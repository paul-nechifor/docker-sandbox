#!/bin/bash

packages=(
  docker-io
  nodejs
)

install_packages() {
  yum -y update
  yum -y install ${packages[@]}
}

setup_docker() {
  service docker start # Start Docker.
  chkconfig docker on # Start Docker on reboot.
  docker pull centos:6.6 # Pull CentOS 6.6
  gpasswd -a vagrant docker # User docker without root for vagrant.
}

main() {
  install_packages
  setup_docker
}

main "$@"
