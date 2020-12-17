FROM quay.io/keycloak/keycloak:11.0.3

COPY ./themes/ilhasoft/ /opt/jboss/keycloak/themes/ilhasoft/
#COPY ./standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml
