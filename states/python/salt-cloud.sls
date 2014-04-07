python salt-cloud package:
  pip.installed:
    - name: salt-cloud
    - require:
      - pkg: python libcloud package
