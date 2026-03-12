#!/bin/bash

set -e

echo "Starting deployment..."

APP_DIR=~/flask-react-template
FRONTEND_DIR=$APP_DIR/src/apps/frontend
BACKEND_DIR=$APP_DIR/src/apps/backend
WEB_DIR=/var/www/react-app

echo "Pulling latest code..."
cd $APP_DIR
git pull origin main

echo "Building React frontend..."
cd $FRONTEND_DIR

npm ci
npm run build

echo "Copying frontend build..."

sudo rm -rf $WEB_DIR/*
sudo cp -r build/* $WEB_DIR/

echo "Setting up Python backend..."

cd $BACKEND_DIR

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
pip install gunicorn

echo "Restart backend..."

pkill gunicorn || true
nohup gunicorn --bind 127.0.0.1:5000 app:app &

echo "Reload nginx..."

sudo nginx -s reload

echo "Deployment successful!"