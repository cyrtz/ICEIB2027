﻿<#
.SYNOPSIS
    Windows 環境一鍵部署 Overleaf Git + Claude Code MCP Server 自動化腳本
.DESCRIPTION
    自動檢查/安裝 Git 與 uv，建立本地工作區，Clone Overleaf 專案，並註冊至 Claude Code 全域 MCP。
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   Overleaf + Claude Code MCP 自動化部署腳本 (Win)   " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 階段 1：檢查與安裝核心相依套件 (Git, uv, Claude Code)
# ---------------------------------------------------------
Write-Host "[1/4] 正在檢查系統環境與相依工具..." -ForegroundColor Yellow

# 1.1 檢查 Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  -> 找不到 Git，正在透過 winget 自動安裝 Git for Windows..." -ForegroundColor DarkYellow
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "  [OK] Git 已安裝 ($(git --version))" -ForegroundColor Green
}

# 1.2 檢查 uv (uvx)
if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
    Write-Host "  -> 找不到 uvx，正在自動安裝 uv..." -ForegroundColor DarkYellow
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
} else {
    Write-Host "  [OK] uvx 已安裝 ($(uvx --version))" -ForegroundColor Green
}

# 重新載入當前工作階段的 PATH 環境變數
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 1.3 檢查 Claude Code CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  [錯誤] 找不到 'claude' 指令！請確認已安裝 Claude Code CLI 並加入 PATH 後再執行此腳本。" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  [OK] Claude Code CLI 已就緒" -ForegroundColor Green
}

Write-Host ""

# ---------------------------------------------------------
# 階段 2：收集 Overleaf 專案資訊
# ---------------------------------------------------------
Write-Host "[2/4] 請輸入 Overleaf 專案設定資訊：" -ForegroundColor Yellow

# 取得 Git URL
do {
    $gitUrl = Read-Host "  1. 請貼上 Overleaf Git 網址 (例如 https://git.overleaf.com/65a1b2c3...)"
    $gitUrl = $gitUrl.Trim()
} while ([string]::IsNullOrWhiteSpace($gitUrl))

# 取得本地資料夾名稱
$defaultFolder = "my-paper"
$folderName = Read-Host "  2. 請輸入本地專案資料夾名稱 [預設: $defaultFolder]"
if ([string]::IsNullOrWhiteSpace($folderName)) { $folderName = $defaultFolder }
$folderName = $folderName.Trim()

# 取得 MCP Server 註冊名稱
$defaultMcpName = "overleaf-$folderName"
$mcpName = Read-Host "  3. 請輸入 Claude Code MCP 註冊名稱 [預設: $defaultMcpName]"
if ([string]::IsNullOrWhiteSpace($mcpName)) { $mcpName = $defaultMcpName }
$mcpName = $mcpName.Trim()

$baseDir = Join-Path $env:USERPROFILE "overleaf-projects"
$targetDir = Join-Path $baseDir $folderName

Write-Host ""

# ---------------------------------------------------------
# 階段 3：建立工作區與 Clone 專案
# ---------------------------------------------------------
Write-Host "[3/4] 正在建立工作區並拉取 Overleaf 專案..." -ForegroundColor Yellow

if (-not (Test-Path $baseDir)) {
    New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
}

if (Test-Path $targetDir) {
    Write-Host "  [警告] 目錄 '$targetDir' 已存在，跳過 git clone 步驟，改為檢查更新..." -ForegroundColor DarkYellow
    Push-Location $targetDir
    git pull
    Pop-Location
} else {
    Write-Host "  -> 正在執行 git clone..." -ForegroundColor Cyan
    Write-Host "  [提示] 若跳出登入視窗，帳號請填 Overleaf 信箱，密碼請貼上 'Git Authentication Token'！" -ForegroundColor Magenta
    git clone $gitUrl $targetDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [錯誤] git clone 失敗，請檢查網址與 Git Token 是否正確。" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  [OK] 本地專案已就緒：$targetDir" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# 階段 4：註冊至 Claude Code 全域 MCP
# ---------------------------------------------------------
Write-Host "[4/4] 正在將專案註冊至 Claude Code MCP ($mcpName)..." -ForegroundColor Yellow

# 若同名 MCP 已存在則先移除，確保設定乾淨覆寫
claude mcp remove $mcpName --scope user 2>$null | Out-Null

# 執行註冊
claude mcp add $mcpName --scope user -- uvx mcp-server-git --repository "$targetDir"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] MCP Server '$mcpName' 註冊成功！" -ForegroundColor Green
} else {
    Write-Host "  [錯誤] MCP 註冊失敗，請確認 Claude Code 版本與權限。" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " 驗證目前 Claude Code MCP 連線狀態：" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
claude mcp list

Write-Host ""
Write-Host "部署完成！你現在可以在任何終端機輸入 'claude' 開始查找與編輯論文。" -ForegroundColor Green
