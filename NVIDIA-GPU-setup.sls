# setup NVIDIA GK110BGL [Tesla K40m] on Boole GPU nodes

# ensure this state only runs on a node with the gpu installed in it
{% if salt['grains.get']('gpus:model') == 'GK110BGL [Tesla K40m]' %}

ensure base packages are installed:
  pkg:
    - installed
    - skip_suggestions: True 
    - pkgs:
      - gcc
      - gcc-c++
      - dkms
      - mesa-libGLU-devel
      - libXmu-devel
      - libXi-devel
#      - kernel-tools-{{ salt['pillar.get']('kernel_version') }}
#      - kernel-tools-libs-{{ salt['pillar.get']('kernel_version') }}


install kernel dependencies (cmd):
  cmd:
    - run
    - name: yum -y install kernel-tools-{{ salt['pillar.get']('kernel_version') }} kernel-tools-libs-{{ salt['pillar.get']('kernel_version') }}

# the nouveu modules need to be removed from the kernel
/etc/modprobe.d/blacklist-nouveau.conf:
  file.managed:
    - source: salt://clusters/nodes/gpu-boole/blacklist-nouveau.conf
    - mode: 644
    - user: root
    - group: root

{% if grains.get('regenerate_ramdisk') != 'regenerated' %}

# ramdisk needs to be re-generated without the nouveu modules and node booted from it
create ramdisk without the nouveau modules:
  cmd.run:
    - name: dracut --force

regenerate_ramdisk:
  module.run:
    - name: grains.setval
    - key: regenerate_ramdisk
    - val: 'regenerated'

{% if pillar['reboot'] != 'yes' %}
always-fails ramdisk:
  test.fail_without_changes: # this is really supported only from Salt 2014.7
    - name: MESSAGE - the minion should reboot before continuing; either reboot manually or run the state passing the reboot pillar as an argument
    - failhard: True
{% endif %} # end if pillar['reboot'] != 'yes' %}

system.reboot ramdisk:
  module:
    - name: system.reboot
    - run
    - require:
      - module: regenerate_ramdisk

stops after ramdisk reboot:
  test.fail_without_changes:
    - name: MESSAGE - system rebooting
    - failhard: True
    - require:
      - module: system.reboot ramdisk

{% endif %} # ramdisk regeneration ends

{% if grains.get('nvidia_drivers_version') != '9.1.85' %}
# old version was 9.0.176

Remove old drivers if installed:
  cmd.run:
    - name: /usr/bin/nvidia-uninstall --silent
    - unless: test ! -e /usr/bin/nvidia-uninstall

Install CUDA 9.0.176:
  cmd.run:
#    - name: /home/support/root/gpu/cuda_9.0.176_384.81_linux-run --silent # Oct 2017 updated version
    - name: /home/support/root/gpu/cuda_9.1.85_387.26_linux.run --silent # Jan 2018 updated version

## following being retired in favour of the above
#Install CUDA 8.0.61:
#  cmd.run:
#    - name: /home/support/root/gpu/cuda_8.0.61_375.26_linux.run --silent # July 2017 updated version
   
#Patch CUDA to 8.0.61.2:
#  cmd.run:
#    - name: /home/support/root/gpu/cuda_8.0.61.2_linux.run --silent --accept-eula

{% if pillar['reboot'] != 'yes' %}
always-fails nvidia_drivers_version:
  test.fail_without_changes: # this is really supported only from Salt 2014.7
    - name: MESSAGE - the minion should reboot before continuing; either reboot manually or run the state passing the reboot pillar as an argument
    - failhard: True
{% endif %} # end if pillar['reboot'] != 'yes' %}

system.reboot nvidia_drivers_version:
  module:
    - name: system.reboot
    - run
    - require:
      - module: nvidia_drivers_version

stops after nvidia drivers reboot:
  test.fail_without_changes:
    - name: MESSAGE - system rebooting
    - failhard: True
    - require:
      - module: system.reboot nvidia_drivers_version

nvidia_drivers_version:
  module.run:
    - name: grains.setval
    - key: nvidia_drivers_version
    - val: '9.1.85'
#    - val: '9.0.176'

{% endif %} # ends driver install

# {% if grains.get('tesla_drivers') != 'installed' %}
# Sean, commenting out 20170705, since a recent version of the
# drivers is included in the CUDA package
#Install Nvidia drivers:
#  cmd.run:
#    - name: /home/support/root/gpu/NVIDIA-Linux-x86_64-375.20.run --silent

#tesla_drivers:
#  module.run:
#    - name: grains.setval
#    - key: tesla_drivers
#    - val: 'installed'

# {% endif %} # ends tesla drivers install

{% endif %} # ends check to make sure this only runs on machines with GPU's in them
