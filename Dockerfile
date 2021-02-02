FROM quay.io/keycloak/keycloak:11.0.3

USER root

COPY ./keycloak-user-migration/ /project
RUN cd /project && ./mvnw clean package

FROM quay.io/keycloak/keycloak:11.0.3
USER root

COPY --from=0 /project/target/*.jar /opt/jboss/keycloak/standalone/deployments/app.jar
COPY ./themes/ilhasoft/ /opt/jboss/keycloak/themes/ilhasoft/
# COPY ./standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml
