# Описываем Виртуальные машины
MACHINES = {
  :"Centos8-for-RAID" => {
    :box_name => "centos/stream8",
    :box_version => "20210210.0",
    :cpus => 2,
    :memory => 1024,
    :disks => {
      :sata1 => {
        :dfile => './tmp/sata1.vdi',
        :size => 250,
        :port => 1
      },
      :sata2 => {
        :dfile => './tmp/sata2.vdi',
        :size => 250, # Megabytes
        :port => 2
      },
      :sata3 => {
        :dfile => './tmp/sata3.vdi',
        :size => 250,
        :port => 3
      },
      :sata4 => {
        :dfile => './tmp/sata4.vdi',
        :size => 250,
        :port => 4
      },
      :sata6 => {
       :dfile => './tmp/sata6.vdi',
       :size => 250,
       :port => 6
      }
    }
  }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.box_version = boxconfig[:box_version]
      box.vm.host_name = boxname.to_s
      box.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "1024"]
        needsController = false
        boxconfig[:disks].each do |dname, dconf|
          unless File.exist?(dconf[:dfile])
            v.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
            needsController =  true
          end 
        end 
        if needsController == true
          v.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
          boxconfig[:disks].each do |dname, dconf|
            v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
          end
        end
      end
      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
        yum install -y mdadm smartmontools hdparm gdisk
      SHELL
    end
  end
end