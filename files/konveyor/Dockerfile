# Build stage
FROM {{ .Values.dockerfile.buildImage | default "registry.access.redhat.com/ubi9/openjdk-21:latest" }} AS builder
WORKDIR /build
COPY . .
RUN mvn package -DskipTests {{ .Values.dockerfile.mavenArgs | default "" }}

# Runtime stage
FROM {{ .Values.dockerfile.runtimeImage | default "registry.access.redhat.com/ubi9/openjdk-21-runtime:latest" }}
WORKDIR /deployments
COPY --from=builder /build/target/*.jar app.jar
EXPOSE {{ .Values.containerPort | default 8080 }}
ENV JAVA_OPTS="{{ .Values.dockerfile.javaOpts | default "" }}"
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
