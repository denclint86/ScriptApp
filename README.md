﻿# AHK 脚本

## 主程序使用方法

1. Config 文件夹内是开发者自己的配置, 直接删除 Config 文件夹
2. 直接 autohotkey v1 启动 main.ahk 即可
3. 设置一个用于加密本地配置的密码
4. 按下 `ed\` 来启动编辑器(目前开发者习惯使用 `\` 作为确认键, 所以大多的热字串都是以它结束), 具体用法请看下方的示例
5. 你可以在 ConfigEditor 中创建自己的表, 并点击新建项来快速创建一个配置
6. 按下 `·12` 或 `21·` 来重载脚本
7. 可以在注册表设置开机自启: "your\script\path\Main.ahk" ${password}

## 功能

### 网络

1. 适用于 win 11 的 wifi 控制 ( 检查、连接、断开指定 wifi 等 )
1. 适用于 win 11 的个人热点启动
1. 当前 ipv4 地址获取
1. 封装 web 请求
1. Bing、DeepL 文本翻译 API

![tran](https://github.com/p1ay1s/ScriptApp/blob/main/readme_resources/tran.png)

### ui提示封装

1. 跟随鼠标的 tooltip
1. 普通、可切换频道的 tooltip
1. msgbox
1. progress、splashText

### 适用于广东工业大学的校园网快连、自动检查和重新登录

![gdut](https://github.com/p1ay1s/ScriptApp/blob/main/readme_resources/gdut.png)

### 对二进制文件的文件读写以及异或加密工具

### 基于 json 的配置文件存取 ( 在主脚本运行后动态加载配置文件中写入的信息 )

建议用专业的 json 编辑器来编辑

可存储并执行的类型:

1. 脚本内置常量 ( 加载至代码内的常量, 可以是你的翻译 api key 等 )
1. 热字串
1. ahk 代码  ( 可以在 json 中写入 ahk 代码并通过热键执行! )
1. 文件路径以及网址

![c1](https://github.com/p1ay1s/ScriptApp/blob/main/readme_resources/config1.png)

![c2](https://github.com/p1ay1s/ScriptApp/blob/main/readme_resources/config2.png)

````json
{
    "as": {
        "type": "runnable", ; 效果: 按下 `as\` 时启动 AndroidStudio
        "value": "D:\\*****\\Androidstudio\\bin\\studio64.exe"
    },
    "sl": {
        "type": "code", ; 效果: 按下 `sl\` 执行 value 中的代码, 使机器休眠
        "value": "DllCall(\"PowrProf\\SetSuspendState\", \"int\", 0, \"int\", 0, \"int\", 0)"
    },
    "gh": {
        "type": "runnable", ; 效果: 按下 `gh\` 使用默认浏览器打开 github
        "value": "https://github.com/"
    },
    "qq": { ; 效果: 按下 `qq\` 直接将 `qq\` 替换为 qq 号码
        "type": "hotString",
        "value": "340****095"
    }
}
````

### ConfigEditor.ahk: 上述配置文件存储系统的编辑器

### 函数定义分析器

1. 可以读取文本文件内的函数定义
1. 目前仅支持 ahk 和 kotlin

读取效果:

````
; ReadBytes(path, batchSize := 4096)
; WriteBytes(path, bytes, batches := 4096)
; AppendBytes(path, bytes, batchSize := 4096)
; CryptBytes(bytes, password)
; GetType(v)
; GetEmptyFile(path)
; GetAppendFile(path, create := False)
; GetReadFile(path, create := False)
; GetFileSize(path)
; XORFile(inFilePath, outFilePath, password, bufferSize := 4096)
````

### CMD 命令执行并返回运行结果

### Crypter.ahk: 基于异或加密的二进制文件加密工具

## 代码分块 ( 使用函数定义分析器读取 )

````ini
[D:\A_code\ScriptApp\CMD.ahk]
RunCmdWithExpect(command, expect, timeout := 0.3)
RunCmd(command, timeout := 0.3)


[D:\A_code\ScriptApp\CodeParser.ahk]
GetFuncDescriptionInFile(filePath := "")
ReadFileDescriptionForFolder()
FilterFuncName(str)
IsArrIncluding(array, expect)


[D:\A_code\ScriptApp\ConfigTools.ahk]
IsParsable(v)
IsUrl(str)
InitPools(obj, parent := "")
BuildRunnables()
BuildHotStrings()
BuildCodes()
BuildHotstring(funcName, key, value)
ConfigsReload(cPath, cDefault, ByRef password, ByRef contents, ByRef manifest)
ConfigsInit(cPath, cDefault, ByRef password, ByRef contents, ByRef manifest)
_ConfigsBuild(cPath, cDefault, ByRef password, ByRef contents, ByRef manifest, withPassword)
Guidance()
RequirePassword(msg)
ReadCryptedJsonString(path, password, default)
ReadCyptedJSON(path, password, default)
IsJson(str)
WriteCryptedJsonString(path, str, password)
WriteCryptedJSON(path, obj, password)
ReadCryptedFile(path, password, default)
WriteCryptFile(path, bytes, password)
AppendCryptFile(path, bytes, password)
GetConfigPath(name)
ReadConfigFiles(manifest, password, ByRef outObj, default)
CleanUnregistereds(manifest)


[D:\A_code\ScriptApp\Crypter.ahk]
XORFileTelling(inFilePath, outFilePath, password)


[D:\A_code\ScriptApp\FileTools.ahk]
ReadBytes(path, batchSize := 4096)
WriteBytes(path, bytes, batches := 4096)
AppendBytes(path, bytes, batchSize := 4096)
CryptBytes(bytes, password)
GetType(v)
GetEmptyFile(path)
GetAppendFile(path, create := False)
GetReadFile(path, create := False)
GetFileSize(path)
XORFile(inFilePath, outFilePath, password, bufferSize := 4096)


[D:\A_code\ScriptApp\GDUT.ahk]
GDUT_KeepAlive()
GDUT_Kill()
GDUT()
GDUT_Connect()
GDUT_Login()


[D:\A_code\ScriptApp\Libs\JSON.ahk]
		Call(self, ByRef text, reviver:="")
		
		ParseError(expect, ByRef text, pos, len:=1)
		
		Walk(holder, key)
		
		Call(self, value, replacer:="", space:="")
		
		Str(holder, key)
		
		Quote(string)
		
		__Call(method, ByRef arg, args*)
		


[D:\A_code\ScriptApp\Main.ahk]
GetSelectedText()
WaitForKey()
Translate(bingKey := "", deeplKey := "")
RunUrl(title, url)
SendString(str)
RunWithSplashText(path)
RunWaitString(command)
RunLocalHost(url)


[D:\A_code\ScriptApp\Message.ahk]
FT_Show(message, time := 0)
FT_Dismiss()
MB(message, title := "")
TT_Show(message, pid := 1, x := "", y := "")
TT_Dismiss(pid := 1)
ST_Show(message, title := "", time := 0, width := 0, height := 0)
ST_Dismiss()


[D:\A_code\ScriptApp\Net.ahk]
Bing(text, apiKey, from := "en", to := "zh-CN")
DeepL(text, apiKey, from := "EN", to := "ZH-HANS")
Ping(url, timeout := 5)
GetRequest(url, timeout := 5)
GetIP(expect := 10)
IsWifiNear(ssid)
IsWifiConnected(ssid)
GetCurrentWifi()
ConnectWifi(ssid)
DisconnectWifi()


[D:\A_code\ScriptApp\Text.ahk]
BytesToString(bytes, encoding := "UTF-8")
IsCN(text)
StringToBytes(str, encoding := "UTF-8")
BytesToBstring(Body, Cset)
IsTextIncluding(text, expect, caseSensitive := False)
FilterText(text, pattern)
ReverseText(text)
ParseCamelText(text)
RunFolder(funcInstance, path := "")
RunFuncForDirectory(path, funcInstance, ByRef result)
````

