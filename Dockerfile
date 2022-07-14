FROM quay.io/keycloak/keycloak:18.0.2

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange

# Install custom providers
RUN curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/2.5.3/keycloak-metrics-spi-2.5.3.jar -o /opt/keycloak/providers/keycloak-metrics-spi-2.5.3.jar
RUN /opt/keycloak/bin/kc.sh build
USER root

RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all

COPY ./keycloak-user-migration/ /project
RUN cd /project && sh ./mvnw clean package

FROM quay.io/keycloak/keycloak:18.0.2
USER root

COPY --from=0 /project/target/*.jar /opt/jboss/keycloak/standalone/deployments/app.jar
COPY ./themes/ilhasoft/ /opt/jboss/keycloak/themes/ilhasoft/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev"]

