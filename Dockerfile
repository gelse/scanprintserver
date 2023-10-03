FROM debian:12-slim as insaned-build
ENV APP_DIR=/app
ENV PACKAGE_DIR=/deploy
WORKDIR "$APP_DIR"

RUN apt-get update \
&& apt-get upgrade -y
RUN apt-get install -y \
  libsane-dev \
  git \
  build-essential \
  debhelper \
  libjq1 \
  curl \
  jq

RUN git clone https://gitlab.com/xeijin-dev/insaned.git 
RUN cd $APP_DIR/insaned \
  && make debian 

FROM debian:12-slim as insaned
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    libjq1 \
    curl \
    jq \
    libsane \
    libsane1 \
  && rm -rf /var/lib/apt/lists/*

ENV APP_DIR=/app
WORKDIR "$APP_DIR"
COPY --from=insaned-build "$APP_DIR/*.deb" "$APP_DIR/"
RUN dpkg -i insaned_*.deb

COPY config.env /etc/insaned/events/.env
ENTRYPOINT ["insaned", "--dont-fork"]
CMD ["-v"]
