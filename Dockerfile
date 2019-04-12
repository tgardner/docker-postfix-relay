FROM trentgardner/base-s6:latest

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

ADD etc /etc
ADD sendmail_test /usr/local/bin/

RUN cleaninstall postfix iproute2 cyrus-sasl-plain cyrus-sasl-login && \
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

VOLUME ["/var/spool/postfix"]
EXPOSE 25

ENTRYPOINT ["/init"]
