# manage salt-cloud.

salt-cloud-apache-libcloud:
  pip.installed:
    - name: apache-libcloud
    - require:
      - pkg: python-pip

salt-cloud:
  pip.installed:
    - name: salt-cloud
    - require:
      - pip: salt-cloud-apache-libcloud

# salt-cloud main configuration file
salt-cloud-conf:
  file.managed:
    - name: /etc/salt/cloud
    - source: salt://salt-cloud/cloud
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - pip: salt-cloud

# salt-cloud provider configuration file
salt-cloud-providers-conf:
  file.managed:
    - name: /etc/salt/cloud.profiles
    - source: salt://salt-cloud/cloud.providers
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - pip: salt-cloud

# salt-cloud profiles configuration file
salt-cloud-profiles-conf:
  file.managed:
    - name: /etc/salt/cloud.profiles
    - source: salt://salt-cloud/cloud.profiles
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - pip: salt-cloud
