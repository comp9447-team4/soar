#!/bin/bash
git clone https://github.com/theupdateframework/notary.git && cd notary
docker-compose up -d

sudo cp fixtures/root-ca.crt /etc/pki/tls/certs/notary-root-ca.crt

echo 'export DOCKER_CONTENT_TRUST_SERVER=https://localhost:4443' >> ~/.bashrc
echo 'export DOCKER_CONTENT_TRUST=1' >> ~/.bashrc
. ~/.bashrc
