# NetworkManagementSuite
Es un proyecto para la gestión y monitoreo de redes, usando contenedores Docker para asegurar modularidad y escalabilidad. Incluye administración de dispositivos UniFi y TP-Link, monitoreo con Nagios, y una interfaz web desarrollada con Reflex y MySQL. Facilita la administración centralizada y eficiente de infraestructuras de red.



Proyecto de Gestión de Redes
Descripción del Proyecto
Versión Simplificada para el Cliente
Petición: Necesitamos crear un sistema de gestión de redes que incluya un control centralizado y monitoreo.

Propuesta: Desarrollaremos un sistema utilizando contenedores Docker para asegurar que cada componente funcione de manera eficiente y sin conflictos. Esto incluirá:

Un contenedor para la aplicación UniFi.
Un contenedor para el controlador de TP-Link.
Un contenedor para el sistema de monitoreo Nagios.
Un contenedor con la base de datos MySQL.
Un contenedor para la web desarrollada con Reflex y MySQL.
Versión Técnica
Petición: Desarrollo de un sistema de gestión de redes integrando varios servicios de monitoreo y control, desplegados en contenedores Docker para mejorar la modularidad y la escalabilidad del sistema.

Propuesta:

Aplicación UniFi:

Contenedor Docker con la imagen de UniFi.
Proporcionará la administración centralizada de dispositivos de red UniFi.
Controlador TP-Link:

Contenedor Docker con la imagen del controlador de TP-Link.
Permitirá la gestión y configuración de dispositivos de red TP-Link.
Sistema de Monitoreo Nagios:

Contenedor Docker con Nagios.
Monitoreará el rendimiento y el estado de la red, alertando sobre posibles problemas.
Base de Datos MySQL:

Contenedor Docker con MySQL.
Almacenará todos los datos necesarios para las aplicaciones y el monitoreo.
Web desarrollada con Reflex y MySQL:

Contenedor Docker para la aplicación web.
Usará Reflex como framework de desarrollo y se conectará a la base de datos MySQL para gestionar datos y operaciones.
Tecnología a Utilizar:

Docker: Plataforma de contenedores que permite la creación y gestión de entornos aislados para cada aplicación, mejorando la portabilidad y consistencia.
UniFi, TP-Link, Nagios: Aplicaciones específicas para la gestión y monitoreo de la red.
MySQL: Sistema de gestión de bases de datos relacional.
Reflex: Framework de desarrollo web que facilitará la creación de una interfaz de usuario intuitiva y funcional.
Esta configuración asegura que cada componente del sistema esté optimizado y pueda ser escalado independientemente según sea necesario.

Docker Compose Configurado y Comentado
Copiar código

version: '3'

