FROM jenkins/inbound-agent:alpine as jnlp

FROM ubuntu:22.04

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update && \
    apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa cmake && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r -g 1441 jenkins && useradd --no-log-init -r -u 1441 -g jenkins -m jenkins
USER jenkins:jenkins
WORKDIR /home/jenkins

ARG flutterVersion=stable

ADD https://api.github.com/repos/flutter/flutter/compare/${flutterVersion}...${flutterVersion} /dev/null

RUN git clone https://github.com/flutter/flutter.git -b ${flutterVersion} flutter-sdk

RUN flutter-sdk/bin/flutter precache

RUN flutter-sdk/bin/flutter config --no-analytics

ENV PATH="$PATH:/home/jenkins/flutter-sdk/bin"
ENV PATH="$PATH:/home/jenkins/flutter-sdk/bin/cache/dart-sdk/bin"
ENV PATH="$PATH:/home/jenkins/.pub-cache/bin"

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]