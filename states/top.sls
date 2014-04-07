base:
  '*':
    - users
    - sudo
    - git

  # target all minions with the salt-master role.
  'roles:salt-master':
    - match: grain
    - python.salt-cloud

