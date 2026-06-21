# PatZilla — Coolify Deployment

**PatZilla** is a modular patent information research platform with access to multiple patent data sources.

![PatZilla Screenshot](https://raw.githubusercontent.com/ip-tools/patzilla/main/patzilla-screenshot.png)

## ✅ Works Out of the Box — No API Keys Needed

Uses **free public sources** by default:

| Source | Coverage | Auth |
|---|---|---|
| **DPMA/DEPATISnet** | 🇩🇪 German patents | Free, no key |

## 🚀 Quick Deploy on Coolify

### 1. Deploy via Coolify

1. **Create new project** in Coolify
2. Choose **"Docker Compose"** as deployment type
3. Point to this repository (or paste the `docker-compose.yml`)
4. **Deploy!** — no environment variables required for basic usage

### 2. Access PatZilla

```
http://your-coolify-domain:6543/navigator/
```

### 3. (Optional) Add EPO/OPS for 80+ Country Coverage

Register for free at 👉 **https://developers.epo.org/**

Once approved, add these env vars in Coolify:

| Variable | Description |
|---|---|
| `EPO_OPS_KEY` | Consumer Key from EPO |
| `EPO_OPS_SECRET` | Consumer Secret from EPO |

Then redeploy. PatZilla will automatically detect and enable EPO/OPS.

---

## Data Sources

### Free (No API Key)
| Source | Coverage | Description |
|---|---|---|
| **DPMA/DEPATISnet** | 🇩🇪 Germany | German Patent Office full-text search |

### Free (Requires Registration)
| Source | Coverage | Description |
|---|---|---|
| **EPO/OPS** | 🌐 80+ countries | European Patent Office — best free option |

### Paid (Optional)
| Source | Coverage | Description |
|---|---|---|
| **IFI CLAIMS** | 🌐 Global | Professional patent database |
| **depa.tech** | 🌐 Global | MTC patent data |

---

## Features

- 🔍 **Multi-source patent search** — Query across patent databases
- 📄 **Full-text & PDF access** — View patent documents inline
- 📁 **Dossier management** — Organize collections with ratings & comments
- 🤝 **Sharing & collaboration** — Share results with colleagues
- 🖥️ **Responsive UI** — Works on desktop, tablet, mobile
- 🔌 **REST API** — Full programmatic access
- 💻 **CLI** — Command-line for scripting

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `EPO_OPS_KEY` | ❌ | empty | EPO/OPS Consumer Key |
| `EPO_OPS_SECRET` | ❌ | empty | EPO/OPS Consumer Secret |
| `PATZILLA_PORT` | ❌ | `6543` | Web UI port |

## Architecture

```
┌──────────────────┐     ┌──────────────┐
│   PatZilla App   │────▶│   MongoDB 6  │
│  (Python/Pyramid)│     │              │
│   Port 6543      │     │              │
└──────────────────┘     └──────────────┘
        │
        ▼
┌──────────────────┐
│  DPMA/DEPATISnet │  ← Free, works now
│  EPO/OPS         │  ← Free, add later
│  IFI, depa.tech  │  ← Paid, optional
└──────────────────┘
```

## Links

- [PatZilla GitHub](https://github.com/ip-tools/patzilla)
- [PatZilla Docs](https://docs.ip-tools.org/patzilla/)
- [EPO/OPS Registration](https://developers.epo.org/)
- [DEPATISnet](https://depatisnet.dpma.de/)
