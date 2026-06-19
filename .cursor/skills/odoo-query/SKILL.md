---
name: odoo-query
description: Connect to Odoo instances via XML-RPC for read-only queries to investigate issues and explore data. Use when user asks to query odoo, connect to odoo, investigate odoo data, or read odoo records.
---

# Odoo Query Skill

Connect to Odoo instances via XML-RPC and perform **read-only** queries.

## Security Rules

Only READ operations are allowed: `search`, `read`, `search_read`, `fields_get`, `search_count`.
Never use `create`, `write`, `unlink`, or any modifying method.

## Connection

Run from the odoo-query skill directory. Use `scripts/odoo_xmlrpc.py`:

```bash
python3 scripts/odoo_xmlrpc.py \
  --url "URL" \
  --db "DATABASE" \
  --login "LOGIN" \
  --api-key "API_KEY" \
  --action ACTION \
  [--model MODEL] \
  [--domain DOMAIN] \
  [--fields FIELDS] \
  [--limit LIMIT]
```

## Actions

| Action | Description |
|--------|-------------|
| `test` | Test connection |
| `list_models` | List available models |
| `fields_get` | Get model field definitions |
| `search` | Search record IDs |
| `read` | Read specific records |
| `search_read` | Search and read in one call |

## Examples

```bash
# Test connection
python3 scripts/odoo_xmlrpc.py --url "$URL" --db "$DB" --login "$LOGIN" --api-key "$KEY" --action test

# Get sale.order fields
python3 scripts/odoo_xmlrpc.py --url "$URL" --db "$DB" --login "$LOGIN" --api-key "$KEY" \
  --action fields_get --model "sale.order"

# Search partners
python3 scripts/odoo_xmlrpc.py --url "$URL" --db "$DB" --login "$LOGIN" --api-key "$KEY" \
  --action search_read --model "res.partner" --domain '[["is_company","=",true]]' \
  --fields '["name","email"]' --limit 10
```

## Configuration

Users must provide: URL, database, login, and API key (preferred) or password.
Credentials are session-scoped only — never persist them.

## Reference

See `reference/xmlrpc-query-patterns.md` and `reference/instance-profile-patterns.md` for advanced query patterns.
