FROM wodby/nginx:1.14

ARG DRUPAL_VER

ENV \
    DRUPAL_VER="8" \
    NGINX_DRUPAL_HIDE_HEADERS="On"


COPY templates/fastcgi.conf.tpl /etc/gotpl/
COPY templates/d${DRUPAL_VER}-vhost.conf.tpl /etc/gotpl/vhost.conf.tpl
COPY init /docker-entrypoint-init.d/
