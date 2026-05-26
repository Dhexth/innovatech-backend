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

# Crear usuario no root
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser

WORKDIR /app

# Copiar jars
COPY --from=builder-despachos /app/despachos/target/*.jar despachos.jar
COPY --from=builder-ventas /app/ventas/target/*.jar ventas.jar

# Copiar script inicio
COPY start.sh .

# Permisos y limpiar line endings
RUN chmod +x start.sh && \
    sed -i 's/\r//' start.sh && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080 8081

CMD ["/bin/sh", "./start.sh"]