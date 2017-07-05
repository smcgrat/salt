# Vivo installation for evaluation purposes
# setup as per: https://wiki.duraspace.org/display/VIVO/A+simple+installation

include:
  - tchpc-general.vivo.bootstrap
  - tchpc-general.vivo.shorewall # this machine has specific rules so managing those from here instead of the general state

# root env stuff
/root/bin:
  file.directory:
	- user: root
	- group: root
	- makedirs: True

/root/backup/logs:
  file.directory:
	- user: root
	- group: root
	- mode: 700
	- makedirs: True

mysql packages:
  pkg:
	- installed
	- pkgs: 
	  - mariadb # installs ver 5.5, rhel7 has switched to mariadb instead of mysql, apparently they're the same things
	  - mariadb-server # installs ver 5.5

mysql service:
  service:
	- name: mariadb
	- running 
	- enable: True

/root/.my.cnf:
  file.managed:
	- source: salt://tchpc-general/vivo/.my.cnf
	- mode: 600
	- user: root
	- group: root

/root/bin/securemysql.sh:
  file.managed:
	- source: salt://tchpc-general/vivo/securemysql.sh
	- mode: 700
	- user: root

# note the following contains the mysql root password so be careful with this
Secure mysql installation (mysql_secure_installation):
  cmd:
	- wait
	- name: /root/bin/securemysql.sh snip
	- watch:
	  - pkg: mysql packages

/root/bin/createvivodb.sh:
  file.managed:
	- source: salt://tchpc-general/vivo/createvivodb.sh
	- mode: 700
	- user: root

/root/backup/mysql:
  file.directory:
	- user: root
	- group: root
	- makdedirs: True
	- mode: 700

# contains the password so be careful
Create vivo database:
  cmd: 
	- wait
	- name: createvivodb.sh snip
	- watch:
	  - pkg: mysql packages

/root/bin/backupvivolocally.sh:
  file.managed:
	- source: salt://tchpc-general/vivo/backupvivolocally.sh
	- mode: 700
	- user: root

/etc/cron.daily/localbackup:
  file.symlink:
	- name: /etc/cron.daily/localbackup
	- target: /root/bin/backupvivolocally.sh

install dependencies:
  pkg:
	- installed
	- pkgs:
	  - tomcat # intsalls Tomcat 7
	  - ant # installs apache ant 1.9
	  - duplicity

java:
  pkg.installed:
	- sources: # http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
	  - jre1.8.0_73: salt://tchpc-general/vivo/jre-8u73-linux-x64.rpm
	  - jdk1.8.0_74: salt://tchpc-general/vivo/jdk-8u74-linux-x64.rpm

vivo:
  group.present

/usr/local/vivo/home:
  file.directory:
	- user: root
	- group: tomcat
	- makedirs: True
	- mode: 775

/usr/local/vivo/home/solr/:
  file.directory:
	- user: root
	- group: tomcat
	- makedirs: True
	- mode: 775

vivo server download:
  archive.extracted:
	- name: /usr/local/tomcat/
	- source: https://github.com/vivo-project/VIVO/releases/download/rel-1.8.1/vivo-rel-1.8.1.zip
	- archive_format: zip
	- source_hash: md5=142efe1fabd426c6e8b657c33fff97c0


/usr/local/tomcat/vivo-rel-1.8.1/origional.build.properties:
  file.managed:
	- source: salt://tchpc-general/vivo/origional.build.properties
	- mode: 644
	- user: root

/usr/local/tomcat/vivo-rel-1.8.1/build.properties:
  file.managed:
	- source: salt://tchpc-general/vivo/build.properties
	- mode: 644
	- user: root

Compile Vivo:
  cmd.wait:
	- name: ant all
	- cwd: /usr/local/tomcat/vivo-rel-1.8.1/
	- watch:
	  - file: /usr/local/tomcat/vivo-rel-1.8.1/build.properties

/usr/share/tomcat/bin/setenv.sh:
  file.managed:
	- source: salt://tchpc-general/vivo/setenv.sh
	- mode: 755
	- user: root

/etc/security/limits.conf:
  file.managed:
	- source: salt://tchpc-general/vivo/limits.conf
	- mode: 755
	- user: root

/usr/share/tomcat/conf/server.xml:
  file.managed:
	- source: salt://tchpc-general/vivo/server.xml
	- mode: 664
	- user: root
	- group: tomcat

/usr/local/vivo/home/config/applicationSetup.n3:
  file.managed:
	- source: salt://tchpc-general/vivo/applicationSetup.n3
	- mode: 644
	- user: root
	- group: root

/usr/local/vivo/home/runtime.properties:
  file.managed:
	- source: salt://tchpc-general/vivo/runtime.properties
	- mode: 644
	- user: root
	- group: root

tomcat service:
  service:
	- name: tomcat
	- running
	- enable: True
