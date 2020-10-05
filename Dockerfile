ARG UBUNTU_VERSION=20.04
ARG SOURCE_DIR=/src/wok


FROM ubuntu:${UBUNTU_VERSION} AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y gcc make autoconf automake git python3-pip python3-requests python3-mock gettext pkgconf xsltproc python3-dev pep8 pyflakes python3-yaml \
  && pip3 install cython libsass pre-commit \
  && rm -rf /var/lib/apt/lists/*

ARG SOURCE_DIR
COPY . ${SOURCE_DIR}
WORKDIR ${SOURCE_DIR}

RUN ./autogen.sh --system && make && make deb && mv wok-*.ubuntu.noarch.deb wok.deb


FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y logrotate python3-psutil python3-ldap python3-lxml python3-websockify python3-jsonschema openssl nginx python3-cherrypy3 python3-cheetah python3-pam python3-m2crypto gettext python3-openssl \
  && rm -rf /var/lib/apt/lists/*

ARG SOURCE_DIR

COPY --from=builder ${SOURCE_DIR}/wok.deb /tmp/wok.deb

RUN dpkg -i /tmp/wok.deb && rm /tmp/wok.deb

ENTRYPOINT ["/usr/bin/wokd"]

EXPOSE 8001/tcp
