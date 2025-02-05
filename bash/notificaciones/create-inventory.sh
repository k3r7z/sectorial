#! /bin/bash -x

readonly REPO_LOGIN=https://www.santafe.gob.ar/repo/login
readonly MINISTERIO_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/1
readonly CIENCIA_TRANSPORTE_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/3
readonly TURISMO_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/4
readonly ROSARIO_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/6
readonly ACUARIO_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/7
readonly SAUCE_VIEJO_URL=https://www.santafe.gob.ar/repo/reporte/jsondatareporte/8
readonly USER="administrador@santafe.gov.ar"
readonly PASSWORD="3e2w1q"
readonly COOKIES_FILE="cookies.txt"

declare csrf_token
curl -c $COOKIES_FILE ${REPO_LOGIN} -o login_page.html
csrf_token=$(grep -oP '(?<=value=").*?(?=")' login_page.html)

curl -c $COOKIES_FILE -b $COOKIES_FILE ${REPO_LOGIN} \
  --data "username=$USER&password=$PASSWORD&_csrf_token=$csrf_token"

curl -b $COOKIES_FILE $MINISTERIO_URL -o ministerio.json
curl -b $COOKIES_FILE $CIENCIA_TRANSPORTE_URL -o ciencia_transporte.json
curl -b $COOKIES_FILE $TURISMO_URL -o turismo.json
curl -b $COOKIES_FILE $ROSARIO_URL -o rosario.json
curl -b $COOKIES_FILE $ACUARIO_URL -o acuario.json
curl -b $COOKIES_FILE $SAUCE_VIEJO_URL -o sauce_viejo.json

rm $COOKIES_FILE login_page.html
