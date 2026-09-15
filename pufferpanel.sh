#!/bin/bash

# ============================================================
#                 PUFFERPANEL INSTALLER
#                    Made By Heron
# ============================================================

set -e

# ---------- Colors ----------
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
WHITE="\033[97m"
GRAY="\033[90m"

# ---------- UI ----------
clear

echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    PUFFERPANEL INSTALLER                   ║"
echo "║                                                            ║"
echo "║                     Made By Heron                          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

sleep 1

echo -e "${GRAY}────────────────────────────────────────────────────────────${RESET}"
echo -e "${WHITE}${BOLD}Preparing PufferPanel installation...${RESET}"
echo -e "${GRAY}────────────────────────────────────────────────────────────${RESET}"
echo

# ---------- Root Check ----------
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[✘] Please run this installer as root.${RESET}"
    echo
    echo -e "${YELLOW}Example:${RESET}"
    echo "sudo bash pufferinstaller.sh"
    exit 1
fi

# ---------- Function ----------
run_step() {
    local title="$1"
    shift

    echo
    echo -e "${BLUE}${BOLD}┌─ ${title}${RESET}"
    echo -e "${GRAY}│${RESET} Running..."
    echo -e "${GRAY}│${RESET}"

    if "$@"; then
        echo -e "${GRAY}│${RESET} ${GREEN}✔ Completed${RESET}"
        echo -e "${BLUE}${BOLD}└────────────────────────────────────────────────────────${RESET}"
    else
        echo -e "${GRAY}│${RESET} ${RED}✘ Failed${RESET}"
        echo -e "${BLUE}${BOLD}└────────────────────────────────────────────────────────${RESET}"
        exit 1
    fi
}

# ---------- Updating ----------
run_step "Updating package lists" apt update

# ---------- Installing Dependencies ----------
run_step "Installing sudo" apt install -y sudo

# systemctl is normally provided by systemd.
if command -v systemctl >/dev/null 2>&1; then
    echo
    echo -e "${GREEN}✔ systemctl is already installed${RESET}"
else
    run_step "Installing systemd / systemctl" apt install -y systemd
fi

# ---------- PufferPanel Repository ----------
echo
echo -e "${CYAN}${BOLD}┌─ Adding PufferPanel Repository${RESET}"
echo -e "${GRAY}│${RESET} Connecting to packagecloud..."
echo -e "${GRAY}│${RESET}"

if curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh?any=true | sudo bash; then
    echo -e "${GRAY}│${RESET} ${GREEN}✔ Repository added${RESET}"
else
    echo -e "${GRAY}│${RESET} ${RED}✘ Repository installation failed${RESET}"
    echo -e "${CYAN}${BOLD}└────────────────────────────────────────────────────────${RESET}"
    exit 1
fi

echo -e "${CYAN}${BOLD}└────────────────────────────────────────────────────────${RESET}"

# ---------- Made By ----------
echo
echo -e "${MAGENTA}${BOLD}                 Made By Heron${RESET}"

# ---------- Update Again ----------
run_step "Refreshing package lists" apt update

# ---------- Install PufferPanel ----------
run_step "Installing PufferPanel" apt-get install -y pufferpanel

# ---------- Create User ----------
echo
echo -e "${CYAN}${BOLD}┌─ PufferPanel User Setup${RESET}"
echo -e "${GRAY}│${RESET} ${WHITE}Creating a PufferPanel administrator user.${RESET}"
echo -e "${GRAY}│${RESET} ${YELLOW}Please complete the prompts below.${RESET}"
echo -e "${CYAN}${BOLD}└────────────────────────────────────────────────────────${RESET}"
echo

sudo pufferpanel user add

# ---------- Enable / Start ----------
run_step "Enabling PufferPanel service" systemctl enable pufferpanel

run_step "Starting PufferPanel on port 8080" systemctl start pufferpanel

# ---------- Final Status ----------
echo
echo -e "${GREEN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║             ✔ PUFFERPANEL INSTALLED                       ║"
echo "║                                                            ║"
echo "║             Panel Port : 8080                             ║"
echo "║             Service    : Running                          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo
echo -e "${WHITE}${BOLD}Panel:${RESET} ${CYAN}http://YOUR_SERVER_IP:8080${RESET}"
echo
echo -e "${GRAY}Check status:${RESET}"
echo -e "${WHITE}systemctl status pufferpanel${RESET}"
echo
echo -e "${GRAY}Restart panel:${RESET}"
echo -e "${WHITE}systemctl restart pufferpanel${RESET}"
echo
echo -e "${GREEN}${BOLD}Installation complete. Enjoy PufferPanel!${RESET}"
echo
