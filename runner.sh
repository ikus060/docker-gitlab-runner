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
if [ -e /etc/gitlab-runner/config.toml ]; then
    echo "Re-use existing runner token from /etc/gitlab-runner/config.toml"
else
    echo "Register new runner"
    gitlab-runner register \
        --non-interactive \
        --url ${GITLAB_URL} \
        --registration-token ${GITLAB_RUNNER_TOKEN} \
        --executor docker \
        --name "${GITLAB_RUNNER_NAME:-runner}" \
        --output-limit "20480" \
        --docker-image "docker:latest" \
        --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
        ${GITLAB_REGISTER_ARGS}
fi

# Update concurrent value
sed -i "s/concurrent.*/concurrent = ${GITLAB_CONCURRENT:=1}/" /etc/gitlab-runner/config.toml

# run multi-runner
gitlab-runner start

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
