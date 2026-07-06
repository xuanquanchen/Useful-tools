# Useful tools
Some useful tools I implemented to make life a little bit easier :)

## Env Manager for macOS

A zero-config, "set it and forget it" shell script that keeps macOS development environment lean and transparent, automatically scans your system to detect installed package managers, safely cleans up unnecessary caches, and generates a unified list of outdated packages. **It leaves the final upgrade decisions entirely up to you**.

It natively integrates with **macOS Notifications** and your **macOS Calendar** to let you know when the background scan and cleanup are complete.

### Automate it Monthly

To schedule it to run silently in the background on the 1st of every month at 10:00 AM using macOS `launchd`.

**1. Create a `launchd` Property List File:**

Open your terminal and run:

```bash
nano ~/Library/LaunchAgents/com.user.envmanager.plist
```

**2. Add the Configuration:**

Paste the following XML into the editor.

*⚠️ Important: Replace `/Users/YOUR_USERNAME/` with your actual Mac username path.*

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.envmanager</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/Documents/env_maintenance.sh</string>
    </array>
    
    <!-- Run at 10:00 AM on the 1st day of every month -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Day</key>
        <integer>1</integer>
        <key>Hour</key>
        <integer>10</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/Library/Logs/env_maintenance.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/Library/Logs/env_maintenance.err</string>
</dict>
</plist>
```

*(Press `Ctrl + O`, hit `Enter` to save, and then press `Ctrl + X` to exit.)*

**3. Load the Scheduled Task:**

Tell macOS to activate the schedule:

```bash
launchctl load ~/Library/LaunchAgents/com.user.envmanager.plist
```
