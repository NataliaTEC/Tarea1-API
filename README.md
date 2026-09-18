# Tarea 1 – API

**Estudiante:** Natalia Granados Rosales
**Carné:** 2021144386
**Estado de la tarea:** Completo

---

## Introducción

Este proyecto corresponde a la Tarea 1 del curso Bases de Datos 2, cuyo objetivo es implementar, a nivel práctico, una arquitectura donde la comunicación entre la aplicación y la base de datos se encuentra desacoplada mediante una API.

Se desarrolló una API REST utilizando Node.js y Express, que se comunica con una base de datos SQL Server (AdventureWorks) alojada en un contenedor Docker sobre WSL con Ubuntu. Toda la interacción con la base de datos se realiza exclusivamente a través de **Stored Procedures**, sin queries SQL sueltas en el código de la aplicación.

La API expone operaciones CRUD (crear, leer, actualizar y eliminar) sobre la tabla `Sales.Customer`, e incluye dos procedimientos de consulta adicionales: uno que retorna los registros de la tabla y otro que responde a una consulta con JOIN entre `Sales.Customer` y `Sales.SalesOrderHeader`, mostrando la información de las órdenes asociadas a cada cliente.

---

## Requisitos previos

- Windows 10/11 con WSL2 habilitado
- Docker Desktop
- Node.js (versión LTS recomendada)
- pnpm como gestor de paquetes
- SQL Server Management Studio (SSMS)
- Extensión **Thunder Client** en Visual Studio Code

---

## 1. Instalación de WSL

```powershell
wsl --install
```
*(PowerShell o CMD)*

Luego puedes buscar la distribución que deseas descargar:

```powershell
wsl.exe --list --online
```
*(PowerShell o CMD)*

Aparecerán todas las versiones y distribuciones disponibles. Una vez elegida la distribución, ejecuta el siguiente comando:

```powershell
wsl.exe --install -d [Distro]
```
*(PowerShell o CMD)*

Cambia `[Distro]` por la distribución que elegiste. Se deja el enlace de la guía más detallada que proporciona Microsoft sobre cómo instalar Linux en Windows con WSL: https://learn.microsoft.com/en-us/windows/wsl/install

## 2. Actualización de paquetes

En la terminal de WSL se realiza la actualización de los paquetes:

```bash
sudo apt update && sudo apt upgrade -y
```
*(Terminal de WSL)*

## 3. Descarga de la imagen de SQL Server

Como siguiente paso se descarga la imagen de SQL Server. Abajo se proporciona el enlace de la guía oficial de Microsoft para la ejecución de imágenes de contenedor de SQL Server para Linux con Docker.

```powershell
docker pull mcr.microsoft.com/mssql/server:2025-latest
```
*(PowerShell o CMD)*

