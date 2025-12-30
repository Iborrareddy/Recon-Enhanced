# 🛡️ Recon-Enhanced

<p>
  <strong style="font-size:17px;">
    A professional-grade reconnaissance automation framework that basically works like a mini recon engine for any target domain.
  </strong><br>
  <em>
    Built for cybersecurity researchers, Blue/Red team beginners, and OSINT lovers who want faster recon without doing everything manually.
  </em>
</p>

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
```
---


## ⚠️ Disclaimer

This tool is built for **security research and authorized penetration testing only**.  
Any misuse, unauthorized scanning, or illegal activity performed using this framework is **not the responsibility of the author or contributors**.

---

## 📥 Installation

Clone the repository and set permissions:

```bash
git clone https://github.com/Iborrareddy/Recon-Enhanced.git
cd Recon-Enhanced
chmod +x ReconEnhanced.sh
```

---

## ▶️ Usage

Run reconnaissance on a target domain:

```bash
./ReconEnhanced.sh example.com
```

After completion, open the generated HTML report:

```bash
open example.com_recon_enhanced/report.html
```

---

## 📁 Output Structure

```
example.com_recon_enhanced/
├── subdomains/
├── takeover/
├── urls/
├── active/
└── report.html
```

---

## 📊 Report Dashboard

The interactive HTML report includes:

- Recon summary + stats chart
- Live hosts table with detected technologies
- Subdomain takeover vulnerability log
- Archived URLs
- JavaScript file list
- Nmap port scan results
- Search filter across sections
- Sortable table columns

---

## ⚡ Quick Reference

| Phase | Task |
|---:|---|
| 1 | Passive subdomain enumeration |
| 2 | Active probing & tech detection |
| 3 | Subdomain takeover scan |
| 4 | URL archive discovery |
| 5 | JavaScript extraction |
| 6 | Active port scanning |
| 7 | Interactive HTML report generation |

---

## 📌 Notes

- Only run on **authorized targets**
- Unauthorized scanning is **illegal and unethical**
- Keep recon tools updated for best results

---

## 🧑‍💻 Author

**Madhan Mohan Reddy Borra**  
Cybersecurity Enthusiast | Recon Automation Developer | Blue/Purple Team Aspirant

---

## ⭐ Contribute

Feel free to:

- ⭐ Star the repository
- 🍴 Fork and extend it
- 🐛 Report bugs or open issues
- 🔧 Submit pull requests (PRs)

---

## 📄 License

This project is licensed under the **MIT License** – free to use, modify, and distribute.

---

