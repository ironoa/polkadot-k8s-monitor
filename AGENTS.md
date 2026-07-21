# polkadot-k8s-monitor — agent context

Helmfile-managed monitoring stack for Substrate validators. Public open source:
**nothing environment-specific (hostnames, IPs, stash accounts, cluster names) goes
in this repo** — code, docs, or samples. Operators keep that context outside.

## Guardrails

- **Never commit `config/env.sh`, `config/nodes.yaml`, `config/validators.yaml`** —
  gitignored on purpose, they hold secrets and per-deployment data. The `*.sample.*`
  files must contain placeholders only.
- **Deploy only via `scripts/deployProduction.sh [selector…]`** (e.g. `60 70`, `pre`).
  It runs against the *current kubectl context* — verify the context before syncing.
- Prefer scoped selectors over full-stack syncs: a full sync applies every release,
  including ones you didn't touch.

## Gotchas (paid for in production)

- Every file in `helmfile.d/` needs a `---` separator between `environments:` and
  `repositories:`/`releases:` — modern helmfile hard-errors without it.
- Values files are **`.gotmpl` templates** rendered by helmfile: `{{ env "..." }}`
  reads from `config/env.sh` (sourced by the deploy scripts). Literal `{{ }}` meant
  for Prometheus/Alertmanager must be escaped as {{`{{ ... }}`}}.
- `helmfile jsonPatches`/`strategicMergePatches` do NOT work on the w3f charts —
  kustomize chokes on their empty YAML documents.
- kube-prometheus-stack major upgrades require applying the prometheus-operator CRDs
  manually first (see README → Troubleshooting).
- Alertmanager ≥0.28 removed `match:`/`match_re:` — routes use `matchers:` syntax.
- The watcher's `prometheusRules.enabled` must be true on **exactly one** watcher
  instance, or alert rules get duplicated/lost.
- Loki `schemaConfig`: only append future-dated entries, never edit past ones;
  `allow_structured_metadata` requires the active schema to be tsdb/v13.
