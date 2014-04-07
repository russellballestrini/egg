# For details go to:
# http://russell.ballestrini.net/understanding-salt-stack-user-and-group-management/

{% for username, user in pillar.get('users', {}).items() %}
{{ username }}:

  group:
    - present
    - name: {{ username }}
    - gid: {{ user['gid'] }}

  user:
    - present
    - fullname: {{ user['fullname'] }}
    - name: {{ username }}
    - shell: /bin/bash
    - home: /home/{{ username }}
    - uid: {{ user['uid'] }}
    - gid: {{ user['gid'] }}
    {% if 'groups' in user %}
    - groups:
      {% for group in user['groups'] %}
      - {{ group }}
      {% endfor %}
    - require:
      {% for group in user['groups'] %}
      - group: {{ group }}
      {% endfor %}
    {% endif %}

  {% if 'pub_ssh_keys' in user %}
  ssh_auth:
    - present
    - user: {{ username }}
    - names:
    {% for pub_ssh_key in user['pub_ssh_keys'] %}
      - {{ pub_ssh_key }}
    {% endfor %}
    - require:
      - user: {{ username }}
  {% endif %}

{% endfor %}
