salt-cloud:

  # public IP address or FQDN of salt-master.
  master: 

  # path to private SSH key associated with provider APIs
  ssh_key_file_path: /path/to/private/salt-cloud-rsa.key

  # name of public SSH key associated with provider APIs
  ssh_key_name: salt-cloud.pub

  providers:
    do:
      provider_name: digital_ocean
      client_key: xxxx
      api_key: yyyy
