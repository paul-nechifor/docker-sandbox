#!/bin/bash -eux

root=$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)
name="docker-sandbox"

main() {
  bash "$root/scripts/provision.sh"
  sudo -u vagrant bash -c "
    rsync -a '$root/' '/data/$name/'
    cd '/data/$name'
    ./scripts/bootstrap
  "
  cp "$root/scripts/service" /etc/init.d/$name
  chkconfig --add $name
  chkconfig $name on
  service $name start
}

main