📖 [Guía oficial de Microsoft](https://learn.microsoft.com/es-es/sql/linux/install-upgrade/quickstart-install-docker?view=sql-server-ver17&tabs=cli&pivots=cs1-bash)

## 4. Levantar el contenedor

Para ejecutar la imagen de contenedor de Linux con Docker, ejecuta el siguiente comando:

```powershell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=TUCONTRASEÑA" -p 1433:1433 --name T1-API --hostname T1-API -d mcr.microsoft.com/mssql/server:2025-latest
```
*(PowerShell o CMD)*

> ⚠️ **Precaución:** la contraseña debe seguir la directiva de contraseña predeterminada de SQL Server. De forma predeterminada, la contraseña debe tener al menos ocho caracteres y contener caracteres de tres de los siguientes cuatro conjuntos: mayúsculas, minúsculas, dígitos en base 10 y símbolos.

## 5. Conexión mediante SSMS

En la siguiente tabla se detalla la configuración que se debe realizar:

| Campo | Valor |
|---|---|
| Server Name | `localhost,1433` |
| Autenticación | SQL Server Authentication |
| Usuario | `sa` |
| Contraseña | La definida en el paso 4 |
| Trust server certificate | ✅ Activado |

## 6. Descarga del respaldo

Para la tarea se solicitó descargar la base de datos `AdventureWorks2025.bak` (versión **OLTP**). Se proporciona el enlace del repositorio donde se puede descargar la base de datos: https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks

## 7. Copiar el respaldo al contenedor

```powershell
docker exec -it T1-API mkdir -p /var/opt/mssql/backup

docker cp "%USERPROFILE%\OneDrive\Escritorio\AdventureWorks2025.bak" T1-API:/var/opt/mssql/backup/AdventureWorks2025.bak
```
*(PowerShell o CMD)*

## 8. Restaurar la base de datos desde SSMS

En el siguiente enlace se muestra un video detallado de cómo realizar la restauración de la base de datos `AdventureWorks2025`: https://youtu.be/uRRHtn-s9co

---

## 9. Instalación de Node.js

1. Descarga e instala Node.js (versión LTS) desde el sitio oficial: https://nodejs.org
2. Verifica la instalación:
   ```bash
   node -v
   npm -v
   ```
3. Instala `pnpm` como gestor de paquetes:
   ```bash
   npm install -g pnpm
   ```

## 10. Instalación de dependencias del proyecto

Dentro de la carpeta `proyectos` del repositorio:

```bash
cd proyectos
pnpm install
```

Esto instalará las dependencias definidas en `package.json`: `express`, `cors`, `dotenv` y `mssql`.

## 11. Configuración de variables de entorno

Crea un archivo `.env` dentro de `proyectos` (no se sube al repositorio) siguiendo el modelo de `.env.example`:

```
db_user=sa
db_password=TU_PASSWORD_AQUI
db_host=localhost
db_port=1433
db_name=AdventureWorks2025
```

## 12. Ejecución del servidor

```bash
node index.js
```

Si todo está correctamente configurado, en la consola deben aparecer los siguientes mensajes:

```
Conexión a SQL Server exitosa
Servidor corriendo en puerto 3000
```

---

## 13. Instalación y uso de Thunder Client

**Thunder Client** es una extensión de Visual Studio Code que permite enviar peticiones HTTP (GET, POST, PUT, DELETE) para probar APIs, de forma similar a Postman pero integrada directamente en el editor.

### Instalación

1. Abre Visual Studio Code.
2. Ve a la pestaña de extensiones (`Ctrl + Shift + X`).
3. Busca **Thunder Client**.
4. Haz clic en **Install**.
5. Aparecerá un ícono de rayo ⚡ en la barra lateral izquierda.

### Creación de una petición

1. Haz clic en el ícono de Thunder Client.
2. Selecciona **New Request**.
3. Elige el método HTTP (`GET`, `POST`, `PUT`, `DELETE`) según el endpoint que quieras probar.
4. Escribe la URL, por ejemplo: `http://localhost:3000/api/customers`.
5. Si el método requiere body (`POST` o `PUT`), ve a la pestaña **Body**, selecciona **JSON** y escribe el objeto correspondiente.
6. Haz clic en **Send** para enviar la petición.
7. La respuesta del servidor (código de estado y JSON) aparece en el panel derecho.

### Organización en una colección

Se recomienda agrupar las 6 peticiones en una **colección** (botón **New Collection**) para tenerlas ordenadas y poder reutilizarlas durante la grabación del video, en vez de escribir cada URL manualmente.

---

## 14. Datos de prueba

Esta sección tiene como fin documentar **con qué datos se probó cada endpoint** y qué respuesta se obtuvo, de manera que cualquier persona pueda repetir las pruebas y verificar que la API funciona correctamente.

### Prueba 1: Crear cliente (POST)

La primera prueba consiste en crear un cliente. Se selecciona `POST` en Thunder Client y se agrega la siguiente URL: `http://localhost:3000/api/customers`. En la parte del body se agrega la información del cliente que se desea crear.

```
POST /api/customers
Body:
{
  "StoreID": 1028,
  "TerritoryID": 5
}
```

Resultado:
![alt text](/codigo//image.png)

### Prueba 2: Consultar cliente (GET)

La segunda prueba consiste en mostrar la información de un cliente. Se selecciona `GET` en Thunder Client y se agrega la siguiente URL: `http://localhost:3000/api/customers/<CustomerID>`, reemplazando `<CustomerID>` por el número del cliente que se desea ver.

Resultado:
![alt text](/codigo/image-1.png)

### Prueba 3: Actualizar cliente (PUT)

La tercera prueba consiste en actualizar la información de un cliente. Se selecciona `PUT` en Thunder Client y se agrega la siguiente URL: `http://localhost:3000/api/customers/<CustomerID>`, reemplazando `<CustomerID>` por el número del cliente que se desea actualizar.

Resultado:
![alt text](/codigo/image-2.png)

### Prueba 4: Eliminar cliente (DELETE)

La cuarta prueba consiste en eliminar el registro de un cliente. Se selecciona `DELETE` en Thunder Client y se agrega la siguiente URL: `http://localhost:3000/api/customers/<CustomerID>`, reemplazando `<CustomerID>` por el número del cliente que se desea eliminar.

Resultado:
![alt text](/codigo/image-3.png)



---

## 15. Video de prueba

**Enlace del video:** https://youtu.be/HDRRATiNFSg