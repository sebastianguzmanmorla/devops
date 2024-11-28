export $(cat ../.env | xargs)

# Create .secret file if not exist
if [ ! -f .secret ]; then
    touch .secret
fi

while [ ! -s .secret ]
do
    # Get Crumb
    crumb=$(curl \
        -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
        -s "${JENKINS_LOCAL_URL}crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"
    )

    # Check if is a valid Crumb
    if [[ $crumb == Jenkins-Crumb:* ]]; then
        # Get Secret
        curl \
            -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} \
            -H "$crumb" \
            -s "${JENKINS_LOCAL_URL}computer/${JENKINS_AGENT_NAME_LINUX}/slave-agent.jnlp" |
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
    curl -o agent.jar "${JENKINS_LOCAL_URL}jnlpJars/agent.jar"
fi

# Start agent
java -jar agent.jar -url "${JENKINS_LOCAL_URL}" -secret $(cat .secret) -name "${JENKINS_AGENT_NAME_LINUX}" -webSocket -workDir "${JENKINS_AGENT_WORKDIR_LINUX}"