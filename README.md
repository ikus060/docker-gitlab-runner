[![Build Status](https://travis-ci.org/ikus060/docker-gitlab-runner.svg?branch=master)](https://travis-ci.org/ikus060/docker-gitlab-runner)

# docker-gitlab-runner

This repository provides a Docker image for Gitlab runners with automatic registration/deregistration based on docker run/stop and provide a `docker-compose.yml` file to install Gitlab with CICD.

## Docker image usage
To start a Gitlab runner only, without docker-compose, you may run this command:

```
docker run -d -v "/var/run/docker.sock:/var/run/docker.sock" -e "GITLAB_URL=http://gitlab.example.com" -e "GITLAB_RUNNER_TOKEN=changeme" ikus060/gitlab-runner:latest
```
This will start a single instance of Gitlab runners with default configuration.

Required variables:
* `GITLAB_URL`: define the URL to Gitlab
* `GITLAB_RUNNER_TOKEN`: define the token for registration. This value should be taken from your Gitlab installation at http://gitlab.example.com/admin/runners/

Optional variables:
* `GITLAB_REGISTER_ARGS`: extra arguments passed to `gitlab-runner register`. This can be used to add more arguments for docker: `--docker-volumes`. To have a complete list of available arguments execute `docker run -it gitlab/gitlab-runner:latest register --help`
* `GITLAB_CONCURRENT`: limits how many jobs globally can be run concurrently. The most upper limit of jobs using all defined runners. 0 does not mean unlimited. Default: 1

## Docker-compose usage
You need to start Gitlab at least once before starting the runner. 

```
git clone https://github.com/ikus060/docker-gitlab-runner.git
cd docker-gitlab-runner 
docker-compose up web
```
Once Gitlab is available, browse to http://example.com/admin/runners/ and get the registration token.
You may then start the runner using the token.
```
GITLAB_RUNNER_TOKEN=Qz3sxs3x5ZP6xNMTw9bA  docker-compose up runner
```
As a more permanent solution, you may store the token into `.env` file.
