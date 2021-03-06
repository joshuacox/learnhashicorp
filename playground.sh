#!/bin/bash
: ${NOMAD_VERSION:=1.3.1}
: ${WAYPOINT_VERSION:=0.8.2}

mkdir dl bin
cd dl
cat > Dockerfile << EOF
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
EOF

cat > start.sh << EOF
#!/bin/sh
while true
do
  echo sleep
  sleep 100
done
EOF
chmod +x start.sh

docker build -t downloader .
docker run -d --name downloader downloader:latest
docker cp downloader:/dl/nomad ~/bin/
docker cp downloader:/dl/waypoint ~/bin/
docker cp downloader:/dl/waypoint-examples ~/

IFACE=eth0
mkdir -p /data/waypoint-server
chown 100 /data/waypoint-server

cat > nomad.config << EOF
client {
  host_volume "waypoint-server" {
    path = "/data/waypoint-server"
    read_only = false
  }
}
EOF

nomad agent \
	-dev \
	-network-interface=$IFACE \
	-config=nomad.config 1>/tmp/nomad.stdout 2>/tmp/nomad.stderr &

THIS_RESULT=1
THIS_COUNT=0
echo -n 'Awaiting nomad to start.'
until [[ $THIS_RESULT == 0 ]];
do
  nomad status &> /dev/null
  THIS_RESULT=$?
  echo -n $THIS_RESULT
  sleep 2
  ((++THIS_COUNT))
done
echo "# $THIS_COUNT"

echo 'Now starting waypoint'
time waypoint install \
	-platform=nomad \
	-accept-tos \
	-nomad-host-volume=waypoint-server \
	-nomad-consul-service=false

cd ~/waypoint-examples/nomad/nodejs
waypoint init
waypoint up
