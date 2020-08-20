#!/bin/sh

set -e

app_name="$1"
shift  
port="$1"

DIR="/code/$app_name"

if [ -d "$DIR" ]; then
    echo 'Project already exsit'
else
    django-admin startproject $app_name
fi

tmp_str_1='
{
"listeners": {
    "*:@@@port@@@
    ": {
      "pass": "routes"
    }
  },
  "routes": [
    {
      "match": {
        "uri": "/static/*"
      },
      "action": {
        "share": "/code/"
      }
    },
    {
      "action": {
        "pass": "applications/django"
      }
    }
  ],
  "applications": {
    "django": {
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

tmp_str_2=$(echo $tmp_str_1 | sed -e "s/@@@port@@@/${port}/g")
json_config=$(echo $tmp_str_2 | sed -e "s/@@@app_name@@@/$app_name/g")

echo $json_config > /docker-entrypoint.d/config.json

exec "$@"

