#!/bin/bash
# Script untuk fix database di VPS

# 1. Drop dan recreate database
cd /tmp
sudo -u postgres psql -c "DROP DATABASE IF EXISTS insurance_db;"
sudo -u postgres psql -c "CREATE DATABASE insurance_db OWNER postgres;"
echo "Database recreated!"

# 2. Run migrations
cd "/var/www/smile/Smile Project"
source env/bin/activate
python manage.py migrate
echo "Migrations complete!"

# 3. Create superuser
echo "Creating admin user..."
python manage.py shell -c "
from users.models import User
from stores.models import Store

# Create default store first
store, created = Store.objects.get_or_create(
    code='HQ001',
    defaults={
        'name': 'Smile HQ',
        'address': 'Jakarta',
        'is_active': True
    }
)
print(f'Store: {store.name} (created: {created})')

# Create superadmin
if not User.objects.filter(email='admin@smile.com').exists():
    user = User.objects.create_superuser(
        email='admin@smile.com',
        password='Admin123!',
        first_name='Super',
        last_name='Admin',
        role='super_admin'
    )
    user.store = store
    user.save()
    print('Admin user created!')
else:
    print('Admin already exists')
"

# 4. Restart gunicorn
cd /var/www/smile
pkill gunicorn
./start_gunicorn.sh

echo "=== DONE! ==="
echo "Login with: admin@smile.com / Admin123!"
