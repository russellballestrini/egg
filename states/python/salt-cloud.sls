python-salt-cloud:
  pip.installed:
    - name: salt-cloud
    - require:
      - pip: python-libcloud
