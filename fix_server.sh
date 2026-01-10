#!/bin/bash

# Smile Deployment Fix Script
# Run this on the server as root

echo "=== Starting Deployment Fix ==="

# 1. Fix Directory Permissions (Ensure Nginx can read)
echo "Setting permissions..."
# Grant read/execute to everyone for static files (simplest for catching permission issues)
chmod -R 755 /var/www/smile/
# Ensure the user 'smile_user' (if it exists) owns the django project specific files if needed, 
# but generic read access for Nginx is priority for 404s on static files.

# 2. Update Nginx Configuration
if [ -f "smile.conf" ]; then
    echo "Found smile.conf, updating /etc/nginx/conf.d/smile.conf..."
    cp smile.conf /etc/nginx/conf.d/smile.conf
else
    echo "WARNING: smile.conf not found in current directory. Skipping config update."
fi

# 3. Restart Gunicorn (Backend)
echo "Restarting Gunicorn Service..."
systemctl restart smile

# Wait for socket to be created
sleep 2

# 4. Fix Socket Permissions
if [ -S /var/www/smile/smile.sock ]; then
    echo "Fixing socket permissions..."
    chmod 777 /var/www/smile/smile.sock
else
    echo "ERROR: Socket file /var/www/smile/smile.sock not found! Gunicorn might have failed."
    systemctl status smile --no-pager
fi

# 5. Test and Restart Nginx
echo "Testing Nginx Configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "Restarting Nginx..."
    systemctl restart nginx
    echo "=== Fix Complete ==="
    echo "Check the following URLs:"
    echo " - Dashboard: http://148.230.97.130/dashboard"
    echo " - API:       http://148.230.97.130/api/"
    echo " - APK:       http://148.230.97.130/download/smile-insurance.apk"
else
    echo "CRITICAL: Nginx configuration test failed. Please fix errors shown above."
    exit 1
fi
