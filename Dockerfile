# SnubWorks — static single-file Three.js app served by nginx.
# The app has no build step; we just copy the static assets into the image.
FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="SnubWorks" \
      org.opencontainers.image.description="Hydraulic workover / snubbing simulator (static Three.js app)" \
      org.opencontainers.image.source="https://github.com/gunstarzer0/snub-sim"

# Custom nginx config (gzip + long-cache for assets, no-cache for index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static app assets
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

# Use 127.0.0.1 (not localhost) — busybox resolves localhost to ::1 first,
# but nginx listens on IPv4 only, which would mark the container unhealthy.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null 2>&1 || exit 1
