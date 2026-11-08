[Interface]
Address = 10.99.0.3/24
PrivateKey = __PRIV__
MTU = 1440

[Peer]
# GW-A
PublicKey = __PUB_GWA__
AllowedIPs = 10.1.0.0/24, 10.2.0.0/24, 10.99.0.0/24
Endpoint = 198.51.100.2:51820
