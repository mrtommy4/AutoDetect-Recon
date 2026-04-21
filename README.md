🚀 Auto Detect - Advanced Recon Suite
Auto Detect is an automated Bash script designed to drastically simplify and accelerate the Information Gathering and Enumeration phases during CTFs (Capture The Flag) or penetration testing engagements.

Instead of manually running dozens of individual commands, this tool orchestrates industry-standard tools into a single interactive interface, allowing you to selectively deploy modules based on the target's context.

✨ Key Features
Interactive Modularity: Toggle specific modules (Nmap, Nikto, Gobuster) via simple (y/n) prompts.

Clean Terminal UI: The terminal displays only progress status and success messages, preventing the "wall of text" clutter common with heavy scanning tools.

Professional Logging: Every session generates a dedicated .txt report in the /reports directory, organized by target and timestamp.

ANSI Log Cleaning: Reports are automatically stripped of ANSI color codes, making them perfectly readable in any text editor (Notepad, Leafpad, etc.).

Passive Subdomain Discovery: Integrates with crt.sh to extract subdomains via SSL certificates without directly interacting with the target server.

🛠️ Built-in Toolset
The suite leverages the power of these essential security tools:

Whois & Dig: For DNS analysis and domain intelligence.

Nmap: Utilizing NSE scripts (vuln, auth) for service detection and known exploit identification.

WhatWeb: For identifying the web technology stack (CMS, Server, Plugins).

Nikto: For discovering web server vulnerabilities and exposed sensitive files.

Gobuster: For high-speed directory and file brute-forcing.



📦 Installation & Usage
Bash
 Clone the repository
git clone https://github.com/YOUR-USERNAME/AutoDetect-Recon.git

 Navigate to the directory
cd AutoDetect-Recon

Grant execution permissions
chmod +x autotrack.sh

 Run the tool (sudo is required for Nmap Stealth Scans)
sudo ./autotrack.sh
Note: The script automatically checks for jq and attempts to install it if missing to ensure proper subdomain extraction.

🛡️ Disclaimer
This tool is for educational purposes and authorized security testing only. Use it responsibly and only on targets you have explicit permission to test.
