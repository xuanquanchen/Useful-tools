#!/bin/bash

# ==============================================================================
# Env Manager: Auto-Detecting Outdated Packages & System Cleaner for macOS
#
# Description: 
#   A zero-config, plug-and-play shell script that automatically detects 
#   installed package managers (Homebrew, Pip, Conda, NPM, Yarn, Cargo, Gem).
#   It strictly LISTS outdated packages (without upgrading them automatically) 
#   and safely cleans up system caches to free up storage. It integrates with 
#   macOS native notifications and Calendar for monthly reporting.
#
# Usage:
#   1. Make executable: chmod +x env_manager.sh
#   2. Run manually: ./env_manager.sh
#   3. For automated monthly execution via launchd, please refer to the README.
#
# Note: 
#   All logs are written to ~/Documents/Env_Outdated_Report.txt to keep the 
#   terminal output completely clean during background execution.
# ==============================================================================

LOG_FILE="$HOME/Documents/Env_Outdated_Report.txt"
DATE_STR=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure standard and custom paths are available
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH" # Rust
if [ -d "$HOME/miniconda3/bin" ]; then export PATH="$HOME/miniconda3/bin:$PATH"; fi
if [ -d "$HOME/anaconda3/bin" ]; then export PATH="$HOME/anaconda3/bin:$PATH"; fi
if [ -d "/opt/homebrew/Caskroom/miniforge/base/bin" ]; then export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"; fi

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOG_FILE")
mkdir -p "$LOG_DIR" || { echo "Failed to create log directory: $LOG_DIR" >&2; exit 1; }

# Initialize the log file
echo "=== Environment Maintenance Report ($DATE_STR) ===" > "$LOG_FILE" || { echo "Failed to write report: $LOG_FILE" >&2; exit 1; }
echo "Scanning system for installed environments..." >> "$LOG_FILE"

# ==========================================
# Dynamic Detection & Maintenance Modules
# ==========================================

# 1. Homebrew (macOS Package Manager)
if command -v brew &> /dev/null; then
    echo -e "\n[Homebrew (Detected)]" >> "$LOG_FILE"
    if [ -f "/opt/homebrew/var/homebrew/locks/update" ]; then
        echo "Warning: Lock file detected, skipping brew update to prevent conflicts." >> "$LOG_FILE"
    else
        brew update >> "$LOG_FILE" 2>&1
    fi
    brew outdated >> "$LOG_FILE" 2>&1
    brew cleanup -s &> /dev/null
fi

# 2. Python / PIP (Global)
if command -v pip &> /dev/null; then
    echo -e "\n[PIP (Detected)]" >> "$LOG_FILE"
    pip list --outdated >> "$LOG_FILE" 2>&1
    pip cache purge &> /dev/null
fi

# 3. Conda (Data Science)
if command -v conda &> /dev/null; then
    echo -e "\n[Conda (Detected)]" >> "$LOG_FILE"
    conda update -n base -c conda-forge conda --dry-run >> "$LOG_FILE" 2>&1
    conda clean --all -y &> /dev/null
fi

# 4. Node.js / NPM (Frontend)
if command -v npm &> /dev/null; then
    echo -e "\n[NPM (Detected)]" >> "$LOG_FILE"
    npm outdated -g >> "$LOG_FILE" 2>&1
    npm cache clean --force &> /dev/null
fi

# 5. Yarn (Frontend Alternative)
if command -v yarn &> /dev/null; then
    echo -e "\n[Yarn (Detected)]" >> "$LOG_FILE"
    yarn outdated --disable-pnp >> "$LOG_FILE" 2>&1
    yarn cache clean &> /dev/null
fi

# 6. Rust / Cargo (Systems Programming)
if command -v cargo &> /dev/null; then
    echo -e "\n[Cargo/Rust (Detected)]" >> "$LOG_FILE"
    echo "Cleaning Cargo cache and registry..." >> "$LOG_FILE"
    rm -rf "$HOME/.cargo/registry/cache"/* &> /dev/null
    echo "Cleanup complete." >> "$LOG_FILE"
fi

# 7. Ruby / Gem
if command -v gem &> /dev/null; then
    echo -e "\n[Ruby Gem (Detected)]" >> "$LOG_FILE"
    gem outdated >> "$LOG_FILE" 2>&1
    gem cleanup &> /dev/null
fi

# ==========================================
# Native macOS Notifications & Calendar
# ==========================================

# Suppress errors if run outside of a standard UI session (e.g., via launchd)
osascript -e 'display notification "Environment maintenance complete. Please check Documents for the report." with title "Env Manager"' &> /dev/null

osascript -e '
set today to current date
tell application "Calendar"
    set targetCalendar to first calendar whose writable is true
    tell targetCalendar
        make new event at end with properties {summary:"📦 Env Maintenance & Cleanup Complete", start date:today, end date:today, allday event:true, description:"Details saved to: ~/Documents/Env_Outdated_Report.txt"}
    end tell
end tell' &> /dev/null

echo "Execution complete."