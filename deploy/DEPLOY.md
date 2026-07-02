# Deploying SnubWorks alongside TeamForce (shared Caddy)

| | |
|---|---|
| VPS | DigitalOcean droplet `134.122.46.229` |
| Existing app | TeamForce — `https://teamforce.teamsnubbing.com` at `/opt/teamforce-git` |
| New app | SnubWorks — `https://snubworks.teamsnubbing.com` at `/opt/snubworks-git` |
| Pattern | Docker Compose + **one shared Caddy** (owned by TeamForce) on 80/443 |
| Repo / branch | `https://github.com/gunstarzer0/snub-sim` · `main` |

**Architecture:** SnubWorks is a **static frontend only** — a single `index.html`
(Three.js loaded from cdnjs) served by nginx inside its container. No backend,
no API, no database, no Postgres, no env secrets, no Ollama. So there is nothing
internal to expose or protect beyond keeping the container off the public
interface. SnubWorks runs **no Caddy of its own** — it joins TeamForce's Caddy
network and the existing Caddy routes to it by container name.

SSH in first (from Windows PowerShell):
```powershell
ssh -i $env:USERPROFILE\.ssh\teamforce_tools root@134.122.46.229
```

---

## 1. Inspect — change nothing yet

```sh
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'
docker compose ls
ls -la /opt
ls -la /opt/teamforce-git
cd /opt/teamforce-git && docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
cd /opt/teamforce-git && cat deploy/Caddyfile

# find the Caddy container name and the network it's on (needed below)
CADDY=$(docker ps --filter name=caddy --format '{{.Names}}')
echo "caddy container: $CADDY"
docker inspect "$CADDY" -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'
docker inspect "$CADDY" -f '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{"\n"}}{{end}}'  # where Caddyfile is mounted
```

Record: the Caddy **container name**, its **network name** (e.g.
`teamforce-git_proxy` — this is Caddy's network, NOT `teamforce-git_default`),
and the **path** its Caddyfile is mounted from
(should be `/opt/teamforce-git/deploy/Caddyfile`). Confirm no container already
uses the name `snubworks`.

---

## 2. Clone SnubWorks (separate path — TeamForce untouched)

```sh
cd /opt
git clone https://github.com/gunstarzer0/snub-sim.git snubworks-git
cd /opt/snubworks-git
git checkout main

# tell the prod override which network TeamForce's Caddy is on
echo "CADDY_NETWORK=<network-from-step-1>" > .env      # TEAMFORCE: teamforce-git_proxy
```

---

## 3. Start SnubWorks + add its route to the shared Caddy

```sh
cd /opt/snubworks-git

# a) build & start the static container on the shared network (no host ports)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps      # expect "healthy"

# b) BACK UP TeamForce's Caddyfile, then append the SnubWorks site block
cd /opt/teamforce-git
cp deploy/Caddyfile deploy/Caddyfile.bak.$(date +%Y%m%d-%H%M%S)
cat /opt/snubworks-git/deploy/Caddyfile >> deploy/Caddyfile
tail -n 8 deploy/Caddyfile        # sanity-check the block landed

# c) validate + reload the EXISTING Caddy (no restart, no downtime)
docker exec <caddy-container> caddy validate --config /etc/caddy/Caddyfile
docker exec <caddy-container> caddy reload   --config /etc/caddy/Caddyfile
```

> If Caddy's Caddyfile is mounted from `/opt/teamforce-git/deploy/Caddyfile`,
> the appended block is already inside the container — `reload` picks it up.
> If TeamForce instead restarts Caddy via compose, use its normal command
> (`docker compose ... up -d`) — do **not** run `down`.

---

## 4. Cloudflare DNS (zone: teamsnubbing.com)

Create a record that resolves `snubworks` to the droplet — **match whatever
TeamForce's record uses** so cert issuance behaves identically:

| Field | Value |
|-------|-------|
| Type | `A` |
| Name | `snubworks` |
| Content | `134.122.46.229` |
| Proxy | **match the `teamforce` record** (see note) |
| TTL | Auto |

Check first: `dig +short teamforce.teamsnubbing.com` and look at the `teamforce`
record in Cloudflare.
- If `teamforce` is a **CNAME** to another hostname, make `snubworks` a CNAME to
  the same target instead of an A record.
- **Proxy status must match `teamforce`.** If `teamforce` is DNS-only (grey),
  set `snubworks` grey too — Caddy needs reachable 80/443 for its ACME
  challenge. If `teamforce` is Proxied (orange) and works, the zone is already
  configured for that (DNS challenge or Origin CA), so orange is safe here too.

---

## 5. Cloudflare SSL/TLS

Do **not** change the zone-wide SSL mode — TeamForce already works under it, and
SnubWorks inherits the same setting. Caddy issues/serves the cert for
`snubworks.teamsnubbing.com` automatically on first request, exactly as it does
for `teamforce`. Just confirm the final site loads over HTTPS (step 6).

---

## 6. Smoke tests

```sh
# on the VPS: SnubWorks reachable from Caddy's network by name
docker exec <caddy-container> wget -qO- http://snubworks:80/ | head -c 200; echo

# host-level routing through the shared Caddy
curl -I -H "Host: snubworks.teamsnubbing.com" http://127.0.0.1

# public HTTPS (from anywhere)
curl -I https://snubworks.teamsnubbing.com          # expect HTTP/2 200

# TeamForce still healthy — MUST still return its normal status
curl -I https://teamforce.teamsnubbing.com
```

Browser at https://snubworks.teamsnubbing.com:
- title reads **SnubWorks**, sim renders
- DevTools console: no asset 404s; `three.min.js` loads from cdnjs
- padlock valid; response header `cf-ray` present if the record is Proxied

(No health/API endpoint — this is a static app. `GET /` doubles as the
container healthcheck.)

---

## 7. Rollback (safe — never touches TeamForce data)

```sh
# 1. remove the SnubWorks route from the shared Caddy
cd /opt/teamforce-git
cp deploy/Caddyfile.bak.<timestamp> deploy/Caddyfile      # restore the backup
docker exec <caddy-container> caddy reload --config /etc/caddy/Caddyfile

# 2. stop + remove the SnubWorks app  (NOTE: no -v, nothing destructive)
cd /opt/snubworks-git
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
docker image rm snubworks:latest

# 3. optional: delete the clone and the Cloudflare snubworks record
cd /opt && rm -rf snubworks-git
```

TeamForce is never stopped at any point; the only shared change is one appended
Caddy block, reverted by restoring the timestamped backup.
