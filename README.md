# 🛡️ Recon‑Enhanced

A **professional‑grade reconnaissance automation framework** that basically works like a mini recon engine for any target domain.  
Built for cybersecurity researchers, Blue/Red team beginners, and OSINT lovers who want faster recon without doing everything manually.

---

## 🚀 Features

Automated multi‑phase recon workflow:

- **Passive Subdomain Enumeration** → `subfinder`, `assetfinder`
- **Live Host + Tech Detection** → `httpx` + `jq`
- **Subdomain Takeover Scan** → `subdominator`
- **Archived URL Discovery** → `gau`, `waymore`
- **JavaScript File Extraction**
- **Active Port Scanning** → `nmap`
- **Interactive Hacker‑Themed HTML Report**
- Searchable + sortable recon dashboard UI
- Structured output storage per phase

---

## 🧰 Prerequisites

Install base dependencies and tools:

```bash
sudo apt update && sudo apt install -y golang-go pipx nmap jq
pipx ensurepath
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
pipx install subdominator
pipx install waymore
