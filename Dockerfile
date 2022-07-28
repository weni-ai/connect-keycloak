FROM jboss/keycloak:16.1.1

USER root

COPY ./keycloak-user-migration/ /project
RUN cd /project && sh ./mvnw clean package

FROM jboss/keycloak:16.1.1
USER root

COPY --from=0 /project/target/*.jar /opt/jboss/keycloak/standalone/deployments/app.jar
COPY ./themes/ilhasoft/ /opt/jboss/keycloak/themes/ilhasoft/
# COPY ./standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml