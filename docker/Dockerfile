# Stage 1: Build Vue frontend
FROM node:20-alpine AS frontend
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Build Spring Boot backend
FROM eclipse-temurin:21-jdk AS backend
WORKDIR /app
COPY gradlew build.gradle.kts settings.gradle.kts ./
COPY gradle/ gradle/
RUN chmod +x gradlew
# Cache dependencies in a separate layer
RUN ./gradlew dependencies --no-daemon -q 2>/dev/null || true
COPY src/ src/
# Inject built frontend into classpath static resources
COPY --from=frontend /app/dist src/main/resources/static/
RUN ./gradlew build -x test --no-daemon

# Stage 3: Runtime image (JRE only)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=backend /app/build/libs/*.jar app.jar
USER spring
EXPOSE 8080
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
