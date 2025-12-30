#!/bin/bash

# ==============================================================================
# Recon-Enhanced Script (Final Hacker Edition)
#
# Description:
# This script is a professional-grade reconnaissance framework, automating a
# multi-phase workflow inspired by cybersecurity professionals. This final
# version features a streamlined toolset and a refined hacker-themed dashboard.
#
#
# Usage:
#   ./recon-enhanced.sh <domain>
#
# ==============================================================================

# --- Colors ---
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
NC="\033[0m"

# --- Initial Checks ---
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <domain>${NC}"
    exit 1
fi

# --- Setup ---
TARGET=$1
OUTPUT_DIR="${TARGET}_recon_enhanced"
SUBDOMAINS_DIR="$OUTPUT_DIR/subdomains"
URLS_DIR="$OUTPUT_DIR/urls"
ACTIVE_DIR="$OUTPUT_DIR/active"
TAKEOVER_DIR="$OUTPUT_DIR/takeover"
REPORT_FILE_HTML="$OUTPUT_DIR/report.html"

# --- Banner ---
echo -e "${CYAN}===========================================${NC}"
echo -e "${PURPLE}     Recon-Enhanced Execution Started     ${NC}"
echo -e "${CYAN}===========================================${NC}"
echo -e "${YELLOW}Target Domain:${NC} $TARGET"
echo -e "${YELLOW}Output Directory:${NC} $OUTPUT_DIR"
echo -e "${CYAN}===========================================${NC}"

# --- Tool Checks ---
echo -e "\n${BLUE}[*] Checking for required tools...${NC}"
tools=("subfinder" "assetfinder" "httpx" "subdominator" "gau" "waymore" "nmap" "jq")
for tool in "${tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || { echo -e >&2 "${RED}$tool is not installed. Aborting.${NC}"; exit 1; }
done
echo -e "${GREEN}[+] All tools are present.${NC}"

# --- Create Directories ---
mkdir -p "$OUTPUT_DIR" "$SUBDOMAINS_DIR" "$URLS_DIR" "$ACTIVE_DIR" "$TAKEOVER_DIR"

