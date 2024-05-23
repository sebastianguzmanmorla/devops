FROM jenkins/inbound-agent:latest-jdk17 as jnlp
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim

RUN apt-get update && apt-get -y upgrade \
    && apt-get -y install openjdk-17-jre git ssh-client sshpass curl

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN dotnet workload install wasm-tools

ENV NODE_VERSION=21.7.3
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
ENV NVM_DIR="/root/.nvm"
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="${PATH}:/root/.nvm/versions/node/v${NODE_VERSION}/bin/"
RUN node --version
RUN npm --version