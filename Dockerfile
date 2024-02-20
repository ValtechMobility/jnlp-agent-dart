FROM jenkins/inbound-agent:alpine as jnlp

FROM dart:3.3.0

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

USER root

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt update && apt install -y default-jre

RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]