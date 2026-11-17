# Tarea 0 — Montaje del entorno de pruebas

Entorno de virtualización del laboratorio: anfitriones, máquinas virtuales, imágenes ISO y reglas para mover las VM entre equipos.

| Documento | Contenido | Estado |
|---|---|---|
| [`04-entorn-virtualitzacio.md`](04-entorn-virtualitzacio.md) | Anfitriones, inventario de VM con recursos, decisión sobre Proxmox, portabilidad entre equipos | ✅ |
| [`05-isos.md`](05-isos.md) | Inventario de ISO con tamaño y SHA256, origen y comprobación con la huella oficial | 🟡 (4 verificadas, 4 sin comparación posible o no coincidente, con motivo) |
| [`00-prediccions.md`](00-prediccions.md) | Predicciones iniciales, a revisar al final | 🟡 revisar |
| [`01-requisits.md`](01-requisits.md) | Necesidades y requisitos del laboratorio | 🟡 revisar |

**Pendiente:** medir el espacio libre del SSD del PC (`lsblk`, `df -h`) y decidir el reparto definitivo de VM entre los dos equipos (se ajustará con las mediciones de la tarea 7).
