#!/bin/bash

# Create /home/jenkins/.secret file if not exist
if [ ! -f /home/jenkins/.secret ]; then
    touch /home/jenkins/.secret
fi

while [ ! -s /home/jenkins/.secret ]
do
    # Wait for Jenkins to start
    sleep 10

    echo "Getting secret from Jenkins..."

    # Get Crumb
    crumb=$(curl \
        -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
        -s "${JENKINS_URL}crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"
    )

    # Check if is a valid Crumb
    if [[ $crumb == Jenkins-Crumb:* ]]; then
        # Get Secret
        curl \
            -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
            -H "$crumb" \
            -s "${JENKINS_URL}computer/${JENKINS_AGENT_NAME}/slave-agent.jnlp" |
            grep -oP '(?<=<jnlp><application-desc><argument>).*?(?=</argument>)' >> /home/jenkins/.secret

        secret=$(cat /home/jenkins/.secret)

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
done

# Start agent
/usr/local/bin/jenkins-agent -secret $(cat /home/jenkins/.secret)