# setup NVIDIA GK110BGL [Tesla K40m] on Boole GPU nodes

# the nouveu modules need to be removed from the kernel
/etc/modprobe.d/blacklist-nouveau.conf:
  file.managed:
    - source: salt://clusters/nodes/gpu-boole/blacklist-nouveau.conf
    - mode: 644
    - user: root
    - group: root

{% if pillar['reboot'] != 'yes' %}
always-fails ib:
  test.fail_without_changes: # this is really supported only from Salt 2014.7
    - name: MESSAGE - the minion should reboot before continuing; either reboot manually or run the state passing the reboot pillar as an argument
    - failhard: True
{% endif %} # end if pillar['reboot'] != 'yes' %}

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

system.reboot ramdisk:
  module:
    - name: system.reboot
    - run
    - require:
      - module: regenerate_ramdisk

stops after ramdisk reboot:
  test.fail_without_changes: # this is really supported only from Salt 2014.7
    - name: MESSAGE - system rebooting
    - failhard: True
    - require:
      - module: system.reboot ramdisk

{% endif %}

{% if grains.get('nvidia_drivers') != 'installed' %}

Install Nvidia drivers:
  cmd.run:
    - name: /home/support/root/gpu/cuda_7.5.18_linux.run --silent

nvidia_drivers:
  module.run:
    - name: grains.setval
    - key: nvidia_drivers
    - val: 'installed'

system.reboot nvidia_drivers:
  module:
    - name: system.reboot
    - run
    - require:
    - module: nvidia_drivers

stops after nvidia drivers reboot:
  test.fail_without_changes: # this is really supported only from Salt 2014.7
    - name: MESSAGE - system rebooting
    - failhard: True
    - require:
      - module: system.reboot nvidia_drivers

{% endif %}