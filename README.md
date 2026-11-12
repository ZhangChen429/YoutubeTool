# YoutubeTool

双击仓库根目录的 `download.bat`，粘贴 YouTube 视频或 Shorts 链接并按回车。视频保存到 `downloads/`。首次启动会下载 Windows 版 yt-dlp。仓库携带的 Deno 和 FFmpeg 通过 Git LFS 分发，克隆后可运行 `git lfs pull` 获取。

## 安装 Get cookies.txt LOCALLY

已安装此扩展的浏览器可以直接使用。也可以从 [Chrome 应用商店](https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc) 安装，或按下面的步骤加载仓库固定版本的源码。

1. 在仓库根目录运行 `git submodule update --init -- vendor/get-cookies-txt-locally`。
2. 在 Chrome 打开 `chrome://extensions/`，或在 Edge 打开 `edge://extensions/`。
3. 打开「开发者模式」，点击「加载已解压的扩展程序」，选择仓库中的 `vendor/get-cookies-txt-locally/src`。这个目录直接包含 `manifest.json`。

## 导出 YouTube cookies.txt

1. 在浏览器中登录 YouTube，保持当前标签页在 `youtube.com`，然后打开 **Get cookies.txt LOCALLY**。
2. 将 **Export Format** 设为 **Netscape**，点击 **Export As** 导出当前站点。只导出当前站点即可。
3. 把导出的文件拖到仓库根目录的 `import-cookies.bat`。校验通过后会更新 `cookies.txt`，校验失败时保留旧文件。运行 `download.bat` 时会自动读取它。

如果 yt-dlp 提示 Cookie 已失效，可在扩展详情里允许其在无痕或 InPrivate 模式下运行。在新的无痕窗口登录 YouTube，然后在同一个标签页打开 `https://www.youtube.com/robots.txt`，按上述方式导出并拖到 `import-cookies.bat`，最后关闭整个无痕窗口。参见 [yt-dlp 官方说明](https://github.com/yt-dlp/yt-dlp/wiki/Extractors#exporting-youtube-cookies)。

`cookies.txt` 含有登录会话信息，已由 `.gitignore` 排除。请只保存在本机。

## 使用 Cookie-Editor

[Cookie-Editor](https://github.com/Moustachauve/cookie-editor) 是另一个可选的导出扩展。仓库将其固定为 `v1.13.0`。已经安装的用户可以直接使用现有扩展。

要从仓库源码安装，请先安装 Node.js 和 npm，然后在仓库根目录运行以下 PowerShell 命令：

```powershell
git submodule update --init -- vendor/cookie-editor
cd vendor/cookie-editor
npm.cmd ci
npx.cmd --no-install grunt json-replace:chrome clean:chrome copy:chrome replace:chrome
```

在 `chrome://extensions/` 开启开发者模式，点「加载已解压的扩展程序」，选择 `vendor/cookie-editor/build/chrome`。如果使用 Edge，把命令里的四个 `:chrome` 改为 `:edge`，然后在 `edge://extensions/` 加载 `vendor/cookie-editor/build/edge`。

在已登录的 YouTube 标签页打开 Cookie-Editor，点 **Export → Netscape**。把剪贴板内容粘贴到记事本，保存为本地 `.txt` 文件，再拖到仓库根目录的 `import-cookies.bat`。导入成功后，`download.bat` 会自动读取更新后的 `cookies.txt`。

## 启动 VideoCaptioner

在 Windows x64 上克隆仓库后，双击根目录的 `run.bat`。首次启动需要 Git 和网络连接，启动器会初始化 VideoCaptioner 子模块，并通过 uv 准备 Python 3.12 和锁定的依赖。如果找不到 uv，会将它下载到仓库的 `.runtime/`。需要使用仓库自带的 FFmpeg 时，先运行 `git lfs pull`。
