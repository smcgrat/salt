# ensure yum-cron is properly configured
{% if grains['osfinger'] == 'Scientific Linux-7' %}

install yum-cron package:
  pkg:
    - installed
    - skip_suggestions: True
    - pkgs:
      - yum-cron

yum-cron messages:
  file:
    - replace
    - name: /etc/yum/yum-cron.conf  
    - pattern: "update_messages = no"
    - repl: "update_messages = yes" 

yum-cron download:
  file:
    - replace
    - name: /etc/yum/yum-cron.conf
    - pattern: "download_updates = no"
    - repl: "download_updates = yes"

yum-cron apply:
  file:
    - replace
    - name: /etc/yum/yum-cron.conf
    - pattern: "apply_updates = no"
    - repl: "apply_updates = yes"

yum-cron-hourly command:
  file:
    - replace
    - name: /etc/yum/yum-cron-hourly.conf
    - pattern: "update_cmd = default"
    - repl: "update_cmd = security"

yum-cron-hourly messages:
  file:
    - replace
    - name: /etc/yum/yum-cron-hourly.conf
    - pattern: "update_messages = no"
    - repl: "update_messages = yes"

yum-cron-hourly download:
  file:
    - replace
    - name: /etc/yum/yum-cron-hourly.conf
    - pattern: "download_updates = no"
    - repl: "download_updates = yes"

yum-cron-hourly apply:
  file:
    - replace
    - name: /etc/yum/yum-cron-hourly.conf
    - pattern: "apply_updates = no"
    - repl: "apply_updates = yes"

enable yum-cron service:
  service:
    - name: yum-cron
    - running
    - enable: True # start at runtime
    - watch:
      - file: /etc/yum/yum-cron.conf
      - file: /etc/yum/yum-cron-hourly.conf


{% endif %}
