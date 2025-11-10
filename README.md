# Everything 安装脚本集合

## 项目简介

这是一个完整的Everything安装脚本集合，提供两种安装选项来满足不同需求。

## 安装选项

### 1. 基础安装 - `安装Everything.ps1`
**功能**：自动下载安装Everything主程序和es.exe命令行工具
**使用**：以管理员身份运行PowerShell执行此脚本
**结果**：完整安装Everything，包括命令行工具和PATH配置

```powershell
powershell -ExecutionPolicy Bypass -File .\安装Everything.ps1
```

### 2. 完整安装 - `Everything完整安装.ps1` ⭐ 推荐
**功能**：一键安装Everything + 命令行工具 + 任务栏工具栏
**使用**：以管理员身份运行PowerShell执行此脚本
**特点**：
- 默认静默安装，无需用户交互
- 支持本地安装包优先使用
- 自动配置es.exe命令行工具
- 自动安装EverythingToolbar任务栏搜索
- 完整的PATH环境变量配置

```powershell
# 默认完整安装（推荐）
powershell -ExecutionPolicy Bypass -File .\Everything完整安装.ps1

# 使用本地安装包
powershell -ExecutionPolicy Bypass -File .\Everything完整安装.ps1 -LocalInstallerPath "C:\path\to\installer.exe"

# 仅安装命令行工具（跳过工具栏）
powershell -ExecutionPolicy Bypass -File .\Everything完整安装.ps1 -NoToolbar

# 交互式安装（显示安装界面）
powershell -ExecutionPolicy Bypass -File .\Everything完整安装.ps1 -Silent:$false
```

## 安装后功能

### 命令行搜索
```cmd
es *.txt                    # 搜索txt文件
es filename.ext             # 搜索特定文件
es "folder name"            # 在特定文件夹搜索
```

### 任务栏搜索
- 右键任务栏 → 工具栏 → EverythingToolbar
- 使用任务栏搜索框进行搜索
- 支持Everything的所有搜索语法

## 系统要求

- Windows 10/11
- PowerShell 2.0+
- 管理员权限

## 注意事项

- 所有脚本都需要管理员权限运行
- 命令行搜索需要重启命令行窗口生效
- EverythingToolbar安装后需要配置任务栏工具栏

## 下载地址

- Everything: https://www.voidtools.com/
- EverythingToolbar: https://github.com/srwi/EverythingToolbar/releases/

## 故障排除

- 如果工具栏没有出现，重启Windows资源管理器
- 确保Everything服务正在运行
- 检查PATH环境变量是否正确配置

## 许可证

本项目采用MIT许可证。
