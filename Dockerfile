FROM jenkins/inbound-agent:alpine as jnlp

FROM ubuntu:24.04

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update && \
    apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa cmake openjdk-17-jre openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash jenkins
USER jenkins
WORKDIR /home/jenkins

ARG flutterVersion=stable

ADD https://api.github.com/repos/flutter/flutter/compare/${flutterVersion}...${flutterVersion} /dev/null

RUN git clone https://github.com/flutter/flutter.git -b ${flutterVersion} flutter-sdk

RUN flutter-sdk/bin/flutter precache

RUN flutter-sdk/bin/flutter config --no-analytics

ENV PATH="$PATH:/home/jenkins/flutter-sdk/bin"
ENV PATH="$PATH:/home/jenkins/flutter-sdk/bin/cache/dart-sdk/bin"
ENV PATH="$PATH:/home/jenkins/.pub-cache/bin"

RUN curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    mkdir android && \
    unzip commandlinetools-linux-11076708_latest.zip -d android && \
    rm commandlinetools-linux-11076708_latest.zip
RUN echo -n "y" | android/cmdline-tools/bin/sdkmanager --install "platform-tools" "cmdline-tools;latest" "platforms;android-34" "build-tools;34.0.0" --sdk_root=/home/jenkins/flutter-sdk/ && \
    flutter config --android-sdk /home/jenkins/flutter-sdk && \
    yes | flutter doctor --android-licenses
USER root

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]