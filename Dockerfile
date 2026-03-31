FROM eclipse-temurin:17-jdk AS builder

WORKDIR /build

# Build-Abhängigkeiten
RUN apt-get update && apt-get install -y ant unzip && rm -rf /var/lib/apt/lists/*

# Repo kopieren
COPY . .

# Build ausfuehren
RUN ant dist

# Konfiguration entpacken
RUN mkdir -p /build/config && unzip dist/*.zip -d /build/config

# --- Runtime ---
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Validator JAR und Konfiguration aus Builder kopieren
COPY --from=builder /build/lib/validator-1.6.0-standalone.jar validator.jar
COPY --from=builder /build/config /app/config

EXPOSE 8080

CMD ["java", "-jar", "validator.jar", "-D", "-H", "0.0.0.0", "-P", "8080", "-G", "-r", "config", "-s", "config/scenarios.xml"]
