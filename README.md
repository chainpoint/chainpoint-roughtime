# chainpoint-roughtime

An experimental Dockerfile to create a [Roughtime](https://roughtime.googlesource.com/roughtime) server image using the [int08h/roughenough](https://github.com/int08h/roughenough) Rust implementation of the Roughtime client and server.

It is suggested that you only run this server on a host that is properly synced via NTP sources such as [Google Public NTP](https://developers.google.com/time/) that properly handle leap-time smearing.

## Prerequisites

You must have a recent version of Docker and `docker-compose` installed.

## Configuration

Copy the `roughenough.cfg.sample` sample configuration to `roughenough.cfg`. You **must** replace the `seed` value in this file with your own 32 byte (64 Hex character) Hex **secret** value. This value is used to derive your private keys and should be carefully protected.

You can generate a suitable Random hex value with `openssl rand -hex 32`

## Run and Verify a Server Locally

After creating your own `roughenough.cfg` file you can start the server locally:

In a terminal, run the server locally.

```
$ docker-compose up --build
```

In another terminal Identify the `Container ID` (`923c0ad8f67d` in this example)

```
$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                    NAMES
923c0ad8f67d        chainpoint-roughenough:latest   "gosu roughenough:ro…"   34 minutes ago      Up About a minute   0.0.0.0:2002->2002/udp   chainpoint-roughenough
```

Run the client against the local server (you'll need to provide your server's Container ID `-t` and unique public key with the `-p` flag. The values provided in this example won't work for you.)

```
$ docker exec -i -t 923c0ad8f67d /roughenough/target/release/client 127.0.0.1 2002 -p d0756ee69ff5fe96cbcf9273208fec53124b1dd3a24d3910e07c7c54e2473012
Requesting time from: "127.0.0.1":2002
Received time from server: midpoint="Sep 22 2018 20:26:57", radius=1000000 (merkle_index=0, verified=true)
```

## Run a `roughenough` Client

This image also includes the Roughenough client. You can use it to retrieve and verify a timestamp from any Roughtime server. Here are some examples with their proper DNS names and public keys provided.

You might find additional, or updated, Roughtime hosts in the [ecosystem](https://github.com/cloudflare/roughtime/blob/master/ecosystem.config).

roughtime.cloudflare.com

```
$ docker run -it chainpoint-roughenough:latest /roughenough/target/release/c
lient roughtime.cloudflare.com 2002 -p 803eb78528f749c4bec2e39e1abb9b5e5ab7e4dd5ce4b6f2fd2f93ecc3538f1a

Requesting time from: "roughtime.cloudflare.com":2002
Received time from server: midpoint="Sep 23 2018 00:36:19", radius=1000000 (merkle_index=0, verified=true)
```

roughtime.sandbox.google.com

```
$ docker run -it chainpoint-roughenough:latest /roughenough/target/release/c
lient roughtime.sandbox.google.com 2002 -p 7ad3da688c5c04c635a14786a70bcf30224cc25455371bf9d4a2bfb64b682534

Requesting time from: "roughtime.sandbox.google.com":2002
Received time from server: midpoint="Sep 23 2018 00:35:40", radius=1000000 (merkle_index=0, verified=true)
```

roughtime.int08h.com

```
$ docker run -it chainpoint-roughenough:latest /roughenough/target/release/c
lient roughtime.int08h.com 2002 -p 016e6e0284d24c37c6e4d7d8d5b4e1d3c1949ceaa545bf875616c9dce0c9bec1

Requesting time from: "roughtime.int08h.com":2002
Received time from server: midpoint="Sep 23 2018 00:37:01", radius=1000000 (merkle_index=0, verified=true)
```
