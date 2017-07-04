install git and etckeeper:
  pkg:
    - installed
    - skip_suggestions: True 
    - refresh: True
    - pkgs:
      - git
      - etckeeper
  file.replace:
    - name: /etc/etckeeper/etckeeper.conf
    - pattern: '^"VCS=bzr"'
    - repl: '"VCS=git"'
  cmd:
    - run
    - name: /usr/bin/etckeeper init creates=/etc/.git/config; /usr/bin/etckeeper commit "First commit by Salt, saving state."; /usr/bin/git --git-dir=/etc/.git --work-tree=/etc gc
    - unless: ls -d /etc/.git
