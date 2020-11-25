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

## Generating QR code images

[`generate_qr_codes.py`](./generate_qr_codes.py) takes the output of the ansible
playbook and generates QR code images of the TOTP hashes for each user. These
can be scanned by the users with an authenticator app, and used to generate TOTP
passwords for authentication.

This script calls qrencode so you will need to make sure this is installed.

Generate the QR code images with

```
$ ./generate_qr_codes.py
```

This will place the images in your current directory.

There are also options to specify the paths of the file containing the hashes
and where to save the image files.

```
$ ./generate_qr_codes.py -h
```
