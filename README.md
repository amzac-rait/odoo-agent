# Letzdoo Odoo Agent for Cursor

A curated collection of Cursor skills for professional Odoo ERP development — fast code indexing, intelligent patterns, token optimization, and live instance querying.

> Part of the [Letzdoo AI Marketplace for Odoo](https://ai.letzdoo.com).

## Quick Start

```bash
git clone https://github.com/amzac-rait/odoo-agent.git
cd odoo-agent

# Global install — skills available in all Cursor projects
./scripts/install-cursor.sh --global

# Or install into a specific Doodba/Odoo project (includes rules + hooks)
./scripts/install-cursor.sh --project ~/my-odoo-project

# Optional: build indexer and OTK dependencies
./scripts/install-cursor.sh --global --with-deps
```

Then in Cursor, ask naturally: *"Create an Odoo 18 module for inventory tracking"* or *"What fields does sale.order have?"*

## Skill Inventory

| Skill | Purpose |
|-------|---------|
| **odoo-development** | Index of 123 Odoo 14–19 pattern files (progressive loading) |
| **odoo-context-gatherer** | Mandatory pre-code context compilation |
| **odoo-code-reviewer** | Deep review against Odoo conventions |
| **odoo-upgrade-analyzer** | Version compatibility analysis |
| **odoo-skill-finder** | Targeted pattern lookup (≤50 lines) |
| **odoo-module** | Scaffold new modules |
| **odoo-owl** | Generate OWL components (version-aware) |
| **odoo-review** | Best-practices review |
| **odoo-security** | Access rights and record rules |
| **odoo-gen-test** | Generate test cases |
| **odoo-upgrade** | Version upgrade analysis |
| **odoo-indexer** | SQLite code indexer (<100ms queries) |
| **odoo-setup** | Doodba environment validation + indexer build |
| **odoo-test** | Run tests via Doodba `invoke test` |
| **odoo-query** | Read-only XML-RPC queries against live instances |
| **otk** | Token optimization overview |
| **otk-setup** | Build OTK and register Cursor hook |
| **otk-gain** | Token savings analytics |

## Compatibility

| Component | Requires Doodba | Works with any Odoo | Standalone |
|-----------|:---------------:|:-------------------:|:----------:|
| odoo-development | | | Yes |
| odoo-indexer / odoo-setup | Yes | | |
| odoo-query | | Yes | Yes |
| otk (token killer) | | | Yes |

**Recommended Doodba stack:** install with `--project` into your Doodba repo for the full experience (rules, hooks, indexer, patterns).

## Repository Structure

```
odoo-agent/
├── .cursor/
│   ├── skills/           # 18 skill directories + otk-core library
│   ├── rules/            # odoo-development.mdc (always-on workflow)
│   ├── hooks/            # OTK preToolUse hook
│   └── hooks.json        # Hook registration
├── scripts/
│   ├── install-cursor.sh # --global | --project | --uninstall
│   └── validate-cursor.sh
├── INSTALLATION.md
└── README.md
```

## Token Optimization (OTK)

OTK intercepts Shell tool calls via a Cursor `preToolUse` hook and returns filtered output — typically 60–90% token savings on tests, logs, git, and file reads.

```bash
# After install, set up OTK
# Ask Cursor: "Run otk-setup skill"
cargo install --path .cursor/skills/otk-core   # or use --with-deps
```

## Uninstall

```bash
./scripts/install-cursor.sh --uninstall --global
./scripts/install-cursor.sh --uninstall --project ~/my-odoo-project
```

## Contributing

1. Add or edit skills under `.cursor/skills/<name>/SKILL.md`
2. Add pattern files under `.cursor/skills/odoo-development/reference/`
3. Run `./scripts/validate-cursor.sh`
4. Submit a pull request

## License

MIT — see [LICENSE](LICENSE).

## Links

- [Installation guide](INSTALLATION.md)
- [Letzdoo](https://letzdoo.com)
- [Cursor Skills documentation](https://cursor.com/docs)
