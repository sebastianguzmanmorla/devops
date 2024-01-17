if (-not (Test-Path -Path ../.env)) {
    Write-Host ".env file not found, exiting..."
    exit 1
}

$JENKINS_URL = (Get-Content -Path ../.env | Select-String -Pattern "JENKINS_URL=").ToString().Split("=")[1].Trim()
$JENKINS_NODE_HELPER_ID = (Get-Content -Path ../.env | Select-String -Pattern "JENKINS_NODE_HELPER_ID=").ToString().Split("=")[1].Trim()
$JENKINS_NODE_HELPER_PASSWORD = (Get-Content -Path ../.env | Select-String -Pattern "JENKINS_NODE_HELPER_PASSWORD=").ToString().Split("=")[1].Trim()
$JENKINS_AGENT_NAME = (Get-Content -Path ../.env | Select-String -Pattern "JENKINS_AGENT_NAME_WINDOWS=").ToString().Split("=")[1].Trim()


if (-not (Test-Path -Path .secret)) {
    New-Item -Path .secret -ItemType File
}

while ([String]::IsNullOrWhiteSpace((Get-Content -Path .secret)))
{
    $CRUMB_URL = "${JENKINS_URL}crumbIssuer/api/xml?xpath=concat(//crumbRequestField,`":`",//crumb)"
    $CRUMB = curl -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} -s ${CRUMB_URL}

    if ($CRUMB -match "Jenkins-Crumb:")
    {
        $SECRET_URL = "${JENKINS_URL}computer/${JENKINS_AGENT_NAME}/slave-agent.jnlp"
        $SECRET_CURL = curl -u ${JENKINS_NODE_HELPER_ID}:${JENKINS_NODE_HELPER_PASSWORD} -H "$CRUMB" -s ${SECRET_URL}
        $SECRET_REGEX = [regex]::Matches($SECRET_CURL, "<jnlp><application-desc><argument>(.*?)</argument>")
        $SECRET = $SECRET_REGEX.Groups[1].Value

        if([String]::IsNullOrWhiteSpace($SECRET))
        {
            Write-Host "Secret is invalid, retrying..."
        }
        else
        {
            Set-Content -Path .secret -Value $SECRET

            Write-Host "Secret is valid, starting agent..."
        }
    }
    else
    {
        Write-Host "Crumb is invalid, retrying... (Jenkins is not ready?)"
    }

    Start-Sleep -Seconds 10
}

curl -sO "${JENKINS_URL}jnlpJars/agent.jar"

$WORK_DIR = Get-Location

$SECRET = Get-Content -Path .secret

while($True)
{
    java -jar agent.jar -webSocket -url "${JENKINS_URL}" -secret "${SECRET}" -name "${JENKINS_AGENT_NAME}" -workDir "${WORK_DIR}" -failIfWorkDirIsMissing

    Write-Host "Agent has stopped, restarting in 10 seconds..."

    Start-Sleep -Seconds 10
}
