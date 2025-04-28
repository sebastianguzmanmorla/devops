FROM jenkins/jenkins:latest-jdk21

COPY jenkins/casc.yaml /var/casc.yaml

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/casc.yaml

RUN jenkins-plugin-cli --plugins \
    ant:latest \
    antisamy-markup-formatter:latest \
    authorize-project:latest \
    build-timeout:latest \
    config-file-provider:latest \
    cloudbees-folder:latest \
    configuration-as-code:latest \
    credentials-binding:latest \
    email-ext:latest \
    generic-webhook-trigger:latest \
    git:latest \
    github-branch-source:latest \
    gradle:latest \
    ldap:latest \
    mailer:latest \
    matrix-auth:latest \
    multibranch-scan-webhook-trigger:latest \
    pam-auth:latest \
    pipeline-github-lib:latest \
    pipeline-stage-view:latest \
    pipeline-utility-steps:latest \
    purge-job-history:latest \
    ssh-slaves:latest \
    timestamper:latest \
    workflow-aggregator:latest \
    workflow-api:latest \
    ws-cleanup:latest