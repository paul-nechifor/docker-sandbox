#!/bin/bash -eux

name=docker-sandbox
user=developer-svc
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

packages=(
  docker-io
  nodejs
  npm
)

main() {
  if [[ $(id -u vagrant) ]]; then
    user=vagrant
    root="/vagrant"
  fi
  install_packages
  setup_docker
  setup_service
}

install_packages() {
  # Install EPEL.
  cd /tmp
  local file="epel-release-6-8.noarch.rpm"
  wget -q "http://dl.fedoraproject.org/pub/epel/6/x86_64/$file"
  rpm -Uvh "$file" >/dev/null 2>&1 || true
  rm "$file"

  yum -y shell <<<"
    update
    install ${packages[@]}
    groupinstall 'Development tools'
    run
  "
}

setup_docker() {
  service docker start # Start Docker.
  chkconfig docker on # Start Docker on reboot.
  docker pull centos:6.6 # Pull CentOS 6.6
  gpasswd -a vagrant docker # User docker without root for vagrant.
}

setup_service() {
  id -u $user 2>/dev/null || adduser $user
  [[ -d /data/$name ]] || mkdir -p /data/$name
  [[ -d /var/log/$name ]] || mkdir -p /var/log/$name
  [[ -d /var/run/$name ]] || mkdir -p /var/run/$name
  chown $user:$user /data/$name /var/log/$name /var/run/$name

  su $user -c "cd $root; ./scripts/bootstrap"
  cp "$root/scripts/service" /etc/init.d/docker-sandbox
  chkconfig --add docker-sandbox
  service docker-sandbox start
}

main
