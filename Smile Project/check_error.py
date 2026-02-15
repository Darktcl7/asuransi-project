
import os
import django
from django.conf import settings

# Setup Django minimal
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Smile_Project.settings')
try:
    django.setup()
    print("Django Setup OK")
    
    # Coba import views yang baru diedit
    from admin_api import views
    from admin_api import report_views
    print("Import Views OK")
except Exception as e:
    print(f"ERROR: {e}")
