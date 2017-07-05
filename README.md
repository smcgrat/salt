# salt

Salt References

cheatsheets: 
- http://www.xenuser.org/saltstack-cheat-sheet/ 
- https://github.com/saltstack/salt/wiki/Cheat-Sheet
- https://blog.talpor.com/2014/07/saltstack-beginners-tutorial/

**Command Line examples**

Call a specific state from a node: `salt-call state.sls general.set_authorized_keys`

Increase debug level: `salt-call -l debug state.apply`

salt key:
```
$ salt-key -L # list keys on master
$ salt-key -A # accept all pending keys, unsecure
$ salt-key -f minion-id # get fingerprint of key from minion-id
$ salt-key -a minion-id.domain.com # accept key for that minion
```

Return all a minions grains, (information about the underlying system known to the minion):
- Remotely, from the master: `salt minion.fqdn grains.items`
- Locally, from the minion: `salt-call -g`

Running a salt command from the master on certain minions based on a grain: 
`salt -G 'osfinger:Scientific Linux-7' state.sls general.autoupdate`

Find out where samba is running: 
`salt '*.tchpc.tcd.ie' cmd.run 'service smb status > /dev/null 2>&1 && if [ "$?" == "0" ]; then me=$(hostname -s); echo "samba is running on $me"; fi'`

Targets can be filtered by regular expression: `salt -E 'virtmach[0-9]' test.ping`

Targets can be explicitly specified in a list: `salt -L 'foo,bar,baz,quo' test.ping`

Or Multiple target types can be combined in one command: `salt -C 'G@os:Ubuntu and webser* or E@database.*' test.ping`

A dry or test run can be done as follows: 
```
salt hprc-guest038.tchpc.tcd.ie state.highstate test=True # from the master
salt-call state.highstate test=True # from the minion
```

To call a highstate from a node with the reboot flag set: `salt-call state.highstate pillar='{"reboot": "yes"}'`

**Code Blocks and snippets from state files that can't go anywhere else**

Find and replace in a file:
```
file:
   - replace
   - name: /etc/fstab
   - pattern: "boole01.ib:/home /home nfs rw,rsize=8192,wsize=8192,soft,intr,defaults,rdma,port=2050 0 0 /home nfs rw,rsize=8192,wsize=8192,soft,intr,defaults 0 0"
   - repl: "boole01.ib:/home /home nfs rw,rsize=8192,wsize=8192,soft,intr,defaults,rdma,port=2050 0 0"
```

Differentiating via a grain based on the hardware in a minion:
```
[root@service01:/srv/salt/clusters/nodes/gpu-boole]# git diff de90ab58d35afcf8afae68967f9c44ad8ce61701 05c8aa77fdbaac42356f5ab357928e98693e528b
diff --git a/salt/clusters/nodes/gpu-boole/init.sls b/salt/clusters/nodes/gpu-boole/init.sls
index be25487..8e8d7b9 100644
--- a/salt/clusters/nodes/gpu-boole/init.sls
+++ b/salt/clusters/nodes/gpu-boole/init.sls
@@ -1,5 +1,7 @@
# setup NVIDIA GK110BGL [Tesla K40m] on Boole GPU nodes

+{% if salt['grains.get']('gpus:model') == 'GK110BGL [Tesla K40m]' %}
+
# the nouveu modules need to be removed from the kernel
/etc/modprobe.d/blacklist-nouveau.conf:
file.managed:
@@ -71,3 +73,5 @@ stops after nvidia drivers reboot:
   - module: system.reboot nvidia_drivers
     
{% endif %}
+
+{% endif %}```

Differentiating based on OS type:
```{% if grains['osfinger'] == 'Scientific Linux-6' -%}
- pam_ldap
{% elif grains['osfinger'] == 'Scientific Linux-7' -%}
- nss-pam-ldapd
{% endif %}
```

differentiating for with Ubuntu:
```
{% if grains['osfullname'] == 'Ubuntu' %}
{% endif %}
{% if grains['osfullname'] != 'Ubuntu' %}
{% endif %}
{% if grains['osfinger'] == 'Ubuntu-14.04' %}
{% elif grains['osfinger'] == 'Ubuntu-16.04' %}
{% endif %}
```

differentiating based on hostname:
```
{% if not grains['id'][:4]=='name' %}
{% endif %}

{% if grains['host'] in ['host1', 'host2'] %}
{% endif %}

```

Including other states in a state
```
include:
  - path.to.state # dots used instead of slashes for paths
```

Package installation:
```
install packages that we want on every computer:
  pkg:
    - installed
    - skip_suggestions: True #Force strict package naming. Disables lookup of package alternatives
    - pkgs:
      - iotop
      - screen
```

Install specific versions on specific node by editing pillar variables. Set the pillar to the updated versions for your test node:
```
# testing upgraded versions on specific nodes:
{% if salt['grains.get']('id')[0:11]=='kelvin-n038' %}
gpfs_version: 3.5.0-32
{% else %}
gpfs_version: 3.5.0-29
{% endif %}
{% if salt['grains.get']('id')[0:11]=='kelvin-n038' %}
kernel_version: 2.6.32-642.3.1.el6.x86_64
{% else %}
kernel_version: 2.6.32-573.12.1.el6.x86_64
{% endif %}
```

Install the relevant kernel version, (pillar variable) for the node, (identified by grain):
```
{% if grains['kernelrelease'] != salt['pillar.get']('kernel_version') %}
install kernel packages (cmd):
  cmd:
    - run
    - name: yum -y install kernel-headers-{{ salt['pillar.get']('kernel_version') }} kernel-{{ salt['pillar.get']('kernel_version') }} kernel-devel-{{ salt['pillar.get']('kernel_version') }}
```
