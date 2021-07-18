ARG ARCH=
FROM ${ARCH}debian:latest

EXPOSE 53
EXPOSE 53/udp

RUN apt-get update \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
RUN apt-get install -fy gnupg apt-transport-https gpgv wget cron \
    && wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | tee /etc/apt/sources.list.d/nextdns.list

RUN apt-get update \
    && apt-get install -fy nextdns dnsmasq dnsutils \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/nextdns
COPY run.sh /var/nextdns/run.sh
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY dns4me /etc/cron.d/dns4me

RUN chmod u+r /etc/dnsmasq.conf \
    && chmod guo+x /var/nextdns/run.sh \
    && chmod 0644 /etc/cron.d/dns4me \
    && crontab /etc/cron.d/dns4me

HEALTHCHECK --interval=60s --timeout=10s --start-period=5s --retries=1 \
    CMD dig +time=20 @127.0.0.1 -p 8053 probe-test.dns.nextdns.io && dig +time=20 @127.0.0.1 -p 53 probe-test.dns.nextdns.io

CMD ["/var/nextdns/run.sh"]
