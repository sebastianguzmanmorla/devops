FROM mcr.microsoft.com/dotnet/sdk:9.0-noble

COPY jenkins-agent-dotnet/startup.sh /home/startup.sh

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y install lsb-release apt-transport-https

RUN wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get update

RUN apt-get -y install msopenjdk-21 git ssh-client sshpass curl python3 clang zlib1g-dev

RUN dotnet workload install wasm-tools

ENV NODE_VERSION=23.2.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
ENV NVM_DIR="/root/.nvm"
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="${PATH}:/root/.nvm/versions/node/v${NODE_VERSION}/bin/"
RUN node --version
RUN npm --version

RUN apt-get clean all