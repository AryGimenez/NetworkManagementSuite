# NetworkManagementSuite

Es un proyecto para la gestión y monitoreo de redes, usando contenedores Docker para asegurar modularidad y escalabilidad. Incluye administración de dispositivos UniFi y TP-Link, monitoreo con Nagios, y una interfaz web desarrollada con Reflex y MySQL. Facilita la administración centralizada y eficiente de infraestructuras de red.

## Proyecto de Gestión de Redes

### Descripción del Proyecto

#### Versión Simplificada para el Cliente

**Petición:** Necesitamos crear un sistema de gestión de redes que incluya un control centralizado y monitoreo.

**Propuesta:** Desarrollaremos un sistema utilizando contenedores Docker para asegurar que cada componente funcione de manera eficiente y sin conflictos. Esto incluirá:

- Un contenedor para la aplicación UniFi.
- Un contenedor para el controlador de TP-Link.
- Un contenedor para el sistema de monitoreo Nagios.
- Un contenedor con la base de datos MySQL.
- Un contenedor para la web desarrollada con Reflex y MySQL.

#### Versión Técnica

**Petición:** Desarrollo de un sistema de gestión de redes integrando varios servicios de monitoreo y control, desplegados en contenedores Docker para mejorar la modularidad y la escalabilidad del sistema.

**Propuesta:**

##### Aplicación UniFi:

- **Contenedor Docker con la imagen de UniFi.**
- Proporcionará la administración centralizada de dispositivos de red UniFi.

##### Controlador TP-Link:

- **Contenedor Docker con la imagen del controlador de TP-Link.**
- Permitirá la gestión y configuración de dispositivos de red TP-Link.

##### Sistema de Monitoreo Nagios:

- **Contenedor Docker con Nagios.**
- Monitoreará el rendimiento y el estado de la red, alertando sobre posibles problemas.

##### Base de Datos MySQL:

- **Contenedor Docker con MySQL.**
- Almacenará todos los datos necesarios para las aplicaciones y el monitoreo.

##### Web desarrollada con Reflex y MySQL:

- **Contenedor Docker para la aplicación web.**
- Usará Reflex como framework de desarrollo y se conectará a la base de datos MySQL para gestionar datos y operaciones.

### Tecnología a Utilizar

- **Docker:** Plataforma de contenedores que permite la creación y gestión de entornos aislados para cada aplicación, mejorando la portabilidad y consistencia.
- **UniFi, TP-Link, Nagios:** Aplicaciones específicas para la gestión y monitoreo de la red.
- **MySQL:** Sistema de gestión de bases de datos relacional.
- **Reflex:** Framework de desarrollo web que facilitará la creación de una interfaz de usuario intuitiva y funcional.

Esta configuración asegura que cada componente del sistema esté optimizado y pueda ser escalado independientemente según sea necesario.

### Docker Compose Configurado y Comentado

```yaml
version: '3'

services:

  nagios:
    image: jasonrivers/nagios:4.4.6
    ports:
      - "8080:80"
    volumes:
      - nagios_data:/opt/nagios/etc
      - nagios_custom_plugins:/opt/Custom-Nagios-Plugins
      - nagiosgraph_var:/opt/nagiosgraph/var
      - nagiosgraph_etc:/opt/nagiosgraph/etc
    restart: always

  omada-controller:
    container_name: omada-controller
    image: mbentley/omada-controller:5.1
    environment:
      - TZ=America/Montevideo
      - MANAGE_HTTP_PORT=8088
      - MANAGE_HTTPS_PORT=8043
      - PORTAL_HTTP_PORT=8088
      - PORTAL_HTTPS_PORT=8043
      - SHOW_SERVER_LOGS=true
      - SHOW_MONGODB_LOGS=false
      - SSL_CERT_NAME="tls.crt"
      - SSL_KEY_NAME="tls.key"
    network_mode: host
    volumes:
      - omada-data:/opt/tplink/EAPController/data
      - omada-work:/opt/tplink/EAPController/work
      - omada-logs:/opt/tplink/EAPController/logs
    restart: unless-stopped

  unifi-controller:
    container_name: unifi-controller
    image: lscr.io/linuxserver/unifi-controller:latest
    environment:
      - PUID=1000
      - PGID=1000
      - MEM_LIMIT=1024
      - MEM_STARTUP=1024
    ports:
      - "8443:8443"
      - "3478:3478/udp"
      - "10001:10001/udp"
      - "8081:8080"
      - "1900:1900/udp"
      - "8843:8843"
      - "8880:8880"
      - "6789:6789"
      - "5514:5514/udp"
    volumes:
      - /home/docker/UniFi-Controller:/config
    restart: unless-stopped

  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=network_management
      - MYSQL_USER=user
      - MYSQL_PASSWORD=user_password
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"
    restart: unless-stopped

volumes:
  nagios_data:
  nagios_custom_plugins:
  nagiosgraph_var:
  nagiosgraph_etc:
  omada-data:
  omada-work:
  omada-logs:
  mysql_data:
