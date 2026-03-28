#!/bin/bash

# =====================================================
# Crater - Hostinger Deployment Script
# Run this ONCE via SSH on Hostinger after uploading files:
#   bash deploy.sh
# =====================================================

set -e

echo "=== Crater Deploy Script ==="
echo ""

# 1. Install PHP dependencies
echo "[1/7] Installing Composer dependencies..."
composer install --optimize-autoloader --no-dev --no-interaction

# 2. Generate APP_KEY if not set
echo "[2/7] Checking APP_KEY..."
php artisan key:generate --force

# 3. Run database migrations
echo "[3/7] Running database migrations..."
php artisan migrate --force

# 4. Storage symlink
echo "[4/7] Creating storage symlink..."
php artisan storage:link

# 5. Set permissions
echo "[5/7] Setting permissions on storage and cache..."
chmod -R 775 storage bootstrap/cache

# 6. Cache config, routes, views for performance
echo "[6/7] Caching config, routes and views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Done
echo ""
echo "[7/7] Done! Crater is deployed."
echo ""
echo "NOTE: Add this cron job in Hostinger cPanel > Cron Jobs:"
echo "  * * * * * /usr/bin/php $(pwd)/artisan schedule:run >> /dev/null 2>&1"
echo ""
echo "Visit: https://honestchoicereview.com"
