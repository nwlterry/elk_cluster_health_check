# elk_cluster_health_check

Bash scripts that poll Elasticsearch `_cluster/health` until status is `green`, then stop the local Elasticsearch service and reboot the host.

Intended for a rolling restart after OS patching: wait until the cluster is healthy, then reboot this node.

## Files

| File | Notes |
| --- | --- |
| `elk_cluster_health_check.v03.sh` | Latest. Validates domain credentials against `https://$(hostname -f):9200/_cluster/health`, then loops until `status` is `green`. |
| `elk_cluster_health_check.v02.sh` | Previous version. |
| `elk_cluster_health_check.v01.sh` | First version. |

Prefer `v03`.

## Behavior (v03)

1. Prompts for domain username and password (`domain\\user`).
2. Checks HTTP 200 on `_cluster/health`.
3. Polls every 15 seconds until `jq .status` is `green`.
4. Runs `systemctl stop elasticsearch.service` and `reboot`.

Requires `curl`, `jq`, and permission to stop Elasticsearch and reboot.

Uses `curl -k` (TLS verify off).