services:
  # Contenedor Nagios para monitorear el rendimiento y el estado de la red
  nagios:
    image: jasonrivers/nagios:4.4.6
    ports:
      - "8080:80"  # Exponer Nagios en el puerto 8080 del host
    volumes:
      - nagios_data:/opt/nagios/etc  # Almacenar configuración de Nagios
      - nagios_custom_plugins:/opt/Custom-Nagios-Plugins  # Plugins personalizados de Nagios
      - nagiosgraph_var:/opt/nagiosgraph/var  # Datos de NagiosGraph
      - nagiosgraph_etc:/opt/nagiosgraph/etc  # Configuración de NagiosGraph
    restart: always  # Reiniciar siempre en caso de fallo

  # Contenedor Omada Controller para la gestión de dispositivos TP-Link
  omada-controller:
    container_name: omada-controller
    image: mbentley/omada-controller:5.1
    environment:
      - TZ=Etc/UTC  # Zona horaria
      - MANAGE_HTTP_PORT=8088  # Puerto HTTP de gestión
      - MANAGE_HTTPS_PORT=8043  # Puerto HTTPS de gestión
      - PORTAL_HTTP_PORT=8088  # Puerto HTTP del portal
      - PORTAL_HTTPS_PORT=8043  # Puerto HTTPS del portal
      - SHOW_SERVER_LOGS=true  # Mostrar logs del servidor
      - SHOW_MONGODB_LOGS=false  # No mostrar logs de MongoDB
      - SSL_CERT_NAME="tls.crt"  # Nombre del certificado SSL
      - SSL_KEY_NAME="tls.key"  # Nombre de la clave SSL
    network_mode: host  # Utilizar la red del host
    volumes:
      - omada-data:/opt/tplink/EAPController/data  # Datos del controlador Omada
      - omada-work:/opt/tplink/EAPController/work  # Archivos de trabajo del controlador
      - omada-logs:/opt/tplink/EAPController/logs  # Logs del controlador
    restart: unless-stopped  # Reiniciar a menos que se detenga manualmente

  # Contenedor UniFi Controller para la administración centralizada de dispositivos UniFi
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi-controller
    environment:
      - PUID=1000  # ID del usuario
      - PGID=1000  # ID del grupo
      - MEM_LIMIT=1024 # Limite opcional de memoria
      - MEM_STARTUP=1024 # Memoria de inicio opcional
    volumes:
      - /path/to/data:/config  # Ruta donde se almacenarán los datos de configuración
    ports:
      - 8443:8443  # Puerto HTTPS de gestión
      - 3478:3478/udp  # Puerto UDP para STUN
      - 10001:10001/udp  # Puerto UDP para descubrimiento de dispositivos
      - 8080:8080  # Puerto HTTP de gestión
      - 1900:1900/udp  # Puerto opcional para SSDP
      - 8843:8843  # Puerto opcional para HTTPs
      - 8880:8880  # Puerto opcional para HTTP redireccionado a HTTPS
      - 6789:6789  # Puerto opcional para el portal de invitados
      - 5514:5514/udp  # Puerto opcional para Syslog
    restart: unless-stopped  # Reiniciar a menos que se detenga manualmente

  # Contenedor MySQL para almacenar los datos necesarios para las aplicaciones y el monitoreo
  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root_password  # Contraseña root
      - MYSQL_DATABASE=network_management  # Base de datos predeterminada
      - MYSQL_USER=user  # Usuario de la base de datos
      - MYSQL_PASSWORD=user_password  # Contraseña del usuario
    volumes:
      - mysql_data:/var/lib/mysql  # Almacenar datos de MySQL
    ports:
      - "3306:3306"  # Exponer MySQL en el puerto 3306
    restart: unless-stopped  # Reiniciar a menos que se detenga manualmente

  # Contenedor Reflex Web para la aplicación web desarrollada con Reflex
  reflex-web:
    image: your-reflex-image:latest
    container_name: reflex-web
    environment:
      - DATABASE_URL=mysql://user:user_password@mysql:3306/network_management  # URL de la base de datos
    ports:
      - "3000:3000"  # Exponer la aplicación web en el puerto 3000
    volumes:
      - reflex_data:/app/data  # Almacenar datos de la aplicación web
    restart: unless-stopped  # Reiniciar a menos que se detenga manualmente
    depends_on:
      - mysql  # Esperar a que el contenedor MySQL esté listo antes de iniciar

volumes:
  nagios_data:  # Volumen para almacenar configuración de Nagios
  nagios_custom_plugins:  # Volumen para plugins personalizados de Nagios
  nagiosgraph_var:  # Volumen para datos de NagiosGraph
  nagiosgraph_etc:  # Volumen para configuración de NagiosGraph
  omada-data:  # Volumen para datos del controlador Omada
  omada-work:  # Volumen para archivos de trabajo del controlador Omada
  omada-logs:  # Volumen para logs del controlador Omada
  mysql_data:  # Volumen para datos de MySQL
  reflex_data:  # Volumen para datos de la aplicación Reflex
Explicación de la Aplicación Web Desarrollada con Reflex
La aplicación web desarrollada con Reflex tiene como objetivo proporcionar una interfaz intuitiva para gestionar y monitorear dispositivos de red. Las funcionalidades clave incluyen:

Escaneo de la red: Detecta dispositivos de red, como APs y switches, guardando información relevante como IP, MAC, nombre y modelo.
Adopción de dispositivos: Proporciona un botón para adoptar dispositivos. El backend ejecuta comandos necesarios para añadir dispositivos al controlador UniFi o TP-Link y los configura en Nagios.
Identificación de dispositivos adoptados y no adoptados: La aplicación debe mostrar claramente qué dispositivos ya están adoptados y cuáles no.
Interacción con dispositivos UniFi: La aplicación incluye un botón que permite ejecutar comandos para que los APs UniFi parpadeen, facilitando su identificación física.
La aplicación se desarrollará utilizando el framework Reflex, lo que permitirá una gestión eficiente y amigable de la red.

Tecnologías Utilizadas
Docker: Para la creación y gestión de contenedores de cada componente.
UniFi y TP-Link Controllers: Para la administración centralizada de dispositivos de red.
Nagios: Para el monitoreo del rendimiento y estado de la red.
MySQL: Para el almacenamiento de datos.
Reflex: Para el desarrollo de la aplicación web.
Esta configuración asegura que cada componente del sistema esté optimizado y pueda ser escalado independientemente según sea necesario.