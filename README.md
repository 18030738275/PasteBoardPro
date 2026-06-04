# PasteBoard Pro

> macOS 菜单栏剪贴板历史管理工具

![macOS](https://img.shields.io/badge/macOS-15.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

复制了找不到？PasteBoard Pro 帮你记住每一次复制。自动记录剪贴板中的文字和图片，随时查看、搜索、重新粘贴。

---

## 功能特性

| 功能 | 说明 |
|------|------|
| **自动记录** | 后台持续监听剪贴板，自动捕获复制的文字和图片，无需手动操作 |
| **一键复制** | 点击任意历史记录卡片，内容立即回到剪贴板 |
| **快捷键呼出** | 全局快捷键 `⌘+Shift+V`，在任意应用中快速唤出 |
| **智能搜索** | 实时关键词搜索，输入即刻筛选匹配结果 |
| **分类筛选** | 按"全部 / 文字 / 图片"快速分类浏览 |
| **置顶功能** | 重要内容一键置顶，始终显示在列表最上方 |
| **删除管理** | 右键菜单快速删除不需要的记录 |
| **存储时长** | 可设置保留 1天 / 3天 / 5天，到期自动清理 |
| **复制提示音** | 每次复制成功后播放提示音，明确告知已记录 |
| **本地存储** | 数据完全本地保存，不联网，保护隐私 |

## 截图

| 主界面 | 设置面板 |
|--------|----------|
| 菜单栏图标 + 弹出窗口，卡片式浏览历史记录 | 存储时长选择 + 图片保存路径自定义 |

## 系统要求

- macOS 15.0 (Sequoia) 或更高版本
- Xcode 16.1（编译时需要）

## 安装方式

### 方式一：下载 Release（推荐）

1. 下载最新版本的 `PasteBoardPro.app`
2. 将 `.app` 拖入"应用程序"文件夹
3. 双击启动，菜单栏右上角出现剪贴板图标

### 方式二：从源码编译

```bash
# 克隆仓库
git clone https://github.com/你的用户名/PasteBoardPro.git
cd PasteBoardPro

# 用 Xcode 打开项目
open PasteBoardPro.xcodeproj

# 或者命令行编译
xcodebuild -configuration Release

# 编译产物在 build/ 目录
```

## 使用指南

### 基本操作

1. **查看历史** — 点击菜单栏剪贴板图标，或按 `⌘+Shift+V`
2. **复制内容** — 点击任意卡片，内容自动复制到剪贴板
3. **搜索记录** — 在搜索框输入关键词，实时筛选
4. **分类浏览** — 点击"全部 / 文字 / 图片"切换筛选
5. **置顶/删除** — 右键点击卡片，选择"置顶"或"删除"

### 设置选项

点击窗口右上角齿轮图标打开设置：

- **存储时长**：选择记录保留 1天、3天或 5天
- **图片路径**：自定义剪贴板图片的保存位置

### 退出应用

点击窗口左下角"退出"按钮，或在终端运行：

```bash
killall PasteBoardPro
```

## 项目结构

```
PasteBoardPro/
├── PasteBoardPro.xcodeproj       # Xcode 项目文件
├── project.yml                   # xcodegen 配置
├── PasteBoardPro/
│   ├── PasteBoardProApp.swift    # 应用入口 + AppDelegate + 全局热键
│   ├── Info.plist                # 应用配置（菜单栏应用，无 Dock 图标）
│   ├── Views/
│   │   ├── ContentView.swift     # 主窗口（搜索 + 筛选 + 列表）
│   │   ├── ClipCardView.swift    # 卡片组件（右键菜单操作）
│   │   ├── SearchBar.swift       # 搜索框
│   │   ├── FilterBar.swift       # 筛选标签
│   │   └── SettingsView.swift    # 设置面板
│   ├── Models/
│   │   └── ClipboardItem.swift   # 数据模型
│   ├── Services/
│   │   ├── ClipboardMonitor.swift # 剪贴板监听 + 复制 + 保存
│   │   └── DatabaseManager.swift  # JSON 文件存储
│   └── Resources/
│       └── Assets.xcassets/       # 图标 + 颜色资源
└── build/                         # Release 编译产物（.gitignore 排除）
```

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 语言 | Swift 5.9+ | macOS 原生开发标准语言 |
| UI | SwiftUI | 现代声明式 UI 框架 |
| 应用类型 | MenuBarExtra | macOS 菜单栏常驻应用 |
| 存储 | JSON 文件 | 轻量本地存储，无需数据库依赖 |
| 全局热键 | Carbon API | RegisterEventHotKey 注册系统级快捷键 |
| 图标生成 | Python + Pillow | 程序化生成多尺寸 App Icon |

## 数据存储

所有数据完全本地存储，不联网，不上传任何云端：

```
~/Library/Application Support/PasteBoardPro/
├── clipboard.json        # 历史记录数据
└── Images/               # 剪贴板图片（默认路径）
```

## 开发日志

详细的开发过程记录在 `dev-logs/` 目录中。

| 日期 | 内容 |
|------|------|
| 2026-06-04 | v1.0 完整开发，从需求到上线 |

## 许可证

MIT License

---

*PasteBoard Pro — 让每一次复制都不再丢失。*
