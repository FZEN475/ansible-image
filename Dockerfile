FROM alpine:latest as ansible

ARG ANSIBLE_INVENTORY_CSP_PATH=192.168.2.1:/mnt/nas/secrets/inventory.json
ENV ANSIBLE_INVENTORY_CSP_PATH $ANSIBLE_INVENTORY_CSP_PATH

RUN apk add py3-pip python3 openssh-client git && \
    apk --update --no-cache add --virtual python3-dev && \
    pip3 install --no-cache-dir --upgrade --break-system-packages pip && \
    pip3 install --no-cache-dir --upgrade --break-system-packages --no-binary  \
    ansible ansible-lint mitogen etcd3 'protobuf<=3.20.1' passlib && \
    ansible-galaxy collection install community.docker ansible.posix kubernetes.core community.general

ADD ./entrypoint.sh ./inventory.yaml /

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]