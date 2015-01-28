Vagrant.configure('2') do |config|
  config.vm.box = 'centos-6.6'
  config.vm.host_name = 'box'
  config.vm.provision 'shell', path: 'scripts/provision.sh'
end
