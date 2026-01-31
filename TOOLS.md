# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

---

## 🖥️ My Environment (Atlas)

**Desktop:** Ubuntu 24.04 GNOME
**RAM:** 19GB available (no memory constraints)
**Runtime:** Node.js v22.22.0

### JS Runtimes
- Node: /usr/bin/node (v22.22.0)
- Bun: ~/.bun/bin/bun
- npm, pnpm, yarn all available

### Browser Stack
- **Primary:** Puppeteer (already installed, preferred)
- **Chrome:** ~/.config/google-chrome or google-chrome-for-testing
- **Fallback:** Puppeteer's bundled Chromium

### Media Tools
- **FFmpeg:** /usr/bin/ffmpeg (v6.1.1)
- **ImageMagick:** /usr/bin/convert, identify

---

## 🧩 Preferred CLI Utilities

### File Operations
- `fzf` — fuzzy finder (fast, minimal deps)
- `ripgrep` (rg) — search
- `fd` — find replacement (faster, better defaults)
- `bat` — cat replacement with syntax highlighting

### Terminal
- **Shell:** (check with `echo $SHELL`)
- `eza` or `exa` — ls replacement with better formatting
- `zoxide` — smart cd with frecency
- `fzf` — fuzzy search everything

### System Monitoring
- `htop` or `glances` — process/memory monitoring
- `jq` — JSON processing (installed)

---

## 🐳 Docker Note

Docker is NOT available on this system. Using:
- Puppeteer for browser automation
- Native CLI tools where possible
- Node.js scripts for container-like isolation when needed

---

## 📦 My Preferred npm Global Packages

(To be installed based on my needs)
- `tldr` — simplified man pages
- `speed-test` — network speed test
- `htop` or `glances` if node version available

---

## 🔧 Tool Preferences

| Task | Preferred Tool |
|------|----------------|
| JSON parsing | `jq` |
| Text search | `ripgrep` |
| File find | `fd` |
| Fuzzy search | `fzf` |
| Browser automation | Puppeteer |
| Image processing | ImageMagick |
| Video processing | FFmpeg |

---

## 📝 Notes to Self

- Don't install Docker if not needed — native tools + Node are sufficient
- Use puppeteer instead of selenium/playwright (already installed)
- If a tool isn't available, check if Node alternative exists first
- Keep ~5GB RAM free for browser automation headroom

---

## 🔌 External Services

### Moltbook API
**Critical Bug:** Moltbook's API has an HTTP/2 issue — headers return instantly but the response body hangs indefinitely.

**Fix:** Always use `--http1.1` flag when curling Moltbook API:
```bash
curl -s --http1.1 "https://www.moltbook.com/api/v1/..."
```

**Affected scripts:**
- `scripts/moltbook-post.sh` — posting to Moltbook
- `scripts/moltbook-research.sh` — fetching posts

---

## 🔌 MCP Integrations

### rtfmbro MCP (Package Documentation)
**Endpoint:** `https://rtfmbro.smolosoft.dev/mcp/`

**Authentication Pattern:**
1. GET request to establish session → session ID in `mcp-session-id` **header** (not SSE data)
2. POST requests include `mcp-session-id` header
3. Accept header: `Accept: text/event-stream, application/json`

**Common Error -32602 (Invalid params):**
- Check that params match exact expected names: `package`, `version`, `ecosystem`
- Ecosystem values: `pypi`, `npm`, `spm`, `github`

**Client:** `system/api-clients/rtfmbro/client.ts`

---

## 🛠️ Custom CLI Tools

### 🛸 Fleet Commander (Task Tracker)
Manage tasks and sub-agents. **USE THIS.**
- **List Tasks:** `node scripts/tasks.cjs list`
- **Spawn Agent:** `node scripts/tasks.cjs spawn "Title" --priority high`
- **Assign Task:** `node scripts/tasks.cjs assign <taskId> <agentId>`
- **Mark Done:** `node scripts/tasks.cjs done <id>`

### Dashboard Notes
Access notes left by Jordan on the dashboard.
- **List:** `node scripts/notes.cjs list`
- **Search:** `node scripts/notes.cjs search "query"`
- **Refresh:** `node scripts/notes.cjs refresh`

### Dashboard Ledger
Update the activity feed on the dashboard.
- **Update:** `node scripts/ledger.cjs "Message" [type]`

---

*This is my environment. Build it to work for me.*
