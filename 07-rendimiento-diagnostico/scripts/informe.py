#!/usr/bin/env python3
"""Genera la tabla limpia por etapa y la gráfica del informe a partir de datos/ (host.csv e instantaneas.txt).
Solo se usan las ventanas de tiempo en las que las máquinas encendidas coincidían con el nombre de la etapa
(ver informe-rendimiento.md, apartado 'Datos válidos')."""
import csv, re, sys, os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "datos")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "evidencies")
os.makedirs(OUT, exist_ok=True)

def t(s):
    h, m, x = map(int, s.split(":")); return h * 3600 + m * 60 + x

# (nombre, etiqueta corta, etapa en host.csv, ventanas [inicio, fin], instantánea "=== etapa fecha")
ETAPAS = [
 ("E0 solo anfitrión (0 VM)", "E0\n0 VM", [("E0-solo-anfitrion","18:42:42","18:44:42"),("E0-solo-anfitrion","18:48:45","18:49:45")], "18:49:45"),
 ("E1 + MikroTik (1 VM)", "E1\n1 VM", [("E1-mikrotik","18:50:45","18:51:45")], "18:51:45"),
 ("E2 + Linux-Servicios (2 VM)", "E2\n2 VM", [("E2-linux-servicios","18:53:16","18:54:16")], "18:54:16"),
 ("E3 + Linux-Datos (3 VM)", "E3\n3 VM", [("E3-linux-datos","18:55:47","18:56:47")], "18:56:47"),
 ("E4 + Debian Server (4 VM)", "E4\n4 VM", [("E4-debian-server","19:08:23","19:09:23")], "19:09:23"),
 ("E5 + Windows Server 2025 (5 VM)", "E5\n5 VM", [("E5-windows-server","19:13:24","19:14:24")], "19:14:24"),
 ("Clúster Proxmox en reposo (MikroTik + 3 nodos)", "Proxmox\nreposo", [("E5-proxmox-reposo","18:34:30","18:36:32")], "18:36:32"),
 ("Clúster Proxmox migrando una VM", "Proxmox\nmigración", [("E5b-proxmox-migracion","18:36:58","18:38:58")], "18:38:58"),
]

rows = list(csv.DictReader(open(os.path.join(D, "host.csv"), encoding="utf-8")))
txt = open(os.path.join(D, "instantaneas.txt"), encoding="utf-8").read()
inst = {}
for bloque in txt.split("=== ")[1:]:
    cab = bloque.splitlines()[0]; hora = cab.split()[2]
    mem = [l for l in bloque.splitlines() if l.startswith("Mem:")][0].split()
    inst[hora] = dict(total=int(mem[1]), usado=int(mem[2]), libre=int(mem[3]), disp=int(mem[6]))

res = []
for nombre, etq, vent, hora in ETAPAS:
    r = [x for e, a, b in vent for x in rows if x["etapa"] == e and t(a) <= t(x["hora"]) <= t(b)]
    f = lambda k: [float(x[k]) for x in r]
    cpu = [100 - v for v in f("id")]
    i = inst[hora]
    res.append(dict(etapa=nombre, etq=etq, muestras=len(r),
        cpu_media=sum(cpu)/len(r), cpu_max=max(cpu),
        espera_es_max=max(f("wa")), swap_max_MB=max(f("swpd"))/1024,
        libre_min_MB=min(f("libre"))/1024, escritura_media_KBs=sum(f("bo"))/len(r), escritura_max_KBs=max(f("bo")),
        ram_usada_MB=i["usado"], ram_disponible_MB=i["disp"], ram_total_MB=i["total"]))

with open(os.path.join(D, "resumen-etapas.csv"), "w", newline="", encoding="utf-8") as fh:
    w = csv.writer(fh)
    w.writerow(["etapa","muestras","cpu_media_pct","cpu_max_pct","espera_es_max_pct","swap_usado_max_MB","libre_min_MB","escritura_disco_media_KBs","escritura_disco_max_KBs","ram_usada_MB","ram_disponible_MB","ram_total_MB"])
    for x in res:
        w.writerow([x["etapa"],x["muestras"],f'{x["cpu_media"]:.1f}',f'{x["cpu_max"]:.0f}',f'{x["espera_es_max"]:.0f}',f'{x["swap_max_MB"]:.0f}',f'{x["libre_min_MB"]:.0f}',f'{x["escritura_media_KBs"]:.0f}',f'{x["escritura_max_KBs"]:.0f}',x["ram_usada_MB"],x["ram_disponible_MB"],x["ram_total_MB"]])

# Gráfica: dos paneles (memoria y CPU)
plt.rcParams.update({"font.size": 10, "axes.spines.top": False, "axes.spines.right": False})
fig, (a1, a2) = plt.subplots(1, 2, figsize=(12.5, 4.8), dpi=150)
x = range(len(res)); etq = [r["etq"] for r in res]
usada = [r["ram_usada_MB"]/1024 for r in res]; disp = [r["ram_disponible_MB"]/1024 for r in res]
tot = res[0]["ram_total_MB"]/1024
c_usada = ["#2a6f97" if r["ram_disponible_MB"] > 5000 else "#c0392b" for r in res]
a1.bar(x, usada, color=c_usada, width=0.62)
for i, (u, d) in enumerate(zip(usada, disp)):
    a1.text(i, u + 0.2, f"{u:.1f}", ha="center", fontsize=9)
a1.axhline(tot, color="#555", ls="--", lw=1); a1.text(len(res)-0.5, tot + 0.2, f"RAM total {tot:.1f} GiB", ha="right", fontsize=9, color="#555")
a1.set_xticks(list(x)); a1.set_xticklabels(etq, fontsize=8.5); a1.set_ylabel("RAM usada del anfitrión (GiB)"); a1.set_ylim(0, tot + 1.5)
a1.set_title("Memoria: es el recurso que se agota", loc="left", fontsize=11, fontweight="bold")
cm = [r["cpu_media"] for r in res]; cx = [r["cpu_max"] for r in res]
a2.bar([i-0.2 for i in x], cm, width=0.38, color="#2a6f97", label="Media")
a2.bar([i+0.2 for i in x], cx, width=0.38, color="#9ecae1", label="Máximo")
for i, (m, mx) in enumerate(zip(cm, cx)):
    a2.text(i-0.2, m + 1.2, f"{m:.0f}", ha="center", fontsize=8); a2.text(i+0.2, mx + 1.2, f"{mx:.0f}", ha="center", fontsize=8)
a2.set_xticks(list(x)); a2.set_xticklabels(etq, fontsize=8.5); a2.set_ylabel("CPU usada (% de los 8 hilos)"); a2.set_ylim(0, 100)
a2.set_title("CPU: holgada salvo en la migración", loc="left", fontsize=11, fontweight="bold"); a2.legend(frameon=False, loc="upper left")
fig.tight_layout(); fig.savefig(os.path.join(OUT, "2026-11-17-rendimiento-etapas.png"))
for r in res: print(f'{r["etapa"]}: n={r["muestras"]} cpu {r["cpu_media"]:.1f}/{r["cpu_max"]:.0f} usada {r["ram_usada_MB"]} disp {r["ram_disponible_MB"]} swap {r["swap_max_MB"]:.0f} libre_min {r["libre_min_MB"]:.0f}')
