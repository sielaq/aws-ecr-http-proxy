FROM openresty/openresty:1.29.2.1-0-alpine

USER root

RUN apk add -v --no-cache bind-tools python3 py-pip py3-urllib3 py3-colorama supervisor jq \
 && mkdir /cache \
 && addgroup -g 110 nginx \
 && adduser -u 110  -D -S -h /cache -s /sbin/nologin -G nginx nginx \
 && pip install --break-system-packages --upgrade pip boto3 \
 && apk -v --purge del py-pip \
 && wget https://cdn.pixabay.com/download/audio/2024/10/12/audio_7dd52a2e33.mp3?filename=richardmultimedia-ocean-waves-250310.mp3 -O /usr/local/openresty/nginx/html/ocean-waves.mp3

COPY files/startup.sh files/renew_token.py files/health-check.sh files/get_repos.py  /
COPY files/ecr.ini /etc/supervisor.d/ecr.ini
COPY files/root /etc/crontabs/root

COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY files/index.html /usr/local/openresty/nginx/html/index.html
COPY files/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf

ENV PORT 5000
RUN chmod a+x /startup.sh

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD /health-check.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
