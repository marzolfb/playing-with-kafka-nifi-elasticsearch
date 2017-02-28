FROM alpine

RUN mkdir -p /nifi_init && \
  apk add --update bash curl jq && \
  rm -rf /var/cache/apk/*

RUN mkdir -p /nifi_init
ADD . /nifi_init
WORKDIR /nifi_init

CMD ./nifi_init.sh
