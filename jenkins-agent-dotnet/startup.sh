#!/bin/bash

cd /home/jenkins/

# Create .secret file if not exist
if [ ! -f .secret ]; then
    touch .secret
fi

while [ ! -s .secret ]
do
    # Get Crumb
    crumb=$(curl \
        -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
        -s "${URL}crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"
    )

    # Check if is a valid Crumb
    if [[ $crumb == Jenkins-Crumb:* ]]; then
        # Get Secret
        curl \
            -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
            -H "$crumb" \
            -s "${URL}computer/${NAME}/slave-agent.jnlp" |
            grep -oP '(?<=<jnlp><application-desc><argument>).*?(?=</argument>)' >> .secret

        secret=$(cat .secret)

        # Check if secret is not empty
        if [[ $secret != "" ]]; then
            echo "Secret is valid, starting agent..."
            break
        else
            echo "Secret is empty, retrying..."
        fi
    else
        echo "Crumb is invalid, retrying..."
    fi

    sleep 10
done

if [ ! -f agent.jar ]; then
    curl -o agent.jar "${URL}jnlpJars/agent.jar"
fi

# Start agent
java -jar agent.jar -url "${URL}" -secret $(cat .secret) -name "${NAME}" -webSocket -workDir "${WORKDIR}"