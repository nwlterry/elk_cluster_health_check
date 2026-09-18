# elk_cluster_health_check

Poll Elasticsearch `_cluster/health` until status is `green`, then stop Elasticsearch on this host and reboot. For a rolling restart after OS patching.

## Layout

```
scripts/elk_cluster_health_check.sh   # current (was v03)
archive/                              # v01, v02
GROUP.md
README.md
```

## Behavior

1. Prompts for domain username and password (`domain\\user`).
2. Checks HTTP 200 on `https://$(hostname -f):9200/_cluster/health`.
3. Polls every 15 seconds until `jq .status` is `green`.
4. Runs `systemctl stop elasticsearch.service` and `reboot`.

Requires `curl`, `jq`, and permission to stop Elasticsearch and reboot. Uses `curl -k`.

---

See [GROUP.md](GROUP.md) for sibling repositories. Catalog: https://github.com/nwlterry/nwlterry
