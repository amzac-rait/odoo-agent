---
name: instance-profile-patterns
keywords: [profiles, credentials, config, multi-instance, authentication, odoo.sh]
description: Patterns for managing multiple Odoo instance profiles and credentials
---

# Odoo Instance Profile Management Patterns

Reference for managing multiple Odoo instance credentials and profiles for the odoo-query plugin.

## Profile Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  User Home Directory                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ~/.odoo-query/                                                 │
│       │                                                         │
│       ├─ profiles.json     → Profile storage (JSON)            │
│       │   or                                                    │
│       └─ profiles.yaml     → Profile storage (YAML)            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Profile Structure                                              │
├─────────────────────────────────────────────────────────────────┤
│  {                                                              │
│    "profiles": {                                                │
│      "production": {                                            │
│        "url": "https://go-ohv.odoo.com",                        │
│        "db": "go-ohv-main-12345",                               │
│        "login": "jerome.sonnet@letzdoo.com",                    │
│        "api_key": "ccdcec18..."                                 │
│      },                                                         │
│      "staging": {...},                                          │
│      "dev": {...}                                               │
│    },                                                           │
│    "default": "staging"                                         │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  CLI Usage                                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  python3 odoo_xmlrpc.py --profile staging \                    │
│    --action search_read --model sale.order ...                 │
│                                                                 │
│  (Credentials loaded automatically from profile)               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Profile Configuration File

### JSON Format
```json
{
  "profiles": {
    "production": {
      "url": "https://go-ohv.odoo.com",
      "db": "go-ohv-main-12345",
      "login": "jerome.sonnet@letzdoo.com",
      "api_key": "ccdcec18abc123def456...",
      "description": "Production instance"
    },
    "staging": {
      "url": "https://go-ohv-staging-29894548.dev.odoo.com",
      "db": "go-ohv-staging-29894548",
      "login": "admin",
      "api_key": "87ca1d3f456789abc...",
      "description": "Staging environment for testing"
    },
    "dev": {
      "url": "https://go-ohv-dev-xxxxx.dev.odoo.com",
      "db": "go-ohv-dev-xxxxx",
      "login": "admin",
      "api_key": "abc123def456...",
      "description": "Development instance"
    }
  },
  "default": "staging"
}
```

### YAML Format
```yaml
profiles:
  production:
    url: https://go-ohv.odoo.com
    db: go-ohv-main-12345
    login: jerome.sonnet@letzdoo.com
    api_key: ccdcec18abc123def456...
    description: Production instance

  staging:
    url: https://go-ohv-staging-29894548.dev.odoo.com
    db: go-ohv-staging-29894548
    login: admin
    api_key: 87ca1d3f456789abc...
    description: Staging environment for testing

  dev:
    url: https://go-ohv-dev-xxxxx.dev.odoo.com
    db: go-ohv-dev-xxxxx
    login: admin
    api_key: abc123def456...
    description: Development instance

default: staging
```

## CLI Usage with Profiles

### Using a Profile
```bash
# Use named profile (credentials loaded from config)
python3 odoo_xmlrpc.py --profile staging \
  --action search_read \
  --model sale.order \
  --domain "[('state', '=', 'sale')]" \
  --fields "name,partner_id,amount_total"

# Use default profile (no --profile needed)
python3 odoo_xmlrpc.py \
  --action search_read \
  --model sale.order \
  --domain "[]" \
  --limit 10

# Override profile credentials (mix profile + custom)
python3 odoo_xmlrpc.py --profile production \
  --login alternate.user@company.com \
  --action search_read \
  --model res.users \
  --domain "[]"
```

### Backward Compatibility
```bash
# Legacy method still works (no profile needed)
python3 odoo_xmlrpc.py \
  --url https://go-ohv.odoo.com \
  --db go-ohv-main-12345 \
  --login jerome.sonnet@letzdoo.com \
  --api-key ccdcec18... \
  --action search_read \
  --model sale.order \
  --domain "[]"
```

## Profile Management Commands

### Save a New Profile
```bash
# Save profile interactively
python3 odoo_xmlrpc.py \
  --action save_profile \
  --profile-name staging \
  --url https://go-ohv-staging-29894548.dev.odoo.com \
  --db go-ohv-staging-29894548 \
  --login admin \
  --api-key 87ca1d3f456789abc... \
  --description "Staging environment"

# Save with minimal info (description optional)
python3 odoo_xmlrpc.py \
  --action save_profile \
  --profile-name dev \
  --url https://go-ohv-dev-xxxxx.dev.odoo.com \
  --db go-ohv-dev-xxxxx \
  --login admin \
  --api-key abc123def456...
```

### List All Profiles
```bash
# List all saved profiles
python3 odoo_xmlrpc.py --action list_profiles

# Expected output:
# Available profiles:
#   production  https://go-ohv.odoo.com (go-ohv-main-12345)
#               Production instance
#   staging*    https://go-ohv-staging-29894548.dev.odoo.com (go-ohv-staging-29894548)
#               Staging environment for testing
#   dev         https://go-ohv-dev-xxxxx.dev.odoo.com (go-ohv-dev-xxxxx)
#               Development instance
#
# * = default profile
```

### Delete a Profile
```bash
# Delete a profile
python3 odoo_xmlrpc.py \
  --action delete_profile \
  --profile-name dev

# Confirm before deletion
# Output:
# Profile 'dev' deleted successfully.
```

### Set Default Profile
```bash
# Set default profile
python3 odoo_xmlrpc.py \
  --action set_default \
  --profile-name production

# Output:
# Default profile set to 'production'
```

### Test Profile Credentials
```bash
# Test connection with a profile
python3 odoo_xmlrpc.py \
  --action test \
  --profile staging

# Expected output on success:
# Testing profile 'staging'...
# URL: https://go-ohv-staging-29894548.dev.odoo.com
# Database: go-ohv-staging-29894548
# Login: admin
# ✓ Authentication successful
# ✓ User ID: 2
# ✓ Server version: Odoo 17.0
# Profile 'staging' is working correctly.

# Expected output on failure:
# Testing profile 'staging'...
# URL: https://go-ohv-staging-29894548.dev.odoo.com
# Database: go-ohv-staging-29894548
# Login: admin
# ✗ Authentication failed: Invalid credentials
```

## Odoo.sh Auto-Discovery

### Auto-Configure from Odoo.sh Project
```bash
# Discover and create profiles for all Odoo.sh branches
python3 odoo_xmlrpc.py \
  --action discover_odoosh \
  --project-name go-ohv \
  --odoosh-token YOUR_ODOOSH_API_TOKEN

# Expected output:
# Discovering Odoo.sh project: go-ohv
# Found 3 branches:
#   - production (ID: 12345)
#   - staging (ID: 29894548)
#   - dev (ID: xxxxx)
#
# Creating profiles:
# ✓ Profile 'go-ohv-production' created
# ✓ Profile 'go-ohv-staging' created
# ✓ Profile 'go-ohv-dev' created
#
# Note: You need to add API keys manually for each profile.
```

### Odoo.sh Naming Conventions
```
Pattern: {project}-{branch}-{id}.dev.odoo.com

Examples:
  Production:  go-ohv.odoo.com (special case, no suffix)
  Staging:     go-ohv-staging-29894548.dev.odoo.com
  Dev branch:  go-ohv-dev-xxxxx.dev.odoo.com
  Feature:     go-ohv-feature-branch-yyyyy.dev.odoo.com

Database naming: {project}-{branch}-{id}
```

### Manual Odoo.sh Profile Creation
```bash
# Production branch (main domain)
python3 odoo_xmlrpc.py \
  --action save_profile \
  --profile-name production \
  --url https://go-ohv.odoo.com \
  --db go-ohv-main-12345 \
  --login your.email@company.com \
  --api-key PROD_API_KEY

# Staging branch (dev subdomain)
python3 odoo_xmlrpc.py \
  --action save_profile \
  --profile-name staging \
  --url https://go-ohv-staging-29894548.dev.odoo.com \
  --db go-ohv-staging-29894548 \
  --login admin \
  --api-key STAGING_API_KEY

# Dev branch
python3 odoo_xmlrpc.py \
  --action save_profile \
  --profile-name dev \
  --url https://go-ohv-dev-xxxxx.dev.odoo.com \
  --db go-ohv-dev-xxxxx \
  --login admin \
  --api-key DEV_API_KEY
```

## Implementation Pattern

### Profile Manager Class
```python
import os
import json
from pathlib import Path


class ProfileManager:
    """Manages Odoo instance profiles for odoo-query."""

    def __init__(self, config_dir=None):
        """Initialize profile manager."""
        if config_dir is None:
            config_dir = Path.home() / '.odoo-query'

        self.config_dir = Path(config_dir)
        self.config_file = self.config_dir / 'profiles.json'
        self._ensure_config_dir()

    def _ensure_config_dir(self):
        """Create config directory if it doesn't exist."""
        self.config_dir.mkdir(parents=True, exist_ok=True)

    def _load_profiles(self):
        """Load profiles from config file."""
        if not self.config_file.exists():
            return {'profiles': {}, 'default': None}

        with open(self.config_file, 'r') as f:
            return json.load(f)

    def _save_profiles(self, data):
        """Save profiles to config file."""
        with open(self.config_file, 'w') as f:
            json.dump(data, f, indent=2)

    def get_profile(self, name):
        """Get a specific profile by name."""
        data = self._load_profiles()

        if name is None:
            name = data.get('default')
            if name is None:
                return None

        return data['profiles'].get(name)

    def save_profile(self, name, url, db, login, api_key, description=None):
        """Save a profile."""
        data = self._load_profiles()

        data['profiles'][name] = {
            'url': url,
            'db': db,
            'login': login,
            'api_key': api_key,
        }

        if description:
            data['profiles'][name]['description'] = description

        # Set as default if it's the first profile
        if not data['default']:
            data['default'] = name

        self._save_profiles(data)

    def delete_profile(self, name):
        """Delete a profile."""
        data = self._load_profiles()

        if name not in data['profiles']:
            raise ValueError(f"Profile '{name}' not found")

        del data['profiles'][name]

        # Clear default if it was the deleted profile
        if data['default'] == name:
            # Set to first available profile or None
            data['default'] = next(iter(data['profiles'].keys()), None)

        self._save_profiles(data)

    def list_profiles(self):
        """List all profiles."""
        data = self._load_profiles()
        return data['profiles'], data.get('default')

    def set_default(self, name):
        """Set the default profile."""
        data = self._load_profiles()

        if name not in data['profiles']:
            raise ValueError(f"Profile '{name}' not found")

        data['default'] = name
        self._save_profiles(data)

    def test_profile(self, name):
        """Test a profile connection."""
        profile = self.get_profile(name)

        if profile is None:
            raise ValueError(f"Profile '{name}' not found")

        # Test connection using OdooXMLRPC
        from odoo_xmlrpc import OdooXMLRPC

        odoo = OdooXMLRPC(
            url=profile['url'],
            db=profile['db'],
            username=profile['login'],
            api_key=profile['api_key']
        )

        # Try to authenticate
        uid = odoo.authenticate()

        if uid:
            # Get server version
            version = odoo.common.version()
            return {
                'success': True,
                'uid': uid,
                'version': version.get('server_version', 'Unknown'),
            }
        else:
            return {
                'success': False,
                'error': 'Authentication failed'
            }
```

### CLI Integration
```python
def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(description='Odoo XML-RPC Query Tool')

    # Profile arguments
    parser.add_argument('--profile', help='Profile name to use')
    parser.add_argument('--profile-name', help='Profile name for management commands')

    # Original arguments (now optional when using profile)
    parser.add_argument('--url', help='Odoo instance URL')
    parser.add_argument('--db', help='Database name')
    parser.add_argument('--login', help='User login')
    parser.add_argument('--api-key', help='API key')

    # Actions
    parser.add_argument('--action', required=True,
                       choices=['search_read', 'search_count', 'read', 'fields_get',
                               'list_models', 'save_profile', 'list_profiles',
                               'delete_profile', 'set_default', 'test'])

    args = parser.parse_args()

    # Initialize profile manager
    profile_mgr = ProfileManager()

    # Handle profile management commands
    if args.action == 'save_profile':
        profile_mgr.save_profile(
            args.profile_name,
            args.url, args.db, args.login, args.api_key
        )
        print(f"Profile '{args.profile_name}' saved successfully.")
        return

    elif args.action == 'list_profiles':
        profiles, default = profile_mgr.list_profiles()
        print("Available profiles:")
        for name, profile in profiles.items():
            default_marker = '*' if name == default else ' '
            print(f"  {name}{default_marker}  {profile['url']} ({profile['db']})")
            if 'description' in profile:
                print(f"            {profile['description']}")
        if default:
            print(f"\n* = default profile")
        return

    elif args.action == 'delete_profile':
        profile_mgr.delete_profile(args.profile_name)
        print(f"Profile '{args.profile_name}' deleted successfully.")
        return

    elif args.action == 'set_default':
        profile_mgr.set_default(args.profile_name)
        print(f"Default profile set to '{args.profile_name}'")
        return

    elif args.action == 'test':
        profile_name = args.profile or args.profile_name
        print(f"Testing profile '{profile_name}'...")

        profile = profile_mgr.get_profile(profile_name)
        print(f"URL: {profile['url']}")
        print(f"Database: {profile['db']}")
        print(f"Login: {profile['login']}")

        result = profile_mgr.test_profile(profile_name)

        if result['success']:
            print("✓ Authentication successful")
            print(f"✓ User ID: {result['uid']}")
            print(f"✓ Server version: {result['version']}")
            print(f"Profile '{profile_name}' is working correctly.")
        else:
            print(f"✗ Authentication failed: {result['error']}")
        return

    # Load credentials from profile or command line
    if args.profile or (not args.url and not args.db):
        profile = profile_mgr.get_profile(args.profile)

        if profile is None:
            print("Error: No profile found and no credentials provided")
            sys.exit(1)

        # Use profile credentials as defaults, allow CLI override
        url = args.url or profile['url']
        db = args.db or profile['db']
        login = args.login or profile['login']
        api_key = args.api_key or profile['api_key']
    else:
        # Use command line credentials
        url = args.url
        db = args.db
        login = args.login
        api_key = args.api_key

    # Continue with normal query operations...
    odoo = OdooXMLRPC(url, db, login, api_key)
    # ... rest of the implementation
```

## Security Best Practices

### File Permissions
```bash
# Restrict config directory to user only
chmod 700 ~/.odoo-query

# Restrict profiles file to user only
chmod 600 ~/.odoo-query/profiles.json
```

### Secure Storage Recommendations
```python
# 1. Use system keyring for API keys (optional enhancement)
import keyring

def save_secure_profile(name, url, db, login, api_key):
    """Save profile with API key in system keyring."""
    profile_data = {
        'url': url,
        'db': db,
        'login': login,
    }

    # Save metadata to JSON
    save_profile_metadata(name, profile_data)

    # Save API key to system keyring
    keyring.set_password('odoo-query', name, api_key)

def get_secure_profile(name):
    """Get profile with API key from keyring."""
    profile = get_profile_metadata(name)

    # Retrieve API key from keyring
    api_key = keyring.get_password('odoo-query', name)
    profile['api_key'] = api_key

    return profile
```

### Environment Variables Fallback
```python
# Allow environment variable overrides
def get_credentials_with_env_fallback(profile_name=None):
    """Get credentials with environment variable fallback."""
    profile_mgr = ProfileManager()

    if profile_name:
        profile = profile_mgr.get_profile(profile_name)
        if profile:
            return profile

    # Fallback to environment variables
    return {
        'url': os.getenv('ODOO_URL'),
        'db': os.getenv('ODOO_DB'),
        'login': os.getenv('ODOO_LOGIN'),
        'api_key': os.getenv('ODOO_API_KEY'),
    }
```

## Common Use Cases

### Development Workflow
```bash
# Setup: Save all environment profiles once
python3 odoo_xmlrpc.py --action save_profile --profile-name dev \
  --url https://dev.odoo.com --db dev-db --login admin --api-key KEY1

python3 odoo_xmlrpc.py --action save_profile --profile-name staging \
  --url https://staging.odoo.com --db staging-db --login admin --api-key KEY2

python3 odoo_xmlrpc.py --action save_profile --profile-name production \
  --url https://prod.odoo.com --db prod-db --login user@company.com --api-key KEY3

# Daily usage: Just specify profile
python3 odoo_xmlrpc.py --profile dev \
  --action search_read --model sale.order --domain "[]" --limit 5

python3 odoo_xmlrpc.py --profile staging \
  --action search_count --model res.partner --domain "[]"

python3 odoo_xmlrpc.py --profile production \
  --action search_read --model account.move \
  --domain "[('payment_state', '!=', 'paid')]"
```

### Testing Across Environments
```bash
# Test all profiles quickly
for profile in dev staging production; do
  echo "Testing $profile..."
  python3 odoo_xmlrpc.py --action test --profile $profile
done
```

### Profile Switching
```bash
# Set staging as default for current work
python3 odoo_xmlrpc.py --action set_default --profile-name staging

# Now all queries use staging by default
python3 odoo_xmlrpc.py --action search_read --model sale.order --domain "[]"

# Switch to production for quick check
python3 odoo_xmlrpc.py --profile production \
  --action search_count --model sale.order --domain "[('state', '=', 'sale')]"
```

## Troubleshooting

### Profile Not Found
```bash
# List all profiles to verify name
python3 odoo_xmlrpc.py --action list_profiles

# If profile doesn't exist, create it
python3 odoo_xmlrpc.py --action save_profile --profile-name myprofile \
  --url URL --db DB --login LOGIN --api-key KEY
```

### Invalid Credentials
```bash
# Test the profile
python3 odoo_xmlrpc.py --action test --profile myprofile

# Update profile with correct credentials
python3 odoo_xmlrpc.py --action save_profile --profile-name myprofile \
  --url CORRECT_URL --db CORRECT_DB --login CORRECT_LOGIN --api-key CORRECT_KEY
```

### Config File Corruption
```bash
# Backup current config
cp ~/.odoo-query/profiles.json ~/.odoo-query/profiles.json.backup

# Validate JSON
python3 -m json.tool ~/.odoo-query/profiles.json

# If corrupted, restore from backup or recreate manually
```

### Permission Errors
```bash
# Fix config directory permissions
chmod 700 ~/.odoo-query
chmod 600 ~/.odoo-query/profiles.json

# Verify ownership
ls -la ~/.odoo-query/
```

## Migration from Legacy Usage

### Automated Migration Script
```python
def migrate_to_profiles():
    """Helper to migrate from command-line credentials to profiles."""
    import sys

    print("Profile Migration Wizard")
    print("=" * 40)

    profile_name = input("Enter profile name: ")
    url = input("Enter Odoo URL: ")
    db = input("Enter database name: ")
    login = input("Enter login: ")
    api_key = input("Enter API key: ")
    description = input("Enter description (optional): ")

    profile_mgr = ProfileManager()
    profile_mgr.save_profile(
        profile_name, url, db, login, api_key,
        description if description else None
    )

    print(f"\n✓ Profile '{profile_name}' created successfully!")
    print(f"\nUsage: python3 odoo_xmlrpc.py --profile {profile_name} [other args]")
```

### Shell Alias for Transition
```bash
# Add to ~/.bashrc or ~/.zshrc for easier transition
alias odoo-query-dev='python3 odoo_xmlrpc.py --profile dev'
alias odoo-query-staging='python3 odoo_xmlrpc.py --profile staging'
alias odoo-query-prod='python3 odoo_xmlrpc.py --profile production'

# Usage
odoo-query-dev --action search_read --model sale.order --domain "[]"
```
