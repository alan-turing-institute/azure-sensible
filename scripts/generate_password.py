#!/usr/bin/env python
from passlib.hash import sha512_crypt
from getpass import getpass

verified = False

while not verified:
    password_hash = sha512_crypt.using(rounds=5000).hash(getpass())
    verified = sha512_crypt.verify(getpass("Verify password:"), password_hash)

print("\nPassword verified")
print(f"Hash: {password_hash}")
