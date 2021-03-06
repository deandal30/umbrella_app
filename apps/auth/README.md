# Dev guide

You need to have hydra running in the background to make this work. Below are the steps:

- Create a hydra database in your localhost Postgre instance in pgAdmin

- Setup Secret and Database URL
```
export SYSTEM_SECRET=fOaJKL0uj1WuLps3x+GSX0vAg/WeGs/y3hiRlMBnoF74cnrQuMfXuygMrXaTScOp
export DATABASE_URL=postgres://postgres:postgres@172.20.0.1:5432/hydra?sslmode=disable
```

- Create hydra DB

```
psql postgres

# Inside the psql console
CREATE DATABASE hydra;
```

- Expose your Postgre remotely

```
# Add the ip of the docker network
sudo vim /etc/postgresql/9.5/main/pg_hba.conf

...
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
host    all             all             172.17.0.0/16           md5
...

# Set to listen to any address '*'
sudo vim /etc/postgresql/9.5/main/postgresql.conf

...
# - Connection Settings -
listen_addresses = '*'
...

```

- Run migration

```
docker run -it --rm \
  oryd/hydra:v0.11.6 \
  migrate sql $DATABASE_URL

```

- Run hydra in docker

```
# Dev Env
# Let's run the server (settings explained below):
docker run -d \
  --name auth-hydra \
  -p 9000:4444 \
  -e SYSTEM_SECRET=$SYSTEM_SECRET \
  -e DATABASE_URL=$DATABASE_URL \
  -e ISSUER=http://localhost:9000/ \
  -e CONSENT_URL=http://localhost:4004 \
  -e FORCE_ROOT_CLIENT_CREDENTIALS=medi:p@ssw0rd \
  oryd/hydra:v0.11.6 host --dangerous-force-http


# Staging Env
docker run -d   --name auth-hydra   -p 9000:4444   -e SYSTEM_SECRET=$SYSTEM_SECRET   -e DATABASE_URL=$DATABASE_URL   -e ISSUER=https://identity-ip-staging.medilink.com.ph -e CONSENT_URL=https://auth-ip-staging.medilink.com.ph -e FORCE_ROOT_CLIENT_CREDENTIALS=medi:p@ssw0rd oryd/hydra:v0.11.6 host --dangerous-force-http


docker run -d   --name auth-hydra   -p 9000:4444   -e SYSTEM_SECRET=fOaJKL0uj1WuLps3x+GSX0vAg/WeGs/y3hiRlMBnoF74cnrQuMfXuygMrXaTScOp -e DATABASE_URL=postgres://postgres:postgres@40.1.1.6:5432/hydra?sslmode=disable -e ISSUER=https://identity-ip-staging.medilink.com.ph -e CONSENT_URL=https://auth-ip-staging.medilink.com.ph -e FORCE_ROOT_CLIENT_CREDENTIALS=medi:p@ssw0rd oryd/hydra:v0.11.6 host
```
If the docker container exist, you can restart it by:
```
docker restart auth-hydra
```


- Check logs if it's running ok

```
docker logs auth-hydra
```

- Use Credential flow to get access token

```
curl --include      --request POST      --header "Content-Type: application/x-www-form-urlencoded"      --header "Accept: application/json"   'http://localhost:9000/oauth2/token' -d 'grant_type=client_credentials&client_id=medi&client_secret=p@ssw0rd&scope=hydra.clients openid hydra.policies hydra.consent'
```

# Protected API
Use access token to do the following:

1. Create a client

```
{
  "client_name" : "<name of the client>",
  "client_uri" : "<client website>",
  "grant_types" : ["authorization_code","refresh_token", "client_credentials", "implicit"],
  "scope": "auth",
  "redirect_uris" : ["http://client.domain/callback"]
}
```

2. Initiate a consent request
```
http://localhost:9000/oauth2/auth?client_id=64e89e1a-7dc7-44b1-a0b8-ba061601c5d7&state=dfwlefmwelwefdafek&scope=auth&response_type=code&redirect_uri=https%3A%2F%2Flocalhost%3A9020%2Fcallback

```
- client_id : based from the client id when client was created
- state: Random string that the client can validate in their side to avoid CSRF
- scope: auth is the current allowed scope
- response_type : use code to trigger authorization code


# Create a consent app for testing

```
docker run -d \
         --name ory-hydra-example--consent \
         -p 9020:3000 \
         -e HYDRA_CLIENT_ID=a718ffa6-c4f6-48f2-b418-2dcbd9b651af \
         -e HYDRA_CLIENT_SECRET=BYeGlo9Gp.Ke \
         -e HYDRA_URL=http://localhost:9000 \
         -e NODE_TLS_REJECT_UNAUTHORIZED=0 \
         oryd/hydra-consent-app-express:v0.1.7
```
