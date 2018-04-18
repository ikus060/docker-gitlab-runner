#!/usr/bin/env bash
set -x

pid=0
token=()

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  gitlab-runner unregister -u ${GITLAB_URL} -t ${token}
  exit 143; # 128 + 15 -- SIGTERM
}

# Wait until gitlab is responding
until curl -s ${GITLAB_URL}; do
    sleep 2
done
sleep 5

# register runner
gitlab-runner register --non-interactive \
                       --url ${GITLAB_URL} \
                       --registration-token ${GITLAB_RUNNER_TOKEN} \
                       --executor docker \
                       --name "runner" \
                       --output-limit "20480" \
                       --docker-image "docker:latest" \
                       --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
		       ${GITLAB_REGISTER_ARGS}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

unset GITLAB_RUNNER_TOKEN
# Update concurrent value
sed -i "s/concurrent.*/concurrent = ${GITLAB_CONCURRENT:=1}/" /etc/gitlab-runner/config.toml

# assign runner token
token=$(cat /etc/gitlab-runner/config.toml | grep token | awk '{print $3}' | tr -d '"')

# run multi-runner
gitlab-ci-multi-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner & pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
