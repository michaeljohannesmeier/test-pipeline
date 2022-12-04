#!/bin/bash

# - generate a folder with the files:
#   cert:               certificate
#   key:                key of cert
#   intermediate-cert:  intermediate certificate
# - then run sh generate-cert-secret <folder-path>
# - this will generate a k8s secret file


if [ $# -eq 0 ]
  then echo "please sepcify folder to cd into"
  exit 1
fi
echo "Cd to $1"
cd $1

echo "Reading certs"
CERT=$( cat cert )
INTERMEDIATE_CERT=$( cat intermediate-cert )

echo "Combining certs"
cat > combined <<EOF
$CERT
$INTERMEDIATE_CERT
EOF

echo "Generating base 64 hashes"
B64_KEY=$(base64 -w 0 key)
B64_CERT=$(base64 -w 0 combined)
rm combined

echo "Generating secrets yaml"
cat > new-secret.yml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: secret-jaaluu.com
data:
  tls.crt: $B64_CERT
  tls.key: $B64_KEY
EOF