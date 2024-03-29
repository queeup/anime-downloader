FROM python:3-alpine AS base

FROM base AS builder

ARG VERSION=5.0.9

RUN apk --no-cache add gcc musl-dev &&\
  pip install --no-cache-dir \
              --no-compile \
              --prefix=/build \
              --no-warn-script-location \
              --disable-pip-version-check \
              anime-downloader==${VERSION} &&\
    find /build -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +;

FROM base

COPY --from=builder /build /usr/local
RUN apk --no-cache add aria2 &&\
    mkdir /config /root/.config /root/.cache &&\
    ln -s /config /root/.config/anime-downloader &&\
    ln -s /config /root/.config/aria2 &&\
    ln -s /config /root/.cache/aria2

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

VOLUME /config /downloads

WORKDIR /downloads

ENTRYPOINT ["anime"]
