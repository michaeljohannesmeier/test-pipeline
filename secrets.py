# pip install cryptography
import glob
import sys
from cryptography.fernet import Fernet
from enum import Enum
import os

class Mode(Enum):
    DECRYPT = "decrypt"
    ENCRYPT = "encrypt"

if len(sys.argv) < 2 or (sys.argv[1] != Mode.DECRYPT.value and sys.argv[1] != Mode.ENCRYPT.value):
    print(f"Specify one of: {[k.value for k in Mode]}")
    sys.exit(1)
de_or_encrypt = sys.argv[1]

files_to_encrypt = [
    "cloud.cfg",
    "generate-cloud-cfg.sh",
    "secret-cert-jaaluu.com.yml",
    "config",
    "env-vars.txt"
]

# key = Fernet.generate_key()
# string the key in a file
# with open('decrypt.key', 'wb') as filekey:
#   filekey.write(key)

# opening the key
if len(sys.argv) == 3:
    key = sys.argv[2]
else:
    with open('decrypt.key', 'rb') as filekey:
        key = filekey.read()
 
# using the generated key
fernet = Fernet(key)
 
# opening the original file to encrypt
# opening the original file to encrypt
for root, _, files in os.walk("."):
    for file in files:
        for file_to_encrypt in files_to_encrypt:
            filepath = os.path.join(root, file)
            if not file.endswith(file_to_encrypt) or ".git" in filepath:
                continue
            with open(filepath, 'rb') as file:
                original = file.read()
            if de_or_encrypt == Mode.DECRYPT.value:
                print(f"Decrypting: {filepath}")
                de_or_encrypted = fernet.decrypt(original)
            elif de_or_encrypt == Mode.ENCRYPT.value:
                print(f"Encrypting: {filepath}")
                de_or_encrypted = fernet.encrypt(original)
            with open(filepath, 'wb') as encrypted_file:
                encrypted_file.write(de_or_encrypted)
