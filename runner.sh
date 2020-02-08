#!/usr/bin/env bash
set -e
set -x

if [ -z $GITLAB_URL ]; then
    echo "GITLAB_URL is required" 
    exit 1
fi
if [ -z $GITLAB_RUNNER_TOKEN ]; then
    echo "GITLAB_RUNNER_TOKEN is required"
    exit 1
fi

# Wait until gitlab is responding
until curl -s ${GITLAB_URL}>/dev/null; do
    echo "Wait for gitlab ${GITLAB_URL} to become available..."
    sleep 5
done
sleep 5

# register runner only if not configure.
# when user mount /etc/gitlab-runner, the config may already exists.
if [ ! -z "$CI_SERVER_TOKEN" ]; then
    echo "Use provided runner token from CI_SERVER_TOKEN"
elif [ -e /etc/gitlab-runner/config.toml ]; then
    echo "Re-use existing runner token from /etc/gitlab-runner/config.toml"
    export CI_SERVER_TOKEN=$(cat /etc/gitlab-runner/config.toml | grep token | awk '{print $3}' | tr -d '"')
else
    echo "Register new runner"
    gitlab-runner register \
        --non-interactive \
        --url ${GITLAB_URL} \
        --registration-token "$GITLAB_RUNNER_TOKEN" \
        --name "${GITLAB_RUNNER_NAME:-runner}" \
        ${GITLAB_REGISTER_ARGS}
    export CI_SERVER_TOKEN=$(cat /etc/gitlab-runner/config.toml | grep token | awk '{print $3}' | tr -d '"')
fi

# run multi-runner
gitlab-runner run-single \
    --url ${GITLAB_URL} \
    --name "${GITLAB_RUNNER_NAME:-runner}"
    --executor docker \
    --output-limit "20480" \
    --docker-image "docker:latest" \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
    --limit ${GITLAB_CONCURRENT:=1} \
    ${GITLAB_REGISTER_ARGS}
