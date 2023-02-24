bash script para tirar un ll y que agarre cada uno de los archivos menos los dos primeros ". , .." y algun otro con el grep y luego mientras los lee los tire en otra carpeta X, no importa si lo que lee con el ls es una carpeta tb la lleva puesta.....

ls -alqh | tail -n+4 | tr -s " " | cut -f9 -d " " |  grep -v MareasApi | while read -r line; do mv "$line"  MareasApi/ ; done | pwd


sudo ls -alht | head -6 | tr -s " " | cut -f9 -d " " | while read -r line; do xargs cat $line; done