#!/bin/bash
# Mide el equipo anfitrión durante un tiempo y guarda los datos con una etiqueta de etapa.
# Uso: ./medir.sh ETAPA [SEGUNDOS]      (por defecto, 120 s; una muestra cada 5 s)
# Ejemplo: ./medir.sh E1-mikrotik 120
E=${1:?Indica la etapa, por ejemplo E0-solo-anfitrion}
S=${2:-120}
D="$HOME/medidas"; mkdir -p "$D"
CSV="$D/host.csv"
N=$((S/5))

# Cabecera tomada de vmstat, para no depender de la versión
if [ ! -f "$CSV" ]; then
  echo "etapa,$(vmstat -n -t 1 1 | sed -n 2p | xargs | tr ' ' ',' | sed 's/,[^,]*$/,fecha,hora/')" > "$CSV"
fi

# Muestras de vmstat (se salta la primera, que es la media desde el arranque)
vmstat -n -t 5 $((N+1)) | tail -n +4 | while read -r linea; do
  echo "$E,$(echo "$linea" | xargs | tr ' ' ',')" >> "$CSV"
done

# Instantánea de memoria y de los procesos de las VM al final de la etapa
{
  echo "=== $E $(date '+%Y-%m-%d %H:%M:%S')"
  uptime
  free -m
  echo "--- procesos de VirtualBox (RSS en KB, %CPU)"
  ps -eo rss,pcpu,args --sort=-rss | grep -E "VirtualBoxVM|VBoxHeadless" | grep -v grep | cut -c1-170
  echo
} >> "$D/instantaneas.txt"
echo "Etapa $E guardada en $D"
