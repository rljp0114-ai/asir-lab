#!/bin/bash
# Arranca las VM del proyecto una a una y mide el anfitrión tras cada una. Para si no queda memoria.
# Antes de lanzarlo hay que apagar todas las VM (comprueba que no haya ninguna encendida).
export MEDIDAS_DIR=~/medidas-pc
if [ -n "$(VBoxManage list runningvms)" ]; then
  echo "ERROR: hay VM encendidas. Apágalas antes de medir:"; VBoxManage list runningvms; exit 1
fi
echo "== E0-solo-anfitrion"; ~/medir.sh E0-solo-anfitrion 60
while IFS='|' read -r etapa vm ram espera; do
  disp=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
  echo "Disponible: ${disp} MB. Siguiente: $vm (${ram} MB)"
  if [ "$disp" -lt $((ram+1500)) ]; then
    echo "PARO: no hay margen para arrancar $vm sin saturar el anfitrión"
    echo "LIMITE antes de $vm (disponible ${disp} MB)" >> $MEDIDAS_DIR/limite.txt; break
  fi
  if ! VBoxManage startvm "$vm" --type headless >/dev/null; then echo "ERROR al arrancar $vm: paro"; break; fi
  echo "$vm arrancada, esperando ${espera}s"; sleep "$espera"
  ~/medir.sh "$etapa" 60
done <<'LISTA'
E1-mikrotik|Mikrotik|512|60
E2-linux-servicios|Linux-Servicios|2048|90
E3-linux-datos|Linux-Datos|2048|90
E4-debian-server|Debian Server|2048|90
E5-windows-server|Windows Server 2025|4096|240
E6-truenas|TrueNAS|8192|240
LISTA
echo "Hecho. Máquinas en marcha:"; VBoxManage list runningvms
