#! /bin/bash -x

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
readonly MAIN_URL="https://app.santafe.gov.ar/soportesipaf"
readonly FILENAME="modulos_cont.html"
readonly LOG="/var/log/sipaf.log"
NOW=$(date)


function download_module(){
  local module=$1 tries=3 module_filename url
  module_filename=$(grep --max-count=1 -oP "archivos/${module}.*zip" "$SIPAF_DIR/$FILENAME")
  url="$MAIN_URL/$module_filename"

  for (( i=0; i < tries; ++i))
  do
    echo "$url (intento $((i+1)))"
    if curl "$url" 1>"$SIPAF_DIR/${module}.zip" #2>>"$SIPAF_DIR/$LOG"
    then
      if ! unzip -o "$SIPAF_DIR/${module}.zip" -d "$SIPAF_DIR"
      then
        echo "ERROR: Ocurrió un error al descomprimir el archivo"
        exit 1
      fi
      rm "$SIPAF_DIR/${module}.zip"
      break
    fi
  done

  if [[ $i == 3 ]]
  then
    echo "Ocurrió un error al intentar descargar $module"
  fi
}


if ! curl "$MAIN_URL/modulos_cont.html" 1>"$SIPAF_DIR/$FILENAME"
then
  echo "Ocurrió un error al descargar los módulos"
  echo "Ejecutando script a las $NOW (exit code 1)" 1>>"$LOG"
  exit 1
else
  for module in "${MODULES[@]}"
  do
    download_module "$module"
  done
  rm "$SIPAF_DIR/$FILENAME"
  echo "Ejecutando script a las $NOW (exit code 0)" 1>>"$LOG"
  exit 0
fi
