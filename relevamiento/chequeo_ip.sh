#! /bin/bash

readonly REPO_LOGIN=https://www.santafe.gob.ar/repo/login
readonly REPORT=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/19
readonly USER=administrador@santafe.gov.ar
readonly PASSWORD=3e2w1q
readonly COOKIES_FILE=cookies.txt
readonly LOGIN_PAGE=login.html
declare csrf_token

curl -c $COOKIES_FILE $REPO_LOGIN -o $LOGIN_PAGE
csrf_token=$(grep -oP '(?<=value=").*?(?=")' $LOGIN_PAGE)

curl -c $COOKIES_FILE -b $COOKIES_FILE $REPO_LOGIN \
  --data "username=$USER&password=$PASSWORD&_csrf_token=$csrf_token"

curl -b $COOKIES_FILE $REPORT -o ips.json
curl -b $COOKIES_FILE https://www.santafe.gob.ar/repo/persona/new -o persona.html

rm $COOKIES_FILE $LOGIN_PAGE

