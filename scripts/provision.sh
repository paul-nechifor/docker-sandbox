#!/bin/bash

packages=(
  docker-io
  nodejs
)

install_packages() {
  yum -y update
  yum -y install ${packages[@]}
}

main() {
  install_packages
}

main "$@"
