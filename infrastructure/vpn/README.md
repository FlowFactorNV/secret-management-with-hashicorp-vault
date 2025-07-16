# 1. create crt and key from terraform output:
```bash
terraform output -raw root_cert > root.crt
terraform output -raw root_key > root.key
```

# 2. Create client cert (Signed by server cert)
```bash
# Generate client key
openssl genrsa -out client.key 2048

# Generate CSR
openssl req -new -key client.key -out client.csr \
  -subj "/CN=myclient/OU=MyOrg"

# Sign the CSR with your Root CA
openssl x509 -req -in client.csr -CA root.crt -CAkey root.key \
  -CAcreateserial -out client.crt -days 365 -sha256
```

# 3. Download ovpn file from aws and add client.crt and client.key to ovpn file:
```ovpn
<ca>
-----BEGIN CERTIFICATE-----
... contents of root.crt ...
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
... contents of client.crt ...
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN RSA PRIVATE KEY-----
... contents of client.key ...
-----END RSA PRIVATE KEY-----
</key>
```

# 4. Connect: 
- `sudo openvpn --config downloaded-client-config.ovpn`

