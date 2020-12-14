#!/usr/bin/env python3
from passlib.hash import sha512_crypt
from getpass import getpass


def main():
    """Print the hash of an input password"""
    verified = False

    while not verified:
        # Ask for password from stdin and generate hash
        password_hash = sha512_crypt.using(rounds=5000).hash(getpass())
        # Ask again and confirm if the hashes match
        verified = sha512_crypt.verify(
            getpass("Verify password: "),
            password_hash
        )

    print("\nPassword verified")
    print(f"Hash: {password_hash}")


if __name__ == "__main__":
    main()
