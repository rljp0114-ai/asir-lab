#!/bin/bash
# Resume por etapa el fichero host.csv que genera medir.sh.
# Uso: ./analizar.sh [carpeta]     (por defecto ~/medidas)
D="${1:-$HOME/medidas}"
LC_ALL=C awk -F, '
NR==1 { for (i=1;i<=NF;i++) c[$i]=i; next }
{
  e=$1; if (!(e in n)) { ord[++k]=e; minfree[e]=1e12 }
  n[e]++
  cpu=100-$c["id"]; sc[e]+=cpu; if (cpu>mc[e]) mc[e]=cpu
  wa[e]+=$c["wa"]; if ($c["wa"]>mw[e]) mw[e]=$c["wa"]
  fr=$c["free"]/1024; if (fr<minfree[e]) minfree[e]=fr; sf[e]+=fr
  av=($c["free"]+$c["buff"]+$c["cache"])/1024; sa[e]+=av
  if ($c["swpd"]>ms[e]) ms[e]=$c["swpd"]
  si[e]+=$c["si"]+$c["so"]
  bi[e]+=$c["bi"]; bo[e]+=$c["bo"]; if ($c["bo"]>mbo[e]) mbo[e]=$c["bo"]
  rq[e]+=$c["r"]; if ($c["r"]>mr[e]) mr[e]=$c["r"]
}
END {
  print "etapa,muestras,cpu_media_pct,cpu_max_pct,espera_E/S_media_pct,espera_E/S_max_pct,cola_media,cola_max,libre_media_MB,libre_min_MB,disponible_media_MB,swap_usado_max_MB,swap_in_out_media,bi_media,bo_media,bo_max"
  for (j=1;j<=k;j++) { e=ord[j]
    printf "%s,%d,%.1f,%.1f,%.1f,%.1f,%.1f,%d,%.0f,%.0f,%.0f,%.0f,%.1f,%.0f,%.0f,%.0f\n", e,n[e],sc[e]/n[e],mc[e],wa[e]/n[e],mw[e],rq[e]/n[e],mr[e],sf[e]/n[e],minfree[e],sa[e]/n[e],ms[e]/1024,si[e]/n[e],bi[e]/n[e],bo[e]/n[e],mbo[e] }
}' "$D/host.csv" | column -s, -t
