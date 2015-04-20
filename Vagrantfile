required_plugins = %w( vagrant-proxyconf vagrant-cachier )
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure('2') do |config|
  config.proxy.http = ENV['http_proxy']
  config.proxy.https = ENV['https_proxy']
  config.ssh.insert_key = false
  config.vm.box = 'chef/centos-6.6'
  config.vm.network 'private_network', ip: '172.16.10.22'
  config.vm.provision 'shell', path: 'scripts/provision.sh'
end
