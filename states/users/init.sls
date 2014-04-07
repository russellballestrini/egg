# For details go to:
# http://russell.ballestrini.net/understanding-salt-stack-user-and-group-management/

{% for username, details in pillar.get('users', {}).items() %}
{{ username }}:

  group:
    - present
    - name: {{ username }}
    - gid: {{ details.get('gid', '') }}

  user:
    - present
    - fullname: {{ details.get('fullname','') }}
    - name: {{ username }}
    - shell: /bin/bash
    - home: /home/{{ username }}
    - uid: {{ details.get('uid', '') }}
    - gid: {{ detials.get('gid', '') }}
    - crypt: {{ details.get('crypt','') }}
    {% if 'groups' in details %}
    - groups:
      {% for group in details.get('groups', []) %}
      - {{ group }}
      {% endfor %}
    - require:
      {% for group in details.get('groups', []) %}
      - group: {{ group }}
      {% endfor %}
    {% endif %}

  {% if 'pub_ssh_keys' in details %}
  ssh_auth:
    - present
    - user: {{ username }}
    - names:
    {% for pub_ssh_key in details.get('pub_ssh_keys', []) %}
      - {{ pub_ssh_key }}
    {% endfor %}
    - require:
      - user: {{ username }}
  {% endif %}

{% endfor %}
