#!/bin/bash
# ===========================================
# PatZilla Entrypoint — Coolify deployment
# Generates config from environment variables
# Uses FREE sources by default, EPO/OPS optional
# ===========================================
set -e

CONFIG_FILE="/etc/patzilla/patzilla.ini"
VENDORS_FILE="/etc/patzilla/vendors.ini"
MONGO_URI="${MONGO_URI:-mongodb://mongodb:27017/patzilla}"

echo "==========================================="
echo "  PatZilla IP Navigator — Starting..."
echo "==========================================="

# -------------------------------------------
# Create vendors.ini if it doesn't exist
# -------------------------------------------
if [ ! -f "$VENDORS_FILE" ]; then
    cat > "$VENDORS_FILE" << EOF
# vendors.ini — empty by default
# Vendor-specific overrides can be added here
EOF
    echo "[✓] Created $VENDORS_FILE"
fi

# -------------------------------------------
# Detect available data sources
# -------------------------------------------
DATASOURCES="depatisnet"

if [ -n "$EPO_OPS_KEY" ] && [ "$EPO_OPS_KEY" != "not-configured" ]; then
    DATASOURCES="ops, depatisnet"
    echo "[✓] EPO/OPS: Configured (key: ${EPO_OPS_KEY:0:8}...)"
else
    echo "[!] EPO/OPS: Not configured — using free sources only"
fi

echo "[✓] DPMA/DEPATISnet: Enabled (free, no key needed)"
echo "[✓] MongoDB: $MONGO_URI"
echo ""

# -------------------------------------------
# Generate PatZilla configuration
# -------------------------------------------
cat > "$CONFIG_FILE" << EOF
# ===============================================
# PatZilla application configuration (auto-generated)
# ===============================================

[main]
include     = vendors.ini

[ip_navigator]
vendors     = patzilla
datasources = ${DATASOURCES}
datasources_protected_fields = api_consumer_key, api_consumer_secret, api_uri, api_username, api_password
development_mode    = false

# ====================
# Vendor configuration
# ====================

[vendor:patzilla]
organization        = PatZilla
productname         = PatZilla IP Navigator
productname_html    = <span class="header-logo">PatZilla <i class="circle-icon">IP</i> Navigator</span>
page_title          = Patent search
copyright_html      = &copy; 2013-2024, <a href="https://docs.ip-tools.org/patzilla/" class="incognito pointer" target="_blank">The PatZilla Developers</a>
stylesheet_uri      = /static/patzilla.css

# ========================
# Datasource: EPO/OPS (optional — needs free API key)
# ========================

[datasource:ops]
api_consumer_key    = ${EPO_OPS_KEY:-not-configured}
api_consumer_secret = ${EPO_OPS_SECRET:-not-configured}
fulltext_enabled    = true
fulltext_countries  = EP, WO, AT, BE, BG, CA, CH, CY, CZ, DK, EE, ES, FR, GB, GR, HR, IE, IT, LT, LU, MC, MD, ME, NO, PL, PT, RO, RS, SE, SK

# ========================
# Datasource: DPMA/DEPATISnet (FREE — no key needed)
# German Patent Office, covers DE patents + citations
# ========================

[datasource:depatisnet]

# ========================
# Datasource: DEPATISconnect (optional)
# ========================

[datasource:depatisconnect]
fulltext_enabled    = true
fulltext_countries  = DE, US

# ========================
# Datasource: IFI CLAIMS (optional — paid professional database)
# ========================

[datasource:ificlaims]
api_uri             = ${IFI_CLAIMS_URI:-not-configured}
api_uri_json        = ${IFI_CLAIMS_URI_JSON:-not-configured}
api_username        = ${IFI_CLAIMS_USER:-not-configured}
api_password        = ${IFI_CLAIMS_PASS:-not-configured}
fulltext_enabled    = true
fulltext_countries  = BE, CA, CN, FR, GB, IN, JP, KR, LU, NL, RU
details_enabled     = true
details_countries   = CN, IN, KR

# ========================
# Datasource: depa.tech (optional — paid)
# ========================

[datasource:depatech]
api_uri             = ${DEPATECH_URI:-not-configured}
api_username        = ${DEPATECH_USER:-not-configured}
api_password        = ${DEPATECH_PASS:-not-configured}

# ========================
# Email/SMTP configuration (optional)
# ========================

[smtp]
hostname = ${SMTP_HOST:-localhost}
port     = ${SMTP_PORT:-587}
tls      = true
username = ${SMTP_USER:-}
password = ${SMTP_PASS:-}

[email_addressbook]
from    = PatZilla <noreply@patzilla.local>
reply   = PatZilla Support <support@patzilla.local>
support = PatZilla Support <support@patzilla.local>
system  = PatZilla System <system@patzilla.local>
purchase = PatZilla Sales <sales@patzilla.local>

[email_content]
subject_prefix = [PatZilla]
body = Automated message from PatZilla.
signature = PatZilla IP Navigator

# ========================
# Pyramid / WSGI server
# ========================

[filter:prefix-middleware]
use = egg:PasteDeploy#prefix

[app:main]
use = egg:patzilla#web
filter-with = prefix-middleware

pyramid.reload_templates = false
pyramid.debug_authorization = false
pyramid.debug_notfound = false
pyramid.debug_routematch = false
pyramid.default_locale_name = en
pyramid.includes =

# Database configuration
mongodb.patzilla.uri = ${MONGO_URI}

# Cache settings
cache.url = ${MONGO_URI}
cache.regions = search, medium, longer, static
cache.key_length = 512

cache.search.type = ext:mongodb
cache.search.sparse_collection = true

cache.medium.type = mongodb_gridfs
cache.medium.sparse_collection = true

cache.longer.type = mongodb_gridfs
cache.longer.sparse_collection = true

cache.static.type = mongodb_gridfs
cache.static.sparse_collection = true

cache.search.expire = 7200
cache.medium.expire = 86400
cache.longer.expire = 604800
cache.static.expire = 2592000

# WSGI server
[server:main]
use = egg:waitress#main
host = 0.0.0.0
port = 6543

# Logging
[loggers]
keys = root, patzilla

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = INFO
handlers = console

[logger_patzilla]
level = INFO
handlers =
qualname = patzilla

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(asctime)s %(levelname)-8.8s [%(name)-40s][%(threadName)s] %(message)s
EOF

echo "[✓] Configuration generated at $CONFIG_FILE"
echo ""
echo "==========================================="
echo "  Data Sources:"
echo "  • DPMA/DEPATISnet — German patents (FREE)"
if [ -n "$EPO_OPS_KEY" ] && [ "$EPO_OPS_KEY" != "not-configured" ]; then
    echo "  • EPO/OPS — 80+ countries (active)"
else
    echo "  • EPO/OPS — not configured (set EPO_OPS_KEY to enable)"
fi
echo "==========================================="
echo ""
echo "Starting PatZilla on port 6543..."
echo "Access at: http://localhost:6543/navigator/"
echo ""

# -------------------------------------------
# Start PatZilla
# -------------------------------------------
exec pserve "$CONFIG_FILE"
