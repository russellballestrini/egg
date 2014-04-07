python-libcloud:
  pip.installed:
    - name: apache-libcloud
    - require:
      - pkg: python-pip
