#! /usr/bin/env python3
"""Generate QR codes from TOTP hashes"""
from pathlib import Path
import re
from subprocess import run, PIPE
import argparse


def main():
    """Generate QR codes from TOTP hashes"""
    parser = argparse.ArgumentParser(
        description="Generate QR codes from TOTP hashes"
    )
    parser.add_argument(
        "--totp-hashes",
        type=str,
        default="./totp_hashes.txt",
        help="Path of the TOTP hashes file"
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="./",
        help="Path to write the QR code images"
    )
    args = parser.parse_args()

    # Read username and TOTP hash combinations
    totp_hashes = open(args.totp_hashes, "r").readlines()
    totp_hashes = [line.split() for line in totp_hashes]

    # Get the machine name from terraform state
    host_name = re.search(
        r'^\s+"computer_name": "(\S*)",$',
        open("../terraform/terraform.tfstate").read(),
        re.MULTILINE
    ).group(1)

    # Create QR code directory
    qr_directory = Path(args.output_dir)
    qr_directory.mkdir(parents=True, exist_ok=True)

    for username, totp_hash in totp_hashes:
        # Find the base32 secret for each user
        result = run(
            ["oathtool", "--totp", "-v", totp_hash],
            stdout=PIPE,
            universal_newlines=True,
            check=True,
        )
        base32_secret = re.search(
            r"^Base32 secret: ([A-Z0-9]{24})$", result.stdout, re.MULTILINE
        ).group(1)

        # Generate a QR code for each user
        result = run(
            ["qrencode",
             f"otpauth://totp/{username}@{host_name}?secret={base32_secret}",
             "-o", f"{qr_directory}/{username}.png"],
            check=True,
        )

        if result.returncode == 0:
            print(f"Successfully generated QR code for user {username}")
        else:
            print(f"Failed to generate QR code for user {username}")

    print(f"QR code images are located in {qr_directory}")


if __name__ == "__main__":
    main()
