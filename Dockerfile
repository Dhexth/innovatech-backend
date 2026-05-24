# ETAPA 1: Compilar Despachos
FROM maven:3.9.6-eclipse-temurin-17 AS builder-despachos

WORKDIR /app/despachos

COPY despachos/pom.xml .
COPY despachos/src ./src

RUN mvn clean package -DskipTests


# ETAPA 2: Compilar Ventas
FROM maven:3.9.6-eclipse-temurin-17 AS builder-ventas

WORKDIR /app/ventas

COPY ventas/pom.xml .
COPY ventas/src ./src

RUN mvn clean package -DskipTests


# ETAPA 3: Imagen final
FROM eclipse-temurin:17-jre

# Crear usuario no-root
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser

WORKDIR /app

# Copiar los JARs
COPY --from=builder-despachos /app/despachos/target/*.jar despachos.jar
COPY --from=builder-ventas /app/ventas/target/*.jar ventas.jar

# Cambiar a usuario no-root
USER appuser

# Exponer puertos
EXPOSE 8080 8081

# Ejecutar ambos microservicios
CMD ["sh", "-c", "java -jar despachos.jar --server.port=8080 & java -jar ventas.jar --server.port=8081"]