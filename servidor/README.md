# Backend - MediTurnos API

API REST construida con Spring Boot para el sistema de gestión de turnos médicos MediTurnos.

## Requisitos previos

* **Java JDK 21**
* **MySQL Server 8.0**
* **Apache Maven 3.x** (o usar el wrapper incluido)

---

## Configuración inicial (Primera vez en una PC)

1. **Configurar propiedades locales:**
   Copiar el archivo de ejemplo en `src/main/resources/`:
   ```bash
   cp src/main/resources/application-local.properties.example src/main/resources/application-local.properties
   ```
   Editar `application-local.properties` y colocar la contraseña de tu MySQL local:
   ```properties
   spring.datasource.password=TU_CONTRASENA_LOCAL
   ```

2. **Cargar la base de datos MySQL:**
   Ejecutar los scripts de la carpeta `database/` en la base de datos local en el siguiente orden estricto:
   1. `mediturnos.sql`
   2. `datos_iniciales.sql`
   3. `datos_iniciales_medicos.sql`
   4. `datos_iniciales_turnos.sql`
   5. `migracion_notificaciones.sql`
   6. `migracion_invitado.sql`

---

## Cómo ejecutar la API localmente

En local se usa `mediturnos.correo.proveedor=demostracion` (el código aparece en el log y en la app).

Ejecutar el comando en la carpeta `servidor/mediturnos-api`:
```bash
mvn spring-boot:run
```
(O mediante el botón **Run** / **Debug** en VS Code o IntelliJ).

Verificar el funcionamiento accediendo a:
`http://localhost:8080/salud` (devuelve `{"estado":"ok"}`)

---

## Generación del archivo ejecutable (JAR)

Para empaquetar la aplicación para despliegue:
```bash
mvn clean package
```
El archivo JAR generado se ubicará en `target/mediturnos-api.jar`.

---

## Variables de entorno para despliegue en Azure App Service

En entornos de producción (Azure App Service), la configuración se inyecta mediante variables de entorno en la plataforma, sin escribir contraseñas en el código ni en el repositorio:

| Variable de entorno | Descripción | Valor de ejemplo |
| :--- | :--- | :--- |
| `SPRING_DATASOURCE_URL` | URL de conexión JDBC a la base de datos | `jdbc:mysql://servidor-azure.mysql.database.azure.com:3306/mediturnos?useSSL=true` |
| `SPRING_DATASOURCE_USERNAME` | Usuario administrador de la base de datos | `adminuser` |
| `SPRING_DATASOURCE_PASSWORD` | Contraseña de la base de datos | `CONTRASENA_SECRETA_AZURE` |
| `SERVER_PORT` | Puerto de escucha del servidor | `80` |
| `SPRING_JPA_SHOW_SQL` | Desactiva el logeo de consultas SQL en producción | `false` |
| `MEDITURNOS_RECUPERACION_MODODEMOSTRACION` | Desactiva o activa el código demo de recuperación | `false` |
| `MEDITURNOS_CORREO_PROVEEDOR` | Proveedor de envío de correo | `azure` (o `demostracion`) |
| `MEDITURNOS_CORREO_AZURE_CADENACONEXION` | Cadena de conexión para Azure Communication Services | `cadena_de_conexion_a_azure` |
| `MEDITURNOS_CORREO_REMITENTE` | Dirección de correo del remitente configurada en Azure | `DoNotReply@midominio.com` |
| `MEDITURNOS_PUSH_PROVEEDOR` | Proveedor de envío de notificaciones push | `azure` (o `demostracion`) |
| `MEDITURNOS_PUSH_AZURE_CADENACONEXION` | Cadena de conexión para Azure Notification Hubs | `Cadena_de_conexion_azure` |
| `MEDITURNOS_PUSH_AZURE_NOMBREHUB` | Nombre del Notification Hub en Azure | `mediturnos-hub` |
| `MEDITURNOS_URLPUBLICA` | URL pública de la aplicación para enlaces de correos | `https://mediturnos.azurewebsites.net` |
| `MEDITURNOS_JWT_SECRETO` | Secreto en Base64 (mínimo 32 bytes) para firma de tokens JWT | `secreto_base64_azure` |
| `MEDITURNOS_RECORDATORIOS_HABILITADOS` | Habilita la tarea programada de recordatorios | `true` |
