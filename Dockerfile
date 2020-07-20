FROM starefossen/ruby-node:2-6-alpine as base

ENV GITHUB_GEM_VERSION 202
ENV JSON_GEM_VERSION 1.8.6

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
  && gem install --verbose --no-document \
    json:${JSON_GEM_VERSION} \
    github-pages:${GITHUB_GEM_VERSION} \
    jekyll-github-metadata \
    minitest \
  && apk del build_deps \
  && apk add git \
  && rm -rf /usr/lib/ruby/gems/*/cache/*.gem

RUN apk update \
    && apk add --no-cache \
        bash

FROM scratch as user
COPY --from=base . .

ARG HOST_UID=${HOST_UID:-4000}
ARG HOST_USER=${HOST_USER:-nodummy}

RUN [ "${HOST_USER}" == "root" ] || \
    (adduser -h /home/${HOST_USER} -D -u ${HOST_UID} ${HOST_USER} \
    && chown -R "${HOST_UID}:${HOST_UID}" /home/${HOST_USER})

USER ${HOST_USER}
RUN ln -s /home/${HOST_USER}/bitcoinwords.github.io /usr/src/app
WORKDIR /home/${HOST_USER}/bitcoinwords.github.io

EXPOSE 4000 80
CMD jekyll serve -d /home/${HOST_USER}/bitcoinwords.github.io/_site --watch --force_polling -H 0.0.0.0 -P 4000

