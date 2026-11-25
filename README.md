# ICEIB 2027 期末專題：AI 健身教練 (AI Fitness Coach)

本專案收錄 ICEIB 2027 期末專題論文提案、系統架構設計文件、Overleaf LaTeX 專案原始碼，以及自動化整合 Overleaf Git 與 AI 工具（Claude Code / Antigravity）的 MCP 部署腳本。

---

## 專案目錄結構

```text
ICEIB2027/
├── setup_overleaf_mcp.ps1                  # Overleaf Git + Claude Code MCP 自動化部署腳本
├── README.md                               # 本說明文件
├── proposal.md                             # 期末專題提案書
├── design.md                               # AI 健身教練系統詳細架構設計文件
├── ICEIB2027-AI-Fitness-Coach-Overleaf.zip  # Overleaf 論文原始碼完整包 (含 main.tex, sections, tables)
├── ICEIB2027-Complete-Draft.zip            # 論文完整草稿包
├── 期末專題提案作業規範.pdf                   # 課程專題規範與評分指標
├── AI健身教練解析.pdf                        # 系統核心解析參考文件
└── A2Z outline example.pdf                 # 論文大綱範例參考
```

---

## 自動化部署腳本使用指南 (`setup_overleaf_mcp.ps1`)

本腳本專為 **Windows (PowerShell)** 環境設計，可自動完成：
1. **環境檢查與自動安裝**：檢查 `Git`、`uv` (`uvx`)、`Claude Code CLI`，若缺失則自動安裝。
2. **本地工作區建立**：在 `%USERPROFILE%\overleaf-projects` 建立專案目錄。
3. **Overleaf 專案拉取**：透過 Overleaf 官方 Git 橋接服務 Clone 或更新論文專案（免受 Cloudflare 機器人驗證干擾）。
4. **全域 MCP 註冊**：自動註冊 `mcp-server-git` 至 Claude Code，讓 AI 可直接讀取與修改 Overleaf 專案。

---

### 一、事前準備（取得 Overleaf Git 資訊）

> [!IMPORTANT]
> Overleaf 官方 Git 整合需具有 Git 存取權限（Overleaf 專業版或學校/學術授權帳號）。

1. **取得專案 Git 網址**：
   - 登入 Overleaf 網頁版，進入您的論文專案。
   - 點擊左上角的 **Menu（選單）**。
   - 找到 **Git** 選項，複製 Git 網址（格式如：`https://git.overleaf.com/65a1b2c3xxxxxxxx`）。

2. **取得 Git 認證權杖 (Git Token)**：
   - 點擊 Overleaf 右上角個人頭像 -> **Account Settings（帳號設定）**。
   - 捲動至 **Git Integration** 區塊。
   - 點擊產生 **Git Authentication Token** 並複製保存（此 Token 即為登入密碼，請勿使用一般網頁登入密碼）。

---

### 二、執行腳本步驟

1. 開啟 **PowerShell** 終端機視窗。
2. Windows 預設會阻擋未簽署的腳本執行，請先執行以下指令放寬當前視窗權限：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   ```
3. 執行部署腳本：
   - **在專案目錄內執行**：
     ```powershell
     & .\setup_overleaf_mcp.ps1
     ```
   - **或執行桌面上的備份腳本**：
     ```powershell
     & "$env:USERPROFILE\Desktop\setup_overleaf_mcp.ps1"
     ```

---

### 三、腳本互動提示輸入流程

腳本啟動後，會依序提示您輸入以下資訊：

| 步驟 | 提示訊息 | 說明與範例 |
| :--- | :--- | :--- |
| **1** | `請貼上 Overleaf Git 網址` | 貼上第一步複製的 `https://git.overleaf.com/...` |
| **2** | `請輸入本地專案資料夾名稱` | 本地儲存名稱，直接按 Enter 預設為 `my-paper` |
| **3** | `請輸入 Claude Code MCP 註冊名稱` | MCP 伺服器識別名稱，直接按 Enter 預設為 `overleaf-<資料夾名稱>` |

4. **Git 登入驗證**：
   - 當腳本執行到 `git clone` 階段時，系統會彈出 **Git Credential Manager** 驗證視窗：
     - **帳號 / Username**：請輸入您的 **Overleaf 註冊信箱**。
     - **密碼 / Password**：請貼上稍早產生的 **Git Authentication Token**。
5. **部署完成**：
   - 專案將被下載至 `C:\Users\<你的使用者名稱>\overleaf-projects\<專案名稱>`。
   - 腳本會自動完成 MCP 註冊並列出 `claude mcp list` 確認連線。

---

### 四、多專案擴充方式

若未來有第二篇或多篇論文需要掛載：
- **重複執行同一支腳本**：
  在步驟 2 輸入不同的專案資料夾名稱（例如 `paper-2`），腳本會自動建立獨立資料夾並註冊為 `overleaf-paper-2`，完全不會覆蓋或影響原有專案。

---

## 替代方案：免 Git Token 本地直接編輯

如果您的 Overleaf 帳號為免費版（無官方 Git 功能）：
1. 直接解壓縮本專案的 `ICEIB2027-AI-Fitness-Coach-Overleaf.zip`。
2. 本機直接包含完整的 LaTeX 結構（`main.tex`、各章節 `sections/` 與圖表）。
3. 由 AI 助手在本地完成論文研讀與修改。
4. 修改完成後，打包為 ZIP 檔案上傳回 Overleaf 網頁版，點擊 **Recompile** 即可預覽 PDF。

---

## GitHub 版本控制

本專案已連結至 GitHub 儲存庫：
- **遠端倉庫**：[https://github.com/cyrtz/ICEIB2027.git](https://github.com/cyrtz/ICEIB2027.git)
- **主要分支**：`main`

常用的提交與同步指令：
```powershell
git add .
git commit -m "更新說明"
git push origin main
```
