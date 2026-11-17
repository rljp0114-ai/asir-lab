#!/bin/bash
# Mide el anfitrión durante una etapa: CPU, RAM, swap, E/S (vmstat), red y disco.
# Uso: ./medir.sh E3-clusterproxmox 120      (etapa y segundos, 120 por defecto)
# Variables opcionales: MEDIDAS_DIR (carpeta de salida), IFACE (tarjeta de red), DISCO (disco).
E=${1:?Indica la etapa, por ejemplo E0-solo-anfitrion}
S=${2:-120}
D="${MEDIDAS_DIR:-$HOME/medidas}"; mkdir -p "$D"
CSV="$D/host.csv"
IFACE=${IFACE:-$(ip route show default | awk '{print $5; exit}')}
DISCO=${DISCO:-$(lsblk -no PKNAME "$(findmnt -no SOURCE /home)" 2>/dev/null | head -1)}
DISCO=${DISCO:-sda}
N=$((S/5))

red()   { awk -v i="$IFACE:" '$1==i{print $2, $10}' /proc/net/dev; }
disco() { awk -v d="$DISCO" '$3==d{print $6, $10, $13}' /proc/diskstats; }

read -r RX0 TX0 < <(red); read -r SR0 SW0 IO0 < <(disco); T0=$(date +%s)

if [ ! -f "$CSV" ]; then
  echo "etapa,$(vmstat -n -t 1 1 | sed -n 2p | xargs | tr ' ' ',' | sed 's/,[^,]*$/,fecha,hora/')" > "$CSV"
fi
vmstat -n -t 5 $((N+1)) | tail -n +4 | while read -r linea; do
  echo "$E,$(echo "$linea" | xargs | tr ' ' ',')" >> "$CSV"
done

read -r RX1 TX1 < <(red); read -r SR1 SW1 IO1 < <(disco); T1=$(date +%s)
DT=$((T1-T0)); [ "$DT" -lt 1 ] && DT=1
R="$D/resumen.csv"
[ -f "$R" ] || echo "etapa,fecha,segundos,tarjeta_red,rx_KBs,tx_KBs,disco,lect_MBs,escr_MBs,util_disco_pct" > "$R"
LC_ALL=C awk -v e="$E" -v f="$(date '+%Y-%m-%d %H:%M:%S')" -v dt="$DT" -v i="$IFACE" -v d="$DISCO" \
    -v rx=$((RX1-RX0)) -v tx=$((TX1-TX0)) -v sr=$((SR1-SR0)) -v sw=$((SW1-SW0)) -v io=$((IO1-IO0)) 'BEGIN{
  printf "%s,%s,%d,%s,%.1f,%.1f,%s,%.2f,%.2f,%.1f\n", e,f,dt,i,rx/1024/dt,tx/1024/dt,d,sr*512/1048576/dt,sw*512/1048576/dt,io/(dt*10)}' >> "$R"

{ echo "=== $E $(date '+%Y-%m-%d %H:%M:%S')"; uptime; free -m
  echo "--- procesos de VirtualBox (RSS en KB, %CPU)"
  ps -eo rss,pcpu,args --sort=-rss | grep -E "VirtualBoxVM|VBoxHeadless" | grep -v grep | cut -c1-170
  echo "--- máquinas en marcha"; VBoxManage list runningvms 2>/dev/null; echo; } >> "$D/instantaneas.txt"
echo "Etapa $E guardada en $D (red: $IFACE, disco: $DISCO)"
