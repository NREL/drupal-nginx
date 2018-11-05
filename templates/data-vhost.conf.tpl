upstream php {
    server {{ getenv "NGINX_BACKEND_HOST" }}:9000;
}

map $http_x_forwarded_proto $fastcgi_https {
    default $https;
    http '';
    https on;
}


# tell fastcgi about protocol in use. in fastcg_params, adjust variable to $fastcgi_port
map $http_x_forwarded_port $fastcgi_port {
    default $http_x_forwarded_port;
    80 80;
    443 443;
}

server {
    server_name {{ getenv "NGINX_SERVER_NAME" "drupal" }};
    listen 80 default_server{{ if getenv "NGINX_HTTP2" }} http2{{ end }};

    root {{ getenv "NGINX_SERVER_ROOT" "/var/www/html/" }};
    index index.php;

    include fastcgi.conf;

{{ if getenv "NGINX_DRUPAL_HIDE_HEADERS" }}
    fastcgi_hide_header 'X-Drupal-Cache';
    fastcgi_hide_header 'X-Generator';
    fastcgi_hide_header 'X-Drupal-Dynamic-Cache';
{{ end }}


    location / {

        location /files/ {
            # proxy_set_header Host 'nrel-datacat-public-stage.s3.amazonaws.com';
            # proxy_hide_header x-amz-id-2;
            # proxy_hide_header x-amz-request-id;
            # proxy_hide_header Set-Cookie;
            # proxy_ignore_headers "Set-Cookie";
            # proxy_intercept_errors on;
            # access_log off;
            # log_not_found off;
            proxy_pass https://nrel-datacat-public-{{ getenv "DEPLOY_ENV" "prod" }}.s3.amazonaws.com/files/;
        }
    
        location ~ /submissions/?$ {
            rewrite ^ /view.php?id=all;
        }
    
        location ~ /submissions/([0-9]+|all|mine)$ {
                rewrite ^/submissions/([0-9]+|all|mine)$ /view.php?id=$1 last;
        }



    }

    location /rest-api {
        alias /var/www/html/docroot/rest-api;
        try_files $uri $uri/ @rest-api;

        location ~ \.php$ {
            include fastcgi.conf;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
            fastcgi_pass php;
        }
    }

    location @rest-api {
        rewrite /rest-api/(.*)$ /rest-api/index.php?/$1 last;
    }

    location /ckan/api/2/search {
        alias /var/www/html/docroot/ckan/api/2/search;
        try_files $uri $uri/ @search;

        location ~ \.php$ {
            include fastcgi.conf;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
            fastcgi_pass php;
        }
    }

    location @search {
        rewrite /ckan/api/2/search/(.*)$ /ckan/api/2/search/index.php?/$1 last;
    }

    location /ckan/api/2/rest {
        alias /var/www/html/docroot/ckan/api/2/rest;
        try_files $uri $uri/ @rest;

        location ~ \.php$ {
            include fastcgi.conf;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
            fastcgi_pass php;
        }
    }

    location @rest {
        rewrite /ckan/api/2/rest/(.*)$ /ckan/api/2/rest/index.php?/$1 last;
    }

    location = /fileupload/index.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /fileupload/index.php;
        fastcgi_param SCRIPT_FILENAME $document_root/fileupload/index.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }


    location ~ [^/]\.php(/|$) {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_param SCRIPT_NAME /index.php;
        fastcgi_param SCRIPT_FILENAME $document_root/index.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
        track_uploads {{ getenv "NGINX_DRUPAL_TRACK_UPLOADS" "uploads 60s" }};
    }

    location = /index.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_param SCRIPT_NAME /index.php;
        fastcgi_param SCRIPT_FILENAME $document_root/index.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /home {
       index  index.html index.php;
       try_files $uri $uri/ /index.php$uri?$args;
    }


    location = /showme.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /showme.php;
        fastcgi_param SCRIPT_FILENAME $document_root/showme.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /acs.php {
       include fastcgi.conf;
       fastcgi_param QUERY_STRING $args;
       fastcgi_param SCRIPT_NAME /acs.php;
       fastcgi_param SCRIPT_FILENAME $document_root/acs.php;
       fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
       fastcgi_pass php;
    }


    location = /faq {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /faq.php;
        fastcgi_param SCRIPT_FILENAME $document_root/faq.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /submit {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /submit.php;
        fastcgi_param SCRIPT_FILENAME $document_root/submit.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /viewdata {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /viewdata.php;
        fastcgi_param SCRIPT_FILENAME $document_root/viewdata.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /about {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /about.php;
        fastcgi_param SCRIPT_FILENAME $document_root/about.php;
        fastcgi_pass php;
    }

    location = /acs {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /acs.php;
        fastcgi_param SCRIPT_FILENAME $document_root/acs.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /api {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /api.php;
        fastcgi_param SCRIPT_FILENAME $document_root/api.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /auth.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /auth.php;
        fastcgi_param SCRIPT_FILENAME $document_root/auth.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /f-login.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /f-login.php;
        fastcgi_param SCRIPT_FILENAME $document_root/f-login.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /curate {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /curate.php;
        fastcgi_param SCRIPT_FILENAME $document_root/curate.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /disclaimer {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /disclaimer.php;
        fastcgi_param SCRIPT_FILENAME $document_root/disclaimer.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /edit {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /edit.php;
        fastcgi_param SCRIPT_FILENAME $document_root/edit.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /error {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /error.php;
        fastcgi_param SCRIPT_FILENAME $document_root/error.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /notes {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /notes.php;
        fastcgi_param SCRIPT_FILENAME $document_root/notes.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /search {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /search.php;
        fastcgi_param SCRIPT_FILENAME $document_root/search.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /secure_dl {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /secure_dl.php;
        fastcgi_param SCRIPT_FILENAME $document_root/secure_dl.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /dl {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /dl.php;
        fastcgi_param SCRIPT_FILENAME $document_root/dl.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /stats {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /stats.php;
        fastcgi_param SCRIPT_FILENAME $document_root/stats.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /view.php {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /view.php;
        fastcgi_param SCRIPT_FILENAME $document_root/view.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }

    location = /test {
        include fastcgi.conf;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param SCRIPT_NAME /test.php;
        fastcgi_param SCRIPT_FILENAME $document_root/test.php;
        fastcgi_param WWW_NREL {{ getenv "WWW_NREL" "PROD" }};
        fastcgi_pass php;
    }


    location ^~ /.bzr {
        return 404;
    }

    location ^~ /.git {
        return 404;
    }

    location ^~ /.hg {
        return 404;
    }

    location ^~ /.svn {
        return 404;
    }

    location ^~ /.cvs {
        return 404;
    }

    location ^~ /patches {
        return 404;
    }

    location ^~ /backup {
        return 404;
    }

    location = /robots.txt {
        access_log {{ getenv "NGINX_STATIC_CONTENT_ACCESS_LOG" "off" }};
        try_files $uri @drupal-no-args;
    }

    location = /favicon.ico {
        expires {{ getenv "NGINX_STATIC_CONTENT_EXPIRES" "30d" }};
        try_files /favicon.ico @empty;
    }

    location ~* ^/.well-known/ {
        allow all;
    }

    location @empty {
        expires {{ getenv "NGINX_STATIC_CONTENT_EXPIRES" "30d" }};
        empty_gif;
    }

    location ~* ^.+\.php$ {
        return 404;
    }

    location ~ (?<upload_form_uri>.*)/x-progress-id:(?<upload_id>\d*) {
        rewrite ^ $upload_form_uri?X-Progress-ID=$upload_id;
    }

    location ~ ^/progress$ {
        upload_progress_json_output;
        report_uploads uploads;
    }

    include healthz.conf;
{{ if getenv "NGINX_SERVER_EXTRA_CONF_FILEPATH" }}
    include {{ getenv "NGINX_SERVER_EXTRA_CONF_FILEPATH" }};
{{ end }}
}
