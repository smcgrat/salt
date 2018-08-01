# Update all the things!

{% if grains['os'] == 'ScientificLinux' %}

{% if salt['grains.get']('domain') == 'cluster' %}
# cluster nodes need some packages excluded and their kernel versions are being controlled elsewhere

update cluster nodes:
  cmd.run:
    - name: yum upgrade --exclude="kernel* openafs* *-kmdl-* kmod-* *firmware*" -y

# otherwise update all the things
{% else %}

pkg.upgrade:
  module.run:
    - refresh: True

# reboot if told to, otherwise this will have to be done manually
{% if pillar['reboot'] == 'yes' %}

system.reboot updates:
  module:
    - name: system.reboot
    - run
    - require:
      - module: pkg.upgrade

stops after updates reboot:
  test.fail_without_changes:
    - name: MESSAGE - system rebooting
    - failhard: True
    - require:
      - module: system.reboot updates

{% endif %} # end if pillar['reboot'] == 'yes' %}

{% endif %} # end of cluster if

{% endif %} # end of os ScientificLinux if
