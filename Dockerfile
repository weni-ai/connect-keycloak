FROM quay.io/keycloak/keycloak:18.0.2

USER root

RUN microdnf update -y && microdnf install -y glibc-langpack-en gzip hostname java-11-openjdk-headless openssl tar which && microdnf clean all

COPY ./keycloak-user-migration/ /project
RUN cd /project && sh ./mvnw clean package

FROM quay.io/keycloak/keycloak:18.0.2
USER root

COPY --from=0 /project/target/*.jar /opt/jboss/keycloak/standalone/deployments/app.jar
COPY ./themes/ilhasoft/ /opt/jboss/keycloak/themes/ilhasoft/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev"]

