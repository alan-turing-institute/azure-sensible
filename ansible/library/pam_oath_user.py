#!/usr/bin/python

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: pam_oath_user

short_description: Configure users for the OATH PAM module

version_added: "1.0.0"

description:
    - Currently only supports HOTP/T30/6 (time based token of 6 characters with
      a 30 second window)
      - Does not support PINS
        (https://code.google.com/archive/p/mod-authn-otp/wikis/UsersFile.wiki)

options:
    name:
        description: Username of the user who's entry to create, modify or
          remove
        required: true
        type: str
        aliases: ['user']
    secret:
        description:
            - TOTP secret
            - Should be a random hexidecimal string of around 40 characters (20
              bytes)
            - See the password plugin
              https://docs.ansible.com/ansible/latest/collections/ansible/builtin/password_lookup.html
              for a method to generate random secrets.
        required: true
        type: str
    update_secret:
        description:
            - C(always) will update passwords if they differ.
            - C(on_create) will only set the password for newly created users.
        type: str
        choices: [ always, on_create ]
        default: always
    state:
        description: Whether the user's entry should exist or not
        type: str
        choices: [ absent, present ]
        default: present
    backup:
        description: Create a backup of the original OATH users file
        type: bool
        default: no

# extends_documentation_fragment:
#     - my_namespace.my_collection.my_doc_fragment_name

# author:
#     - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Create OATH entry for a user
  pam_oath_user:
    name: harry
    secret: 2790e8a91e763942ba23cdadd442d064d9ac908d

- name: Create OATH entry for a user with a random secret, backing up the
    original
  pam_oath_user:
    name: sam
    secret: "{{ lookup('password', '/dev/null chars=0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f length=40') }}"
    backup: yes
'''  # noqa: 402

RETURN = r'''
name:
    description: User account name
    returned: always
    type: str
    sample: 'harry'
secret:
    description: Masked value of the users OATH secret
    returned: always
    type: str
    sample: 'NOT_LOGGING_SECRET'
state:
    description: Whether the user's OATH entry should exist or not
    returned: always
    type: str
    sample: 'present'
backup_file:
    description: Path to the backup of the previous OATH users file
    returned: When I(backup) is C(True)
'''

from ansible.module_utils.basic import AnsibleModule  # noqa: 402
from ansible.module_utils._text import to_native  # noqa: 402
from pathlib import Path  # noqa: 402
import re  # noqa: 402


def match_line_number(pattern, lines):
    for line_number, line in enumerate(lines):
        if pattern.match(line):
            return line_number


def main():
    OATH_FILE = '/etc/users.oath'
    TOKEN_TYPE = 'HOTP/T30/6'
    backup_file = None

    module = AnsibleModule(
        argument_spec=dict(
            name=dict(type='str', required=True, aliases=['user']),
            secret=dict(type='str', required=True),
            update_secret=dict(type='str', required=False,
                               choices=['always', 'on_create'],
                               default='always'),
            state=dict(type='str', required=False,
                       choices=['present', 'absent'],
                       default='present'),
            backup=dict(type='bool', required=False, default=False)
        ),
        supports_check_mode=True
    )

    # Create a new user entry
    user_entry = '{token_type} {user} - {secret}\n'.format(
        token_type=TOKEN_TYPE,
        user=module.params['name'],
        secret=module.params['secret']
    )

    # Seed the result dict in the object
    result = dict(
        changed=False,
        name=module.params['name'],
        state=module.params['state'],
        secret='NOT_LOGGING_SECRET'
    )

    # Ensure that OATH file exists
    p = Path(OATH_FILE)
    if not p.exists():
        module.fail_json(
            msg='{} does not exist or is not visible'.format(OATH_FILE),
            **result
        )

    # Get contents of OATH file
    try:
        oath_contents = open(OATH_FILE).read()
    except Exception as err:
        module.fail_json(
            msg="failed to read {oath_file}: {err}".format(
                oath_file=OATH_FILE,
                err=to_native(err)
            )
        )

    # Construct regex for user's entry in OATH file
    pattern = re.compile(
        r'^{token_type}\s+({user})\s+-\s+([0-9A-Fa-f]+)'.format(
            token_type=TOKEN_TYPE,
            user=module.params['name']
        ),
        re.MULTILINE
    )
    # Look for (the first) entry for user
    match = pattern.search(
        oath_contents
    )
    current_secret = match.group(2)

    if module.params['state'] == 'absent':
        if match:
            # User is present and should not be, remove the user entry
            result['changed'] = True

            if module.check_mode:
                module.exit_json(**result)

            # Remove existing entry
            oath_contents_new = oath_contents.splitlines()
            oath_contents_new.pop(
                match_line_number(pattern, oath_contents_new)
            )

            # Backup existing OATH users file
            if module.params['backup']:
                backup_file = module.backup_local(OATH_FILE)

            # Write OATH users file
            with open(OATH_FILE, "w") as oath_file:
                oath_file.writelines(oath_contents_new)
    elif module.params['state'] == 'present':
        if not match:
            # User is not present and should be, add a user entry
            result['changed'] = True

            if module.check_mode:
                module.exit_json(**result)

            # Backup existing OATH users file
            if module.params['backup']:
                backup_file = module.backup_local(OATH_FILE)

            # Append the new entry to the OATH users file
            with open(OATH_FILE, 'a') as oath_file:
                oath_file.write(user_entry)
        elif match:
            if (current_secret != module.params['secret'] and
                    module.params['update_secret'] == 'always'):
                # User is present but secret is not consistent, update user
                # entry
                result['changed'] = True

                if module.check_mode:
                    module.exit_json(**result)

                # Replace existing entry
                oath_contents_new = oath_contents.splitlines()
                oath_contents_new[
                    match_line_number(pattern, oath_contents_new)
                ] = user_entry

                # Backup existing OATH users file
                if module.params['backup']:
                    backup_file = module.backup_local(OATH_FILE)

                # Write OATH users file
                with open(OATH_FILE, "w") as oath_file:
                    oath_file.writelines(oath_contents_new)

    if backup_file:
        result['backup_file'] = backup_file

    # Catch check mode when no changes have occurred
    if module.check_mode:
        module.exit_json(**result)

    # Catch success
    module.exit_json(**result)


if __name__ == '__main__':
    main()
