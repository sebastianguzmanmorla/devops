FROM jenkins/inbound-agent:latest-jdk17 as jnlp
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim

RUN apt-get update && apt-get -y upgrade \
    && apt-get -y install openjdk-17-jre git

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=jnlp /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar