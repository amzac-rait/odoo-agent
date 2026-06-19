---
name: otk-gain
description: Show OTK token savings analytics dashboard. Use when user asks about token savings, otk stats, otk gain, or token analytics.
---

# OTK Gain Analytics

Display the OTK token savings analytics dashboard.

## Commands

```bash
otk gain
otk gain --daily
otk gain --json
otk gain --daily --json
otk gain --reset
```

## Output

The dashboard shows:
- Total commands intercepted
- Estimated tokens saved
- Breakdown by filter type (test, log, git, python, xml, etc.)
- Daily trends with `--daily`

Requires OTK to be installed via the otk-setup skill.
