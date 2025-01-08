#! /bin/bash

readonly URL="https://app.santafe.gov.ar/soportesipaf/archivos"
readonly MODULES=(
  libcom
  confbd
  responeje
  recpreeje
  progeje
  modifeje
  formeje
  ejereceje
  ejegaseje
  sumieje
  contaeje
  delegfiscaleje
  admbaneje
  consultaseje
  benefeje
  admusr
)

readonly FILENAME="modulos"


function download_module(){
  module_filename=$(grep --max-count=1 -oP "$1.*zip" "$FILENAME")
  echo "$module_filename"
  url="$URL/$module_filename"
  echo "$url"
}

if [[ ! -d "SIPAF" ]]
then
  mkdir SIPAF
fi

cd SIPAF || exit 1

wget https://app.santafe.gov.ar/soportesipaf/modulos_cont.html "$FILENAME"

for module in "${MODULES[@]}"
do
  download_module "$module"
done

## Librerias comunes
#wget "$URL/libcom-v6-01.zip"
#
## Configurador de conexiones
#wget "$URL/confbd-v13-00.zip"
#
## Responsables
#wget "$URL/responeje-v6-06.zip"
#
## Reconducción de presupuesto
#wget "$URL/recpreeje-v6-02.zip"
#
## Programación de la ejecución
#wget "$URL/progeje-v6-05.zip"
#
## Modificaciones presupuestarias
#wget "$URL/modifeje-v6-06.zip"
#
## Formulación de presupuesto
#wget "$URL/formeje-v6-13.zip"
#
## Ejecución recursos
#wget "$URL/ejereceje-v6-06.zip"
#
## Ejecución de gastos
#wget "$URL/ejegaseje-v6-14.zip"
#
## Contrataciones y suministras
#wget "$URL/sumieje-v6-09.zip"
#
## Contabilidad
#wget "$URL/contaeje-v6-11.zip"
#
## Consultas delegaciones fiscales
#wget "$URL/delegfiscaleje-v6-05.zip"
#
## Cuentas bancarias y pagos
#wget "$URL/admbaneje-v6-17.zip"
#
## Consultas
#wget "$URL/consultaseje-v6-03.zip"
#
## Beneficiarios
#wget "$URL/benefeje-v6-09.zip"
#
## Administarción de usuarios
#wget "$URL/admusr-v6-02.zip"


