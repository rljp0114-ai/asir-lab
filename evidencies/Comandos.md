# Debian Server:
- ip -br addr (Muestra las interfaces de red y sus direcciones IP)
- ip route (Rutas de red y Gateway del debian)
He instalado Debian 13 Server en VirtualBox sin entorno gráfico, con las utilidades básicas y el servidor SSH. He configurado el primer adaptador de red en modo NAT y he comprobado que tiene conexión a Internet mediante ping. También he añadido un segundo adaptador conectado a la red interna asir_lab, que he identificado como enp0s8. La interfaz secundaria todavía no tiene una IP configurada de forma permanente, por lo que queda pendiente completar la configuración de la red interna 192.168.34.0/24 y comprobar la comunicación con otras máquinas virtuales.
