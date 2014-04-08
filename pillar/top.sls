base:
  '*':
    - users

  # target all minions with the salt-master role.
  'roles:salt-master':
    - match: grain
    - salt-cloud

