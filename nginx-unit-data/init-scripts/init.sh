#!/bin/sh

set -e

app_name="$1"
shift 
port="$1"
shift 

PROJECT_DIR="/code/$app_name"
LOCAL_SETTINGS_FILE="$app_name/$app_name/local_settings.py"

echo 'Checking Django project exsist or not...'
if [ -d "$PROJECT_DIR" ]; then
    echo 'Django project already exsit.'
    echo 'Skip django-admin startproject '$app_name'.'
else
    echo 'Django project dose not exsist.'
    echo 'Django project start create...'
    django-admin startproject $app_name
    # Create ALLOWED_HOST
    ALLOWED_HOSTS="ALLOWED_HOSTS=['"$app_name"']"
    # Remove secret key
    sed -i '/SECURITY WARNING: keep the secret key used in production secret!/d' $app_name/$app_name/settings.py
    sed -i '/SECRET_KEY/d' $app_name/$app_name/settings.py
    # Remove ALLOWED_HOSTS
    sed -i '/ALLOWED_HOSTS/d' $app_name/$app_name/settings.py
    # Add ALLOWED_HOSTS
    sed -i "/DEBUG/a ${ALLOWED_HOSTS}" $app_name/$app_name/settings.py
    # Add STATIC_ROOT
    sed -i -e"$ a STATIC_ROOT = '/static/'" $app_name/$app_name/settings.py
    # Add MEDIA_ROOT
    sed -i -e"$ a MEDIA_ROOT = '/media/'" $app_name/$app_name/settings.py
    # Add MEDIA_URL
    sed -i -e"$ a MEDIA_URL = '/media/'" $app_name/$app_name/settings.py
    echo 'Create project Done!'
fi

if  [ ! -f "$LOCAL_SETTINGS_FILE" ]; then
    echo 'Generate SECRET_KEY ...'
    # Generate SECRET_KEY
    python3 /generate_secret_key.py > $app_name/$app_name/local_settings.py
    # Remove from .local_settings import *
    sed -i '/from .local_settings import */d' $app_name/$app_name/settings.py
    # Add load local_settings
    sed -i "/import os/a from .local_settings import *" $app_name/$app_name/settings.py
    echo 'Generate SECRET_KEY Done!'
fi

# Create nginx-unit config.json
tmp_str_1='
{
"listeners": {
    "*:@@@port@@@": {
      "pass": "routes"
    }
  },
  "routes": [
        {
            "match": {
                "uri": "/static/*"
            },

            "action": {
                "share": "/code/@@@app_name@@@/"
            }
        },
        {
            "match": {
                "uri": "/media/*"
            },

            "action": {
                "share": "/code/@@@app_name@@@/"
            }
        },
        {
            "action": {
                "pass": "applications/django-app"
            }
        }
  ],
  "applications": {
    "django-app": {
      "type": "python 3",
      "path": "/code/@@@app_name@@@/",
      "module": "@@@app_name@@@.wsgi",
      "environment": {
        "DJANGO_SETTINGS_MODULE": "@@@app_name@@@.settings"
      }
    }
  }
}
'
# Repalce str in config.json
tmp_str_2=$(echo $tmp_str_1 | sed -e "s/@@@port@@@/${port}/g")
json_config=$(echo $tmp_str_2 | sed -e "s/@@@app_name@@@/$app_name/g")

# Output and rewriteto config.json
echo $json_config > /docker-entrypoint.d/config.json

exec "$@"

