
# Innovatech Chile - Backend (Microservicios Spring Boot)

Este repositorio centraliza los microservicios lógicos de negocio para **Innovatech Chile**, estructurados bajo un modelo modular, desacoplado y completamente administrado en la nube.

## 🗂️ Componentes del Sistema
El backend está compuesto por dos microservicios Java totalmente independientes que comparten una única capa de datos relacional:
1.  **Microservicio Despachos:** Encargado de la lógica operativa, control de estados y tracking logístico de las entregas.
2.  **Microservicio Ventas:** Responsable del ciclo comercial, transacciones financieras y procesamiento de ventas corporativas.

---

## 🛠️ Requisitos Previos

Para ejecutar, compilar o depurar estos servicios en tu entorno local necesitas:
* **Java Development Kit (JDK) 17 o superior**.
* **Maven 3+** (O utilizar el envoltorio ejecutable `./mvnw` empaquetado en el proyecto).
* **MySQL 8.0** activo localmente o acceso al endpoint correspondiente de Amazon RDS.

---

## 🚀 Configuración y Uso Local

### 1. Variables de Entorno de Persistencia
Los microservicios obtienen las credenciales de conexión de la base de datos de manera dinámica para evitar credenciales quemadas (*hardcodeadas*) en el código. Configura las siguientes variables en tu sistema operativo o IDE:

```env
SPRING_DATASOURCE_URL=jdbc:mysql://<HOST_RDS_O_LOCAL>:3306/innovatech_db?createDatabaseIfNotExist=true
SPRING_DATASOURCE_USERNAME=backend
SPRING_DATASOURCE_PASSWORD=password123
SPRING_JPA_HIBERNATE_DDL_AUTO=update

🔌 Puertos de Escucha y Endpoints
Cada servicio levanta un servidor embebido Tomcat en un puerto dedicado para no generar conflictos de red:

Servicio Despachos (Puerto 8081):

GET /api/v1/despachos ➡️ Devuelve el listado completo del control logístico.

Servicio Ventas (Puerto 8082):

GET /api/v1/ventas ➡️ Devuelve el historial de transacciones comerciales.

💻 Comandos de Consola (Maven)
Ubícate en la carpeta raíz del microservicio específico que deseas iniciar y ejecuta:
# 1. Limpiar construcciones previas y empaquetar el código en un binario ejecutable .jar
./mvnw clean package -DskipTests

# 2. Levantar el microservicio localmente con el contexto de Spring Boot
./mvnw spring-boot:run

🐳 Dockerización y AWS ECS
Cada componente cuenta con su propio archivo Dockerfile optimizado. El artefacto final .jar se encapsula dentro de una imagen diseñada para correr de manera serverless en el servicio AWS Fargate.
# Construir la imagen Docker local para el microservicio
docker build -t innovatech-despachos:latest .

Análisis Crítico y Errores Resueltos
Si experimentas fallas en el entorno, valida las siguientes soluciones de infraestructura aplicadas en este proyecto:

Error Too many connections en Amazon RDS: Se controló el desbordamiento de hilos bloqueantes limitando rigurosamente el pool de conexiones compartidas mediante configuraciones personalizadas de HikariCP y removiendo tareas inactivas.

Health Checks fallidos en el Load Balancer (Bucle de reinicios en ECS): Corregido configurando las reglas del ALB para apuntar específicamente a los puertos destino de las aplicaciones (8081 o 8082) y usando la ruta base real de la API (/api/v1/...) en lugar de rutas por defecto.

Desarrollado en un entorno DevOps por Ariel Ortiz y Cristofer Lobos (2026).
