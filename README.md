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

In another terminal Identify the `Container ID`

```
$ docker ps
CONTAINER ID        IMAGE                                                                      COMMAND                  CREATED             STATUS              PORTS                    NAMES
33ad742cac21        gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest   "gosu roughenough:ro…"   37 minutes ago      Up 2 seconds        0.0.0.0:2002->2002/udp   chainpoint-roughtime
```

Run the client against the local server (you'll need to provide your server's unique `Container ID` not the one shown here)

```
$ docker exec -it 33ad742cac21 /roughenough/target/release/client 127.0.0.1 2002

Requesting time from: "127.0.0.1":2002
Received time from server: midpoint="Sep 23 2018 05:26:57", radius=1000000 (merkle_index=0, verified=false)
```

## Run a `roughenough` Client

This Docker image also includes the Roughenough client. You can use it to retrieve and verify a timestamp from any Roughtime server.

You can find a description of additional Roughtime hosts in the [ecosystem.md](https://github.com/cloudflare/roughtime/blob/master/ecosystem.md) file and a JSON representation of the list in [ecosystem.json](https://github.com/cloudflare/roughtime/blob/master/ecosystem.json). A few prominent servers are provided with client examples below.

## Roughtime Servers

### roughtime.chainpoint.org

The `chainpoint.org` roughtime servers run on the Google Compute Platform behind a `UDP` load balancer and rely on Google's internal leap-smeared `NTP` time service for accuracy.

The `roughtime.chainpoint.org` long term public key is:

```
hex :
6db4fe44f4bbcca5fac3bd6cb0f89bce6c16a94f5f7d1579a23d8eadeb129a11

base64:
bbT+RPS7zKX6w71ssPibzmwWqU9ffRV5oj2OresSmhE=
```

This [conversion tool](https://cryptii.com/base64-to-hex) can be convenient for Hex/Base64 conversion for clients that expect the public key in one form or the other.

The long-term public key can also be discovered through a DNS `TXT` record:

```
$ dig -t txt roughtime.chainpoint.org

...
;; ANSWER SECTION:
roughtime.chainpoint.org. 300	IN	TXT	"6db4fe44f4bbcca5fac3bd6cb0f89bce6c16a94f5f7d1579a23d8eadeb129a11"
...
```

A timestamp can be retrieved using a pre-built client hosted in a public Docker image:

```
$ docker run -it --rm gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest /roughenough/target/release/client roughtime.chainpoint.org 2002 -p 6db4fe44f4bbcca5fac3bd6cb0f89bce6c16a94f5f7d1579a23d8eadeb129a11

Requesting time from: "roughtime.chainpoint.org":2002
Received time from server: midpoint="Sep 23 2018 04:47:46", radius=1000000 (merkle_index=0, verified=true)
```

### Other Roughtime Servers

You can use the client in this docker image to get a timestamp from any of them using the following command, substituting the `HOST` and `PUBLIC-KEY`:

```
$ docker run -it --rm gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest /roughenough/target/release/client <HOST> 2002 -p <PUBLIC-KEY>
```

#### roughtime.cloudflare.com

```
$ docker run -it --rm gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest /roughenough/target/release/client roughtime.cloudflare.com 2002 -p 803eb78528f749c4bec2e39e1abb9b5e5ab7e4dd5ce4b6f2fd2f93ecc3538f1a
```

#### roughtime.sandbox.google.com

```
$ docker run -it --rm gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest /roughenough/target/release/client roughtime.sandbox.google.com 2002 -p 7ad3da688c5c04c635a14786a70bcf30224cc25455371bf9d4a2bfb64b682534
```

#### roughtime.int08h.com

```
$ docker run -it --rm gcr.io/chainpoint-registry/github-chainpoint-chainpoint-roughtime:latest /roughenough/target/release/client roughtime.int08h.com 2002 -p 016e6e0284d24c37c6e4d7d8d5b4e1d3c1949ceaa545bf875616c9dce0c9bec1
```
