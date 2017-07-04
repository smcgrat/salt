cgroup packages:
  pkg:
    - installed
    - pkgs:
      - libcgroup
      - libcgroup-pam

/etc/pam.d/login:
  file.append:
    - text:
      - "session    required    pam_cgroup.so"

/etc/pam.d/password-auth-ac:
  file.append:
    - text:
      - "session    required    pam_cgroup.so"

/etc/pam.d/system-auth-ac:
  file.append:
    - text:
      - "session     required      pam_cgroup.so"

/etc/cgconfig.conf:
  file.append:
    - text: | 
        group users {
            memory {
              memory.limit_in_bytes="4G";
              memory.memsw.limit_in_bytes="6G";
          }
          cpuset {
            cpuset.mems="0-1";
            cpuset.cpus="0-2";
          }
        }

/etc/cgrules.conf:
  file.append:
    - text: |
        root    *      /
        *   cpuset,memory    users

cgroup service:
  service:
    - name: cgconfig
    - running
    - enable: True
