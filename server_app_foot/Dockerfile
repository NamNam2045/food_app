FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app

COPY mvnw .
RUN chmod +x mvnw

COPY .mvn .mvn
COPY pom.xml .

RUN ./mvnw dependency:go-offline -B

COPY src src
RUN ./mvnw package -DskipTests


FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

RUN useradd -m spring
RUN mkdir -p /home/spring/uploads && chown -R spring:spring /home/spring
USER spring

COPY --from=build /app/target/*.jar app.jar

ENV APP_UPLOAD_DIR=/home/spring/uploads

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
