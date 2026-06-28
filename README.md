[อ่านภาษาไทยที่นี่ (Thai Version)](README_TH.md)

Hello. I also experienced Roblox Studio constantly leaking my RAM every time I ran a playtest, and the RAM wouldn't drop back down even after I stopped testing. So, I wrote this simple tool to use quietly for myself, and figured it might be useful for others who are dealing with the same headache.

---

## ⚠️ Safety Disclaimer

- **Please use with caution:** It works fine on my personal setup, but since PC configurations vary, I am slightly anxious about unexpected issues on other machines. Please review the code and use it at your own discretion.
- **Strictly Local:** The code is completely transparent and runs strictly on your own local loopback network (`localhost:9088`). It does not transmit any data over the internet, so we both can have complete peace of mind.
- **Admin Rights:** `Setup.bat` requires Admin rights solely to register a Windows Scheduled Task, allowing the background program to start quietly on boot.

---

## 💻 System Requirements

- Windows 10 and Windows 11 (No macOS or Linux support).
- I am not quite sure about other Windows versions.

---

## 🛠️ How it Works

1. The Roblox Studio Plugin (`plugin.rbxmx`) detects when you press **Stop** to end a playtest.
2. The plugin sends a quick signal to the background program through a local port.
3. The background program waits 1.5 seconds for Roblox to finish saving data, then commands Windows to reclaim Roblox Studio's RAM.

---

## 📥 Installation

### Step 1: Install the Background Program
1. Double-click **`Setup.bat`** and click "Yes" to accept Admin rights.
2. Wait until the system displays `Press any key to continue . . .` and then close the black CMD window.

### Step 2: Install the Plugin
1. Open Roblox Studio.
2. Go to the **Plugins** tab and click **Plugins Folder**.
3. Copy **`plugin.rbxmx`** into that folder, then close and restart Roblox Studio.

---

## 📤 Uninstallation

You can easily remove the tool anytime:
1. Double-click **`Uninstall.bat`** (and accept Admin rights) to completely delete the background task.
2. Delete **`plugin.rbxmx`** from your Roblox Studio Plugins folder.
