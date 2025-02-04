#!/bin/env bash

export ISTIO_VERSION=1.24.2
curl -L https://istio.io/downloadIstio | sh -
ln -s ./istio-$ISTIO_VERSION ./istio
cp ./istio/bin/* /usr/local/bin

istioctl install --set profile=ambient -y
