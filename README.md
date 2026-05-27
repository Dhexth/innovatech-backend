# Innovatech Backend — ISY1101 EP2

## Descripción

Backend de Innovatech Chile compuesto por dos microservicios Spring Boot desplegados en AWS EC2 mediante contenedores Docker y un pipeline CI/CD automatizado con GitHub Actions.

| Microservicio | Puerto | Descripción |
|---|---|---|
| Despachos | 8080 | Gestión de despachos |
| Ventas | 8081 | Gestión de ventas |
| MySQL 8.0 | 3306 | Base de datos persistente |

---

## Estructura del Repositorio

```
innovatech-backend/
├── Dockerfile              # Multi-stage build (3 etapas)
├── start.sh                # Script de arranque de ambos JARs
├── docker-compose.yml      # Stack completo (backend + MySQL)
├── .github/
│   └── workflows/
│       └── deploy.yml      # Pipeline CI/CD
├── despachos/
│   ├── pom.xml
│   └── src/
└── ventas/
    ├── pom.xml
    └── src/
```

---

## Dockerfile — Multi-Stage Build

El Dockerfile utiliza 3 etapas para optimizar el tamaño de la imagen final:

1. **builder-despachos** — Compila el microservicio de despachos con Maven
2. **builder-ventas** — Compila el microservicio de ventas con Maven
3. **Producción** — Imagen final `eclipse-temurin:17-jre` con usuario no root (`appuser`, UID 1001)

Buenas prácticas aplicadas:
- Usuario no root (`appuser:appgroup`)
- Imagen base mínima (JRE, no JDK completo)
- `sed -i 's/\r//' start.sh` para eliminar line endings de Windows
- Puertos 8080 y 8081 expuestos

---

## docker-compose.yml

Levanta el stack completo con:

- **database**: MySQL 8.0 con healthcheck (`mysqladmin ping`)
- **backend**: imagen desde ECR, espera a que la DB esté healthy
- **Red interna**: `app-network` (bridge)
- **Volumen persistente**: `innovatech_mysql_data` (named volume)

### Variables de entorno del backend

| Variable | Valor |
|---|---|
| DB_ENDPOINT | database |
| DB_PORT | 3306 |
| DB_NAME | innovatech_db |
| DB_USERNAME | backend |
| DB_PASSWORD | password123 |

---

## Pipeline CI/CD — GitHub Actions

El pipeline se activa con un `push` a la rama `deploy` y ejecuta:

1. **Checkout** del código
2. **Configure AWS credentials** (usando GitHub Secrets)
3. **Login a Amazon ECR**
4. **Build y Push** de la imagen Docker
5. **Deploy** en la instancia EC2 backend vía SSH

### GitHub Secrets requeridos

| Secret | Descripción |
|---|---|
| AWS_ACCESS_KEY_ID | Credencial AWS Academy |
| AWS_SECRET_ACCESS_KEY | Credencial AWS Academy |
| AWS_SESSION_TOKEN | Token de sesión AWS Academy |
| AWS_REGION | Región (us-east-1) |
| ECR_REGISTRY | URL del repositorio ECR |
| EC2_HOST | IP pública de la EC2 backend |
| EC2_USER | Usuario SSH (ubuntu) |
| EC2_SSH_KEY | Clave privada PEM |

---

## Despliegue Manual en EC2

En caso de necesitar desplegar manualmente:

```bash
# Conectarse a la EC2 backend
sudo su - ubuntu

# Login a ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ECR_REGISTRY>

# Ir al directorio del proyecto
cd /home/ubuntu/innovatech-backend

# Exportar variables
export ECR_REGISTRY=<ECR_REGISTRY>
export IMAGE_TAG=<SHA_DE_LA_IMAGEN>

# Levantar el stack
docker compose up -d

# Verificar estado
docker compose ps
docker volume ls
```

---

## Persistencia de Datos

Se utiliza un **named volume** (`innovatech_mysql_data`) para la base de datos MySQL.

**¿Por qué named volume y no bind mount?**
- Gestionado por Docker, portable entre contenedores
- No depende de la ruta del sistema de archivos del host
- Los datos persisten al reiniciar o reemplazar el contenedor de base de datos

---

## Endpoints disponibles

```
GET  http://<IP_BACKEND>:8080/api/v1/despachos
POST http://<IP_BACKEND>:8080/api/v1/despachos
PUT  http://<IP_BACKEND>:8080/api/v1/despachos/{id}
DELETE http://<IP_BACKEND>:8080/api/v1/despachos/{id}

GET  http://<IP_BACKEND>:8081/api/v1/ventas
POST http://<IP_BACKEND>:8081/api/v1/ventas
```

---

## Integrantes

- Ariel Ortiz
- Cristofer Lobos

**Asignatura:** ISY1101-004V — Introducción a Herramientas DevOps  
**Profesor:** Álvaro Mellado  
**Evaluación:** Parcial N°2 — 2025
