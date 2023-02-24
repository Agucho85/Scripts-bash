#!/bin/bash
# Proveer al script un directorio donde trabajar (sh script.sh home/ > incluir la barra)

DIRECTORIO="$1"
ahora=$(date +"%m_%d_%Y")
hoy=$(printf "%s\n" $ahora)
NombreArchivo="Compilacion"
compilado="./"$NombreArchivo".csv"
backup="./"$NombreArchivo"-bck.csv"

for diretorio in $DIRECTORIO/*
do 
 if [ -d "$archivos" ]
    then
        echo "...Verificando archivos "$diretorio
        for subadirectorio in $diretorio/*
        do
            echo "Encontre archivos en $subadirectorio"
        done
    else
        echo "Encontre archivo en $diretorio"
        echo ""
    fi
done

for f in $DIRECTORIO
do
  echo "Procesando arhcivo $f..."
  (cat "${f}";echo) >> "${hoy}".csv
  echo "archivo concatenado"
done && echo "Proceso de archivos terminado, verificando si existe actualemnte archivo $compilado"

if test ! -f "$compilado";
  then
  echo "No existe archivo Compilacion.csv en este directorio"
fi
if test -f "$compilado";
  then
  echo "Realizando back up - Compilacion-bck.csv" && mv --force $compilado $backup
fi

for i in $compilado
do
   (cat ""${hoy}".csv";echo) >> $compilado && rm -f "${hoy}".csv
done && echo "Nuevo archivo $compilado listo"
