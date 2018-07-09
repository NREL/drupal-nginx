ARG DRUPAL_VER

FROM wodby/nginx:1.14

ARG DRUPAL_VER

RUN echo "Building nginx image containing the vhost file for : $DRUPAL_VER"

ENV \
    NGINX_DRUPAL_HIDE_HEADERS="On" \
    VER="${DRUPAL_VER}"

COPY templates/fastcgi.conf.tpl /etc/gotpl/

COPY templates/${VER}-vhost.conf.tpl /etc/gotpl/vhost.conf.tpl

COPY init /docker-entrypoint-init.d/
