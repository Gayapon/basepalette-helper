# Palette Helper for Aseprite 🎨

An Aseprite script that fetches **BasePaint** palettes by canvas number, automatically sorts the colors by perceptual CIELAB $L*$ luminance, and projects them onto shading spheres for instant pixel art preview and application.

## ✨ Features
- **BasePaint Integration:** Pulls palette hex codes directly from the official BasePaint GraphQL and REST API using a canvas number.
- **Smart Luminance Sorting:** Automatically organizes color ramps from lightest to darkest using CIELAB $L*$ luminance calculations.
- **Interactive Shading Preview:** Renders a floating window featuring custom $16 \times 16$ shading spheres (with smart matrices for 2, 3, 4, or 8+ colors) scaled up at multiple view factors.
- **Shuffle Tool:** Randomly samples and re-sorts palettes with more than 8 colors on the fly.

---

## 🛠️ Requirements
- **cURL:** This script requires `cURL` to interact securely with the BasePaint web API. 
  - *Windows and macOS* come with `cURL` pre-installed by default.

---

## 📥 Installation
1. Download or copy the `palette_helper.lua` file from this repository.
2. Open Aseprite and navigate to **File > Scripts > Open Scripts Folder**.
3. Place the `.lua` file inside that folder.
4. Back in Aseprite, go to **File > Scripts > Rescan Scripts** (or restart the application).

---

## 🚀 How to Use
1. Open or create any canvas/sprite in Aseprite.
2. Go to **File > Scripts > Palette helper**.
3. Type the desired **Canvas #** (e.g., `42`).
4. Click **Load palette** to open the floating preview window and apply the sorted color ramps directly to your active Aseprite palette.

---

## 🌐 Why does it require network access & cURL?
Because Aseprite scripts run inside a localized sandboxed Lua environment, they cannot natively perform web requests. 

* **cURL Bridge:** The script safely invokes system `cURL` commands in the background to query the BasePaint database (`https://basepaint.xyz/`). 
* **Privacy:** No personal data, local files, or system information are ever collected, read, or transmitted. Network access is strictly restricted to downloading public palette color codes.

---
Created with ❤️ by **Gayapón**.
