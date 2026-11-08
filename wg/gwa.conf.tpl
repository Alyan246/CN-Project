[Interface]
Address = 10.99.0.1/24
ListenPort = 51820
PrivateKey = __PRIV__
MTU = 1440

[Peer]
# GW-B
PublicKey = __PUB_GWB__
AllowedIPs = 10.99.0.2/32, 10.2.0.0/24
Endpoint = 203.0.113.2:51820

[Peer]
# RA-Client
PublicKey = __PUB_RA__
AllowedIPs = 10.99.0.3/32