# --- Phase 1: Passive Subdomain Enumeration ---
echo -e "\n${BLUE}[Phase 1] Starting Passive Subdomain Enumeration...${NC}"
subfinder -d "$TARGET" -o "$SUBDOMAINS_DIR/subfinder.txt" -silent
assetfinder --subs-only "$TARGET" > "$SUBDOMAINS_DIR/assetfinder.txt"
cat "$SUBDOMAINS_DIR"/*.txt | sort -u > "$SUBDOMAINS_DIR/all_subs.txt"
all_subs_count=$(wc -l < "$SUBDOMAINS_DIR/all_subs.txt")
echo -e "${GREEN}[+] Phase 1 Complete. Found $all_subs_count unique potential subdomains.${NC}"

# --- Phase 2: Active Probing & Tech Detection ---
echo -e "\n${BLUE}[Phase 2] Starting Active Probing & Tech Detection...${NC}"
httpx -l "$SUBDOMAINS_DIR/all_subs.txt" -threads 200 \
-tech-detect -json -o "$SUBDOMAINS_DIR/live_subs_tech.json" -silent

if [ -s "$SUBDOMAINS_DIR/live_subs_tech.json" ]; then
    jq -r '.url' < "$SUBDOMAINS_DIR/live_subs_tech.json" > "$SUBDOMAINS_DIR/live_subs.txt"
else
    touch "$SUBDOMAINS_DIR/live_subs.txt"
fi

live_subs_count=$(wc -l < "$SUBDOMAINS_DIR/live_subs.txt")
dead_hosts_count=$((all_subs_count - live_subs_count))
echo -e "${GREEN}[+] Phase 2 Complete. Found $live_subs_count live web servers.${NC}"

# --- Phase 3: Subdomain Takeover Scan ---
echo -e "\n${BLUE}[Phase 3] Checking for Subdomain Takeover...${NC}"
subdominator -l "$SUBDOMAINS_DIR/all_subs.txt" -o "$TAKEOVER_DIR/takeover.txt" --silent
takeover_count=0
if [ -f "$TAKEOVER_DIR/takeover.txt" ]; then
    takeover_count=$(grep -c . "$TAKEOVER_DIR/takeover.txt")
fi
echo -e "${GREEN}[+] Phase 3 Complete. Found $takeover_count potential takeover vulnerabilities.${NC}"

# --- Phase 4: Archived URL Discovery ---
echo -e "\n${BLUE}[Phase 4] Starting Archived URL Discovery...${NC}"
gau --threads 50 "$TARGET" > "$URLS_DIR/gau.txt" 2>/dev/null
waymore -i "$TARGET" -mode U -oU "$URLS_DIR/waymore.txt" 2>/dev/null
cat "$URLS_DIR"/*.txt | sort -u > "$URLS_DIR/all_urls.txt"
all_urls_count=0
if [ -f "$URLS_DIR/all_urls.txt" ]; then
    all_urls_count=$(wc -l < "$URLS_DIR/all_urls.txt")
fi
echo -e "${GREEN}[+] Phase 4 Complete. Found $all_urls_count unique archived URLs.${NC}"

# --- Phase 5: JavaScript File Discovery ---
echo -e "\n${BLUE}[Phase 5] Discovering JavaScript Files...${NC}"
if [ -s "$URLS_DIR/all_urls.txt" ]; then
    cat "$URLS_DIR/all_urls.txt" | grep "\.js" | sort -u > "$URLS_DIR/js_files.txt"
fi
js_files_count=0
if [ -f "$URLS_DIR/js_files.txt" ]; then
    js_files_count=$(wc -l < "$URLS_DIR/js_files.txt")
fi
echo -e "${GREEN}[+] Phase 5 Complete. Found $js_files_count unique JavaScript files.${NC}"

# --- Phase 6: Active Scanning ---
echo -e "\n${BLUE}[Phase 6] Starting Active Scanning...${NC}"
LIVE_SUBS_FILE="$SUBDOMAINS_DIR/live_subs.txt"
if [ -s "$LIVE_SUBS_FILE" ]; then
    echo -e "${YELLOW} -> Running nmap on the top 10 live subdomains...${NC}"
    head -n 10 "$LIVE_SUBS_FILE" | while read -r url; do
        clean_name=$(echo "$url" | sed -e 's|https\?://||' -e 's|/||g')
        nmap -sV -sC -T4 "$clean_name" -oN "$ACTIVE_DIR/nmap_$clean_name.txt"
    done
    echo -e "${GREEN} -> Nmap scans complete.${NC}"
else
    echo -e "${YELLOW}[!] No live hosts found. Skipping Nmap scans.${NC}"
fi

# --- Phase 7: Report Generation ---
echo -e "\n${BLUE}[Phase 7] Generating Interactive HTML Report...${NC}"

# Prepare data for HTML
live_subs_html="<tr><td colspan='3' style='text-align:center;'>No live hosts found.</td></tr>"
if [ -s "$SUBDOMAINS_DIR/live_subs_tech.json" ]; then
    live_subs_html=$(jq -r '
        . as $data |
        "
        <tr data-search-item>
            <td><a href=\(.url) target=\"_blank\">\(.url)</a></td>
            <td>\(."status-code")</td>
            <td>\(.tech // "N/A")</td>
        </tr>
        "
    ' "$SUBDOMAINS_DIR/live_subs_tech.json" | tr -d '\n')
fi

all_urls_data="No archived URLs found."
if [ -s "$URLS_DIR/all_urls.txt" ]; then
    all_urls_data=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$URLS_DIR/all_urls.txt")
fi

js_files_data="No JavaScript files found."
if [ -s "$URLS_DIR/js_files.txt" ]; then
    js_files_data=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$URLS_DIR/js_files.txt")
fi

takeover_data="No potential takeover vulnerabilities found."
if [ -s "$TAKEOVER_DIR/takeover.txt" ]; then
    takeover_data=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$TAKEOVER_DIR/takeover.txt")
fi

nmap_reports="<p>No Nmap scans were run.</p>"
if [ -n "$(ls -A "$ACTIVE_DIR"/nmap_*.txt 2>/dev/null)" ]; then
    nmap_reports=""
    for file in "$ACTIVE_DIR"/nmap_*.txt; do
        if [ -f "$file" ]; then
            host=$(basename "$file" .txt | sed 's/nmap_//')
            file_content=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$file")
            nmap_reports+="<div class='nmap-report' data-search-item><h3>$host</h3><pre><code>$file_content</code></pre></div>"
        fi
    done
fi

cat <<EOF > "$REPORT_FILE_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recon Enhanced Report: ${TARGET}</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --bg-color: #0d1117; --sidebar-bg: #161b22; --card-bg: #161b22;
            --text-color: #c9d1d9; --secondary-text-color: #8b949e; --accent-color: #58a6ff;
            --border-color: #30363d; --green: #3fb950; --magenta: #bc3fbc; --cyan: #39c5cf;
            --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            --mono-font: "SF Mono", "Menlo", "Courier New", monospace;
        }
        body { font-family: var(--font-family); background-color: var(--bg-color); color: var(--text-color); margin: 0; display: flex; height: 100vh; overflow: hidden; }
        #sidebar { width: 240px; background-color: var(--sidebar-bg); padding: 2rem 0; flex-shrink: 0; border-right: 1px solid var(--border-color); display: flex; flex-direction: column; }
        #sidebar h1 { 
            font-family: var(--mono-font);
            font-size: 1.5rem; padding: 0 1.5rem; margin-bottom: 0.5rem; word-wrap: break-word; font-weight: 600; 
            color: var(--cyan); text-shadow: 0 0 8px rgba(57, 197, 207, 0.7);
        }
        #sidebar .sidebar-meta { font-size: 0.8rem; color: var(--secondary-text-color); padding: 0 1.5rem; margin-bottom: 2rem; }
        #sidebar nav { flex-grow: 1; }
        #sidebar nav a { display: flex; align-items: center; gap: 10px; padding: 0.75rem 1.5rem; text-decoration: none; color: var(--secondary-text-color); font-weight: 500; transition: background-color 0.2s ease, color 0.2s ease; border-left: 3px solid transparent; }
        #sidebar nav a.active, #sidebar nav a:hover { background-color: rgba(88, 166, 255, 0.1); color: var(--accent-color); border-left-color: var(--accent-color); }
        #main-content { flex-grow: 1; display: flex; flex-direction: column; height: 100vh; }
        header { padding: 1rem 2rem; border-bottom: 1px solid var(--border-color); background-color: var(--sidebar-bg); display: flex; justify-content: space-between; align-items: center; }
        #search-box { width: 400px; padding: 0.75rem 1rem; background-color: var(--bg-color); border-radius: 6px; border: 1px solid var(--border-color); color: var(--text-color); font-size: 1rem; outline: none; transition: all 0.2s ease; }
        #search-box:focus { border-color: var(--accent-color); box-shadow: 0 0 0 3px rgba(88, 166, 255, 0.3); }
        .header-stats span { margin-left: 1rem; color: var(--secondary-text-color); }
        .content-section { display: none; padding: 2.5rem; overflow-y: auto; flex-grow: 1; }
        .content-section.active { display: block; }
        h2 { font-size: 2.2rem; margin-top: 0; margin-bottom: 2rem; font-weight: 600; background: linear-gradient(to right, var(--cyan), var(--magenta)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid var(--border-color); }
        th { color: var(--secondary-text-color); font-weight: 600; cursor: pointer; user-select: none; }
        th:hover { background-color: rgba(255, 255, 255, 0.05); }
        td a { color: var(--accent-color); text-decoration: none; }
        pre { background-color: #010409; padding: 1rem; border-radius: 8px; white-space: pre-wrap; word-wrap: break-word; font-family: var(--mono-font); }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; margin-bottom: 3rem; }
        .stat-card { background-color: var(--card-bg); padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border-color); transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 0 20px rgba(88, 166, 255, 0.3); }
        .stat-card h3 { margin: 0 0 0.5rem 0; font-size: 1rem; color: var(--secondary-text-color); font-weight: 500; }
        .stat-card p { margin: 0; font-size: 2.5rem; font-weight: 600; color: var(--text-color); }
        .overview-main { display: flex; gap: 2rem; align-items: flex-start; }
        .chart-container { flex-grow: 1; max-width: 400px; height: 400px; }
    </style>
</head>
<body>
    <aside id="sidebar">
        <h1>RECON ENHANCED</h1>
        <div class="sidebar-meta">
            Target: ${TARGET}<br>
            Generated: $(date +"%Y-%m-%d %H:%M:%S")
        </div>
        <nav>
            <a href="#" class="nav-link active" onclick="showSection('overview', this)">Overview</a>
            <a href="#" class="nav-link" onclick="showSection('subdomains', this)">Live Hosts</a>
            <a href="#" class="nav-link" onclick="showSection('takeover', this)">Vulnerabilities</a>
            <a href="#" class="nav-link" onclick="showSection('urls', this)">URL Archive</a>
            <a href="#" class="nav-link" onclick="showSection('jsfiles', this)">JavaScript Files</a>
            <a href="#" class="nav-link" onclick="showSection('ports', this)">Port Scans</a>
        </nav>
    </aside>
    <main id="main-content">
        <header>
            <input type="text" id="search-box" placeholder="Search reconnaissance data...">
            <div class="header-stats">
                <span><span style="color:var(--cyan)">${all_subs_count}</span> Subdomains</span>
                <span><span style="color:var(--green)">${live_subs_count}</span> Live</span>
                <span><span style="color:var(--magenta)">${takeover_count}</span> Vulns</span>
            </div>
        </header>
        <section id="overview" class="content-section active">
            <h2>Reconnaissance Overview</h2>
            <div class="stats-grid">
                <div class="stat-card" style="border-left: 3px solid var(--cyan);"><h3>TOTAL SUBDOMAINS</h3><p>${all_subs_count}</p></div>
                <div class="stat-card" style="border-left: 3px solid var(--green);"><h3>LIVE HOSTS</h3><p>${live_subs_count}</p></div>
                <div class="stat-card" style="border-left: 3px solid var(--accent-color);"><h3>ARCHIVED URLS</h3><p>${all_urls_count}</p></div>
                 <div class="stat-card" style="border-left: 3px solid yellow;"><h3>JS FILES</h3><p>${js_files_count}</p></div>
                <div class="stat-card" style="border-left: 3px solid var(--magenta);"><h3>VULNERABILITIES</h3><p>${takeover_count}</p></div>
            </div>
            <div class="overview-main">
                 <div class="chart-container">
                    <canvas id="overviewChart"></canvas>
                </div>
            </div>
        </section>
        <section id="subdomains" class="content-section">
            <h2>Live Hosts (${live_subs_count})</h2>
            <table id="subdomains-table">
                <thead><tr><th onclick="sortTable(0, 'subdomains-table')">URL</th><th onclick="sortTable(1, 'subdomains-table')">Status</th><th onclick="sortTable(2, 'subdomains-table')">Technologies</th></tr></thead>
                <tbody>${live_subs_html}</tbody>
            </table>
        </section>
        <section id="takeover" class="content-section">
            <h2>Vulnerabilities</h2>
            <pre>${takeover_data}</pre>
        </section>
        <section id="urls" class="content-section">
            <h2>URL Archive (${all_urls_count})</h2>
            <pre>${all_urls_data}</pre>
        </section>
        <section id="jsfiles" class="content-section">
            <h2>JavaScript Files (${js_files_count})</h2>
            <pre>${js_files_data}</pre>
        </section>
        <section id="ports" class="content-section">
            <h2>Port Scans (Nmap)</h2>
            <div>${nmap_reports}</div>
        </section>
    </main>
    <script>
        function showSection(sectionId, element) {
            document.querySelectorAll('.content-section').forEach(s => s.classList.remove('active'));
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            document.getElementById(sectionId).classList.add('active');
            if (element) { element.classList.add('active'); }
        }

        const searchInput = document.getElementById('search-box');
        searchInput.addEventListener('keyup', (e) => {
            const searchTerm = e.target.value.toLowerCase();
            document.querySelectorAll('[data-search-item]').forEach(item => {
                item.style.display = item.textContent.toLowerCase().includes(searchTerm) ? '' : 'none';
            });
        });
        
        const ctx = document.getElementById('overviewChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Live Hosts', 'Dead Hosts', 'Vulnerabilities'],
                datasets: [{
                    label: 'Host Status',
                    data: [${live_subs_count}, ${dead_hosts_count}, ${takeover_count}],
                    backgroundColor: ['#39c5cf', '#8b949e', '#bc3fbc'],
                    borderColor: '#0d1117',
                    borderWidth: 4,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { color: '#c9d1d9', font: { size: 14 } } } },
                cutout: '70%'
            }
        });

        function sortTable(columnIndex, tableId) {
            const table = document.getElementById(tableId);
            const tbody = table.tBodies[0];
            const rows = Array.from(tbody.rows);
            const header = table.tHead.rows[0].cells[columnIndex];
            const isAsc = header.classList.contains('asc');
            const direction = isAsc ? -1 : 1;

            table.tHead.rows[0].querySelectorAll('th').forEach(th => th.classList.remove('asc', 'desc'));
            header.classList.toggle('asc', !isAsc);
            header.classList.toggle('desc', isAsc);

            rows.sort((a, b) => {
                const aText = a.cells[columnIndex].innerText.trim();
                const bText = b.cells[columnIndex].innerText.trim();
                const aNum = parseFloat(aText);
                const bTextNum = parseFloat(bText);

                if (!isNaN(aNum) && !isNaN(bNum)) {
                    return (aNum - bNum) * direction;
                } else {
                    return aText.localeCompare(bText) * direction;
                }
            });
            rows.forEach(row => tbody.appendChild(row));
        }
    </script>
</body>
</html>
EOF

echo -e "${GREEN}[+] HTML report generated successfully!${NC}"
echo -e "\n${CYAN}===========================================${NC}"
echo -e "${PURPLE}       All tasks are complete!       ${NC}"
echo -e "${CYAN}===========================================${NC}"
echo -e "${YELLOW}Open the HTML report in your browser:${NC}"
echo -e "file://$(pwd)/$REPORT_FILE_HTML"
