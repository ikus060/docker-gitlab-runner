FROM gitlab/gitlab-runner:v13.5.0
MAINTAINER Patrik Dufresne <info@patrikdufresne.com>

ADD runner.sh /runner.sh
RUN chmod +x /runner.sh

ENTRYPOINT ["/runner.sh"]
