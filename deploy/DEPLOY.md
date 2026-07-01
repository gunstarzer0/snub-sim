# Deploying SnubWorks to the TEAMFORCE VPS

Target public URL: **https://snubworks.teamsnubbing.com**
Repo: `https://github.com/gunstarzer0/snub-sim` · branch: `main`

Run every command below **on the TEAMFORCE droplet** (SSH in first). Nothing
here touches the existing TeamForce app until the reverse-proxy step, which
only *adds* a vhost. Fill in the two unknowns as you go:
`<DROPLET_PUBLIC_IP>` and your proxy stack (discovered in step 1).

---

## 1. Inspect the existing layout (read-only — change nothing yet)

```sh
# running containers + their published ports
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'

# everything listening on the host (identify the proxy + free ports)
sudo ss -tlnp | sort -k4

# where apps live — check the common conventions
ls -la /opt/teamforce/apps 2>/dev/null; ls -la /opt 2>/dev/null; ls -la /srv 2>/dev/null

# identify the reverse-proxy stack (whichever prints something wins)
docker ps --format '{{.Image}} {{.Names}}' | grep -Ei 'nginx|caddy|traefik|cloudflared'
systemctl is-active nginx caddy 2>/dev/null
sudo nginx -v 2>&1; caddy version 2>/dev/null
docker network ls
```

Record, before changing anything:
- app root convention (e.g. `/opt/teamforce/apps/<app>`)
- proxy stack: **host-nginx / containerized-nginx / Caddy / Traefik / cloudflared**
- if Traefik/containerized-nginx: the shared docker network name
- ports already in use (confirm **8081** is free; if not, pick the next free one)

---

## 2. Deploy the app

```sh
# use the existing convention if it differs from this default
sudo mkdir -p /opt/teamforce/apps
cd /opt/teamforce/apps
sudo git clone https://github.com/gunstarzer0/snub-sim.git snubworks
cd snubworks
git checkout main

# --- choose the compose invocation that matches your proxy stack ---

# A) host nginx / host Caddy  -> bind to loopback only (proxy is on the host):
docker compose -f docker-compose.yml -f deploy/docker-compose.loopback.yml up -d --build

# B) Traefik (container network routing, no host port):
# docker compose -f docker-compose.yml -f deploy/docker-compose.traefik.yml up -d --build

# C) containerized nginx that shares a docker network:
# attach the container to that network, keep the base compose, and proxy to
# http://snubworks:80 by container name (see step 3-C).
```

Confirm health + local response:

```sh
docker compose ps
docker ps --filter name=snubworks --format '{{.Names}} {{.Status}}'   # expect "healthy"
curl -I http://127.0.0.1:8081                                         # expect HTTP/1.1 200
```

> **Port already taken?** Edit the port in
> `deploy/docker-compose.loopback.yml` (or the base `docker-compose.yml`),
> re-run `up -d`, and use the new port everywhere below.

---

## 3. Reverse-proxy routing (adds a vhost; existing routes untouched)

### 3-A · Host nginx
```sh
sudo cp deploy/snubworks.nginx.conf /etc/nginx/sites-available/snubworks.teamsnubbing.com
sudo ln -s /etc/nginx/sites-available/snubworks.teamsnubbing.com /etc/nginx/sites-enabled/
# get a cert (webroot must match the acme location in the site file):
sudo certbot certonly --webroot -w /var/www/certbot -d snubworks.teamsnubbing.com
sudo nginx -t && sudo systemctl reload nginx      # test BEFORE reload
```

### 3-B · Caddy
```sh
cat deploy/snubworks.Caddyfile | sudo tee -a /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy            # Caddy auto-issues the TLS cert
```

### 3-C · Containerized nginx
Add a site file into the proxy container's conf dir (mounted volume), using the
container name as upstream instead of a host port:
```nginx
location / { proxy_pass http://snubworks:80; ... }   # same network required
```
```sh
docker network connect <proxy_network> snubworks     # if not already shared
docker exec <nginx_container> nginx -t && docker exec <nginx_container> nginx -s reload
```

### 3-D · Traefik
Nothing more — the labels in `deploy/docker-compose.traefik.yml` register the
route and request the cert automatically. Verify in the Traefik dashboard/logs.

### 3-E · Cloudflare Tunnel (cloudflared)
Add an ingress rule to the tunnel config (`/etc/cloudflared/config.yml`):
```yaml
ingress:
  - hostname: snubworks.teamsnubbing.com
    service: http://127.0.0.1:8081
  # ...existing rules stay ABOVE the catch-all...
  - service: http_status:404
```
```sh
sudo systemctl restart cloudflared
```
> With a Tunnel you SKIP step 4's A record — add a **CNAME**
> `snubworks -> <TUNNEL_ID>.cfargotunnel.com` (proxied) instead, or let
> `cloudflared tunnel route dns` create it.

---

## 4. Cloudflare DNS (skip if using a Tunnel — see 3-E)

Dashboard → teamsnubbing.com → DNS → **Add record**:

| Field | Value |
|-------|-------|
| Type | A |
| Name | `snubworks` |
| Content | `<DROPLET_PUBLIC_IP>` |
| Proxy | **Proxied** (orange cloud) |
| TTL | Auto |

If a wildcard `*.teamsnubbing.com` A record already points at this droplet, the
subdomain may already resolve — an explicit record is still clearer. If TeamForce
is reached via a CNAME to another hostname on the same box, a CNAME
`snubworks -> <that-hostname>` is equivalent.

---

## 5. Cloudflare SSL/TLS

- SSL/TLS → Overview → mode. **Prefer Full (strict)** — valid with a Let's
  Encrypt cert (3-A/3-B) or a Cloudflare Origin CA cert on the droplet.
- If the zone is currently **Flexible**, do NOT change it globally without
  sign-off — it affects every teamsnubbing.com host. Instead, get a real origin
  cert for this subdomain and use a per-hostname setting, or confirm the change
  is safe for TeamForce first.
- Origin CA option: SSL/TLS → Origin Server → Create Certificate, install the
  pem/key on the droplet, point the nginx `ssl_certificate*` lines at them.

---

## 6. Validation

```sh
docker ps
docker compose ps
curl -I http://127.0.0.1:8081                                              # 200, local
curl -I -H "Host: snubworks.teamsnubbing.com" http://127.0.0.1             # proxy routes host
curl -I https://snubworks.teamsnubbing.com                                 # public HTTPS 200
curl -I https://<existing-teamforce-host>                                  # TeamForce still 200
```

Then in a browser at https://snubworks.teamsnubbing.com:
- app loads, title reads **SnubWorks**
- DevTools console: no 404s on assets; `three.min.js` loads from the cdnjs CDN
- response header `cf-ray` present (Cloudflare proxy active); padlock valid

---

## 7. Rollback

```sh
# stop + remove just this app (TeamForce untouched)
cd /opt/teamforce/apps/snubworks && docker compose down

# remove the proxy vhost, then reload
#   host nginx:  sudo rm /etc/nginx/sites-enabled/snubworks.teamsnubbing.com && sudo nginx -t && sudo systemctl reload nginx
#   Caddy:       remove the snubworks block from /etc/caddy/Caddyfile && sudo systemctl reload caddy
#   Traefik:     docker compose down already dropped the labels/route
#   tunnel:      remove the ingress rule && sudo systemctl restart cloudflared

# Cloudflare: delete the snubworks A/CNAME record (or grey-cloud it)

# full removal:
cd /opt/teamforce/apps && sudo rm -rf snubworks
docker image rm snubworks:latest
```
