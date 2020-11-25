# Scripts

## Generating password hashes

[`generate_password.py`](./generate_password.py) allows you to enter a password,
without printing it to the screen, and produces a hash which can be inserted
into [`ansible_vars.yaml`](../ansible/ansible_vars.yaml) to set a users
password.

First ensure you have installed the required Python packages

```
$ pip install -r ./requirements.txt
```

Now run the script

```
$ ./generate_password.py
```

You will be asked to enter the same password twice to ensure it has been typed
correctly. If the two entries match, the hash will be printed to the terminal.
