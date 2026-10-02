FROM maven:3.9-eclipse-temurin-25

LABEL org.opencontainers.image.source2="Hallo"
LABEL org.opencontainers.image.source="https://github.com"

# default changed because image is intended to use as a non root user
ARG USER_HOME_DIR="/home/maven" 
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

RUN git config --system credential.helper 'store --file /var/tmp/.git-credentials'

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
