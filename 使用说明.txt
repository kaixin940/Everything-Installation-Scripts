Everything 安装脚本使用说明
================================

当前目录包含以下可用文件：

1. 安装Everything.ps1
   功能：自动下载安装Everything主程序和es.exe命令行工具
   使用：以管理员身份运行PowerShell执行此脚本
   结果：完整安装Everything，包括命令行工具和PATH配置

2. 配置Everything命令行搜索.ps1
   功能：配置es.exe命令行搜索工具（如果主脚本未成功）
   使用：以管理员身份运行PowerShell执行此脚本
   结果：可以在命令行使用es命令搜索文件

3. 配置Everything快捷键和右键菜单.ps1
   功能：配置Everything的快捷键和右键菜单集成
   使用：以管理员身份运行PowerShell执行此脚本
   结果：
   - Ctrl+Alt+E 快捷键打开Everything搜索
   - 右键文件可选择"用Everything搜索文件"
   - Everything开机自启动

4. 安装EverythingToolbar.ps1
   功能：自动下载安装EverythingToolbar任务栏搜索工具
   使用：以管理员身份运行PowerShell执行此脚本
   结果：在Windows任务栏集成Everything搜索框

5. EverythingToolbar手动安装指南.txt
   功能：EverythingToolbar任务栏搜索工具的安装指南
   使用：备用安装指南，如果自动脚本失败时使用
   结果：在Windows任务栏集成Everything搜索框

使用顺序建议：
1. 首先运行"安装Everything.ps1"（主安装脚本）
2. 如果需要，运行"配置Everything命令行搜索.ps1"
3. 运行"配置Everything快捷键和右键菜单.ps1"
4. 运行"安装EverythingToolbar.ps1"（任务栏搜索工具）
5. 如果自动安装失败，参考"EverythingToolbar手动安装指南.txt"

注意事项：
- 所有脚本都需要管理员权限运行
- 确保Everything已正确安装并运行
- 命令行搜索需要重启命令行窗口生效
- EverythingToolbar需要从GitHub手动下载安装

下载地址：
Everything: https://www.voidtools.com/
EverythingToolbar: https://github.com/srwi/EverythingToolbar/releases/
