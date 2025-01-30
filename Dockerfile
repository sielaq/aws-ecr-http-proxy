FROM openresty/openresty:1.27.1.1-1-alpine

USER root

RUN apk add -v --no-cache bind-tools python3 py-pip py3-urllib3 py3-colorama supervisor jq \
 && mkdir /cache \
 && addgroup -g 110 nginx \
 && adduser -u 110  -D -S -h /cache -s /sbin/nologin -G nginx nginx \
 && pip install --break-system-packages --upgrade pip awscli==1.37.4 \
 && apk -v --purge del py-pip

COPY files/startup.sh files/renew_token.sh files/health-check.sh files/get_repos.sh  /
COPY files/ecr.ini /etc/supervisor.d/ecr.ini
COPY files/root /etc/crontabs/root

COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY files/index.html /usr/local/openresty/nginx/html/index.html
COPY files/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh /get_repos.sh

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD /health-check.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
