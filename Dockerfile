FROM alpine:3.9

VOLUME ["/var/log/socklog", "/var/spool/postfix"]
EXPOSE 25

ENV HOST=localhost \
    DOMAIN=localdomain \
    MAILNAME=localdomain \
    INET_PROTOCOLS=ipv4 \
    MAIL_RELAY_HOST='' \
    MAIL_RELAY_PORT='' \
    MAIL_RELAY_USER='' \
    MAIL_RELAY_PASS='' \
    MAIL_VIRTUAL_FORCE_TO='' \
    MAIL_VIRTUAL_ADDRESSES='' \
    MAIL_VIRTUAL_DEFAULT='' \
    MAIL_CANONICAL_DOMAINS='' \
    MAIL_NON_CANONICAL_PREFIX='noreply+' \
    MAIL_NON_CANONICAL_DEFAULT='' \
    MESSAGE_SIZE_LIMIT=26214400

# Install s6-overlay, socklog-overlay
ARG S6_VERSION=v1.22.1.0
ARG SOCKLOG_VERSION=v3.1.0-2

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
ADD https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG_VERSION}/socklog-overlay-amd64.tar.gz /tmp/

RUN apk add --no-cache postfix nano iproute2 bash tzdata && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    tar xzf /tmp/socklog-overlay-amd64.tar.gz -C / && \
    (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)

ADD etc /etc
ADD sendmail_test.sh /

RUN chmod a+rx /*.sh && \
    ln -s /sendmail_test.sh /usr/local/bin/sendmail_test && \
    postconf -e inet_interfaces=all && \
    postconf -e smtp_tls_security_level=may && \
    postconf -e smtp_sasl_auth_enable=yes && \
    postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd && \
    postconf -e smtp_sasl_security_options=noanonymous && \
    postconf -e mydestination=localhost && \
    postconf -e mynetworks_style=subnet && \
    postconf -e smtp_helo_name=\$myhostname.\$mydomain && \
    postconf -e virtual_maps='hash:/etc/postfix/virtual, regexp:/etc/postfix/virtual_regexp' && \
    postconf -e sender_canonical_maps=regexp:/etc/postfix/sender_canonical_regexp && \
    postconf compatibility_level=2 && \
    postmap /etc/postfix/sasl_passwd && \
    postmap /etc/postfix/virtual_regexp && \
    postmap /etc/postfix/virtual && \
    postmap /etc/postfix/sender_canonical_regexp

ENTRYPOINT ["/init"]
