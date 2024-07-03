#!/bin/bash

# Create /home/jenkins/.secret file if not exist
if [ ! -f /home/jenkins/.secret ]; then
    touch /home/jenkins/.secret
fi

while [ ! -s /home/jenkins/.secret ]
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
            grep -oP '(?<=<jnlp><application-desc><argument>).*?(?=</argument>)' >> /home/jenkins/.secret

        secret=$(cat /home/jenkins/.secret)

        # Check if secret is not empty
        if [[ $secret != "" ]]; then
            curl -sO "${URL}jnlpJars/agent.jar"

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

# Start agent
java -jar agent.jar -url "${URL}" -secret $(cat /home/jenkins/.secret) -name "${NAME}" -webSocket -workDir "${WORKDIR}"