# -*- mode: ruby -*-
# vi: set ft=ruby :

INSTANCES=2

PROVISION_PUPPET = <<PUPPET
/bin/rpm -ivh http://yum.puppetlabs.com/puppet6/puppet6-release-el-7.noarch.rpm
/usr/bin/yum -y install puppet-agent
echo '*' > /etc/puppetlabs/puppet/autosign.conf
/opt/puppetlabs/bin/puppet resource host puppet.choria ensure=present ip=192.168.90.5 host_aliases=puppet
mkdir -p /etc/puppetlabs/facter/facts.d
echo "role=${1}" > /etc/puppetlabs/facter/facts.d/role.txt
PUPPET

Vagrant.configure("2") do |config|
  config.vm.define :puppet do |vmconfig|
    vmconfig.vm.box = "centos/7"
    vmconfig.vm.box_version = "1804.02"
    vmconfig.vm.hostname = "puppet.choria"
    vmconfig.vm.network :private_network, ip: "192.168.90.5"
    vmconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 3072]
    end

    vmconfig.vm.provision :shell do |s|
      s.inline = PROVISION_PUPPET
      s.args = "puppetserver"
    end

    vmconfig.vm.provision :shell do |s|
      s.inline = "bash /vagrant/analytics.sh >/dev/null 2>&1 || /usr/bin/true"
    end

    vmconfig.vm.provision "puppet" do |puppet|
      puppet.environment_path = "environments"
    end

    vmconfig.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "puppet.choria"
      puppet.options = "--waitforcert 10 --test"
    end
  end

  INSTANCES.times do |i|
    config.vm.define "instance#{i}" do |vmconfig|
      vmconfig.vm.box = "centos/7"
    vmconfig.vm.box_version = "1804.02"
      vmconfig.vm.hostname = "choria%s.choria" % i
      vmconfig.vm.network :private_network, ip: "192.168.90.%d" % (9+i)
      vmconfig.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", 1024]
      end
  
      vmconfig.vm.provision :shell do |s|
        s.inline = PROVISION_PUPPET
        s.args = "managed"
      end
  
      vmconfig.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "puppet.choria"
        puppet.options = "--waitforcert 10 --test"
      end
    end
  end
end
