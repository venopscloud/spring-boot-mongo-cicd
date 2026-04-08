
# Stage 1: Build the application
FROM maven:3.8.5-openjdk-8-slim AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests


# Stage 2: Run the application
FROM eclipse-temurin:8-jre-alpine

ENV PROJECT_HOME=/opt/app
WORKDIR $PROJECT_HOME

COPY --from=build /app/target/spring-boot-mongo-1.0.jar spring-boot-mongo.jar

EXPOSE 8080
CMD ["java", "-jar", "spring-boot-mongo.jar"]
