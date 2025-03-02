FROM alpine:latest as ansible

RUN apk add py3-pip python3 openssh-client git && \
    apk --update --no-cache add --virtual python3-dev && \
    pip3 install --no-cache-dir --upgrade --break-system-packages pip && \
    pip3 install --no-cache-dir --upgrade --break-system-packages --no-binary  \
    ansible ansible-lint mitogen etcd3 'protobuf<=3.20.1' passlib jmespath && \
    ansible-galaxy collection install community.docker ansible.posix kubernetes.core community.general community.crypto
ADD ./entrypoint.sh /
ADD ./ansible.cfg /etc/ansible/ansible.cfg

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]