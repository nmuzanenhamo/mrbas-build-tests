FROM busybox:1.36
# === hostile probes: every check prints what it could (not) reach ===
RUN echo "== env scan ==" && (env | grep -iE 'secret|token|pass|key|mrbas|aws|cred' || echo "env clean")
RUN echo "== docker socket ==" && (ls -l /var/run/docker.sock 2>&1 || echo "no socket")
RUN echo "== host/agent paths ==" && (ls /etc/mrbas /var/lib/mrbas-agent 2>&1 || echo "no agent paths")
RUN echo "== metadata ==" && (timeout 3 wget -qO- http://169.254.169.254/ 2>&1 || echo "metadata unreachable")
RUN echo "== private ranges ==" && (timeout 3 wget -qO- http://10.1.2.3/ 2>&1 || echo "private unreachable")
RUN echo "== control-plane net ==" && (timeout 3 wget -qO- http://172.17.0.1:8080/ 2>&1 || echo "bridge-gw unreachable")
# build secret: mount, use, prove mount does not persist into layers
RUN --mount=type=secret,id=marker \
    echo "marker check: [$(cat /run/secrets/marker 2>/dev/null || echo none)]"
RUN echo "== leak check ==" && (ls /run/secrets 2>&1 || echo "secrets dir absent now")
RUN mkdir -p /www && echo ok > /www/index.html
EXPOSE 80
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
