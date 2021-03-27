FROM alpine

RUN apk add --no-cache openssh-client sshpass \
    && mkdir /scp \
    && mkdir -p /root/.ssh

COPY ./docker-entrypoint.sh /bin/docker-entrypoint.sh

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
