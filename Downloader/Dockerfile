FROM alpine:latest
ENV NOMAD_VERSION=1.3.1
ENV WAYPOINT_VERSION=0.8.2
RUN apk add --no-cache unzip curl dumb-init openssl git

RUN mkdir /dl
WORKDIR /dl
#ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_linux_amd64.zip
#ADD https://releases.hashicorp.com/waypoint/${WAYPOINT_VERSION}/waypoint_${WAYPOINT_VERSION}_linux_amd64.zip waypoint_${WAYPOINT_VERSION}_linux_amd64.zip

RUN set -x; curl https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad_${NOMAD_VERSION}_linux_amd64.zip && \
  unzip nomad_${NOMAD_VERSION}_linux_amd64.zip  && \
  rm -v nomad_${NOMAD_VERSION}_linux_amd64.zip  && \
  chmod +x nomad && \
  git clone --depth=1 https://github.com/hashicorp/waypoint-examples.git && \
  curl https://releases.hashicorp.com/waypoint/${WAYPOINT_VERSION}/waypoint_${WAYPOINT_VERSION}_linux_amd64.zip -o waypoint_${WAYPOINT_VERSION}_linux_amd64.zip && \
  unzip waypoint_${WAYPOINT_VERSION}_linux_amd64.zip && \
  rm -v waypoint_${WAYPOINT_VERSION}_linux_amd64.zip && \
  chmod +x waypoint && \
  ls -alh

COPY start.sh /start.sh
CMD "/start.sh"
