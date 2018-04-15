FROM gitlab/gitlab-runner:v10.6.0
MAINTAINER Patrik Dufresne <info@patrikdufresne.com>

ADD runner.sh /runner.sh
RUN chmod +x /runner.sh

ENTRYPOINT ["/runner.sh"]
