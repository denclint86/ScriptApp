global keywords := ["for", "if", "loop", "else", "else if", "while", "switch", "try", "catch", "when"]

Action_Translate()
{
    rawText := GetText_Clipboard()
    str := ParseCamel(rawText)

    if (ErrorLevel || RegExReplace(str, "\s") == "")
    {
        Return
    }
    else
    {
        str := BingTranslate(str)
        ShowSplashText("press C to copy", str)

        Input, key, L1, {Tab}{BackSpace}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
        if (key = "c")
            Clipboard := str

        CloseWin()
    }
}

; ����ͨ������������һ�� api ������
; ��ǰʵ��ֱ�������ͷ���
Action_UseBrowser(title, url)
{
    content := GetText_Clipboard()
    if (ErrorLevel || RegExReplace(content, "\s") == "")
    {
        InputBox content, %title%, What To %title%?, , 330, 130
        if (content == "")
            Return
    }
    Run %url%%content% ; 'https://xxx.com?q=' + 'content'
}

BuildHotstrings_Send(values)
{
    BuildHotstrings(values, "Send_Arr")
}

BuildHotStrings_Run(values)
{
    BuildHotstrings(values, "Run_Arr")
}

; Ϊһ�����������ֵ����Ϊ���� funcName ���ַ���
BuildHotstrings(values, funcName)
{
    for key in values
        BuildHotstring(funcName, values, key)
}

; ��̬�������ַ���
; ��ҪΪ�������ļ��еļ�ֵ�����
BuildHotstring(funcName, values, key)
{
    if(key = "default")
        Return

    hotstring := ":*:" key "\"
    Hotstring(hotstring, Func(funcName).Bind(values, key))
}

; bing ���� api
BingTranslate(text)
{
    langfrom := RegExMatch(text, "[\x{4e00}-\x{9fa5}]") ? "zh-CN": "en"
    langto := langfrom = "en" ? "zh-CN" : "en"

    ; ���������ķ��� api
    url := "http://api.microsofttranslator.com/v2/Http.svc/Translate?appId="
        . "74FE953EB48E1487E94F4BF9C425B6290FF2DA48"
        . "&from="
        . RegExReplace(langfrom, "S)-.*$")
        . "&to="
        . RegExReplace(langto, "S)-.*$")
        . "&text=" text

    response := Web_Get(url)

    return Filter(response, "S)^<[^>]+>(.*?)<\/string>$")
}

Web_Get(url)
{
    Try
    {
        result := ""

        WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        WebRequest.Open("GET", url, true, "", "", 1500)
        WebRequest.Send()
        WebRequest.WaitForResponse()

        result := WebRequest.ResponseText
        ObjRelease(WebRequest)

        Return result
    }
    Catch
    {
        Return ""
    }
}

CloseWin()
{
    Progress, Off
    SplashTextOff
}

; fast msgbox
Msg(content)
{
    MsgBox, 262144, , %content%
}

; �����շ��ַ���ΪӢ�ľ��
; Ч��: ��StrSplit(str, A_Space)�� -> 'Str split ( str , A _ Space )'
; ������Ϊȫ��д�ĵ������ȫ����
ParseCamel(str)
{
    result := ""
    words := StrSplit(str, A_Space) ; Ԥ����: ���ո���Ϊ����

    for index, word in words
    { ; ����
        if (index > 1)
            result .= A_Space ; ������һ������Ԫ��ǰ����ո�

        position := 1
        len := StrLen(word) ; �����ж�ѭ��

        while (position <= len)
        {
            ; position ��Ӧ���ַ�
            thisChar := SubStr(word, position, 1)
            ; position + 1 ��Ӧ���ַ�
            nextChar := (position < len) ? SubStr(word, position + 1, 1) : ""

            thisCharIsLowercase := RegExMatch(thisChar, "^[a-z]$")
            thisCharIsUppercase := RegExMatch(thisChar, "^[A-Z]$")
            thisCharIsLetter := thisCharIsLowercase || thisCharIsUppercase

            ; �����ַ������Ǵ�д��ת��ΪСд
            if (position > 1 && thisCharIsUppercase)
            {
                result .= Format("{:L}", thisChar)
            }
            Else
            {
                ; ���򲻴���
                result .= thisChar
            }

            ; ��һ�ַ�����Сд��ո�(�ո���Ҫ�ټӿո�), ���ߵ�ǰ�ַ�������ĸ, �����ո�
            if (!RegExMatch(nextChar, "^[a-z ]$") || !thisCharIsLetter)
                result .= A_Space

            position++
        }
    }

    return result
}

; ���������һ��ֵ��ͨ�� splash text ����
Run_Arr(array, key)
{
    Run_ShowingSplashText(array[key])
}

; ���в�ͨ�� splash text ����
Run_ShowingSplashText(path)
{
    Run % path
    ShowSplashText("", "��", 800)
}

; ѡ��һ�� url ���� '/login/refresh' �� 'login/refresh'
; �Ѿ��������Ƿ�ͷ�Ƿ�Ϊ '/'
; ���������� api �ĵ���
Run_OnLocalHost(url) {
    content := GetText_Clipboard()
    if (ErrorLevel || RegExReplace(content, "\s") == "")
        Return
    ; �����ʼ�ַ��Ƿ�Ϊ '/'
    if (SubStr(content, 1, 1) != "/")
        content := "/" . content
    Run %url%%content%
}

; ���� cmd ���������Ƿ����������ֵ
RunCmd_IsValueExisted(order, hope := "")
{
    cmdInfo := GetText_Clipboard(order)

    If (hope = "")
        Return True
    Else
        Return InStr(cmdInfo, hope, False, 1, 1) > 0 ; check if "cmdInfo" is including "hope"
}

; ���� cmd ����������н��
RunCmd_GetFullResult(order)
{
    Return GetText_Clipboard(order)
}

; ����ѡ��Ŀ¼�µ������ļ�, ���������ļ��ú���ʵ�� funcInstance ����, Ȼ�󽫽��ѹ�� result
Run_Folder(folderPath := "", funcInstance := "") {
    FileSelectFolder, folderPath, , 3, ѡ��һ���ļ���

    If (!folderPath || !FileExist(folderPath))
        Return

    result := {}

    Loop, %folderPath%\*.*, 0, 1 ; �����ļ���,���������ļ���
    {
        If (funcInstance) {
            Try {
                r := %funcInstance%(A_LoopFileFullPath)
                If (r)
                    result[A_LoopFileName] := r
            }
            Catch {
                Msg(A_LoopFileName . "����ʧ��")
            }
        }
    }

    Loop, %folderPath%\*.*, 2, 1 ; �������ļ���
    {
        If A_LoopFileIsDir {
            subResult := Run_Folder(A_LoopFileFullPath, funcInstance)
            For index, value in subResult
                result[index] := value
        }
    }

    Return result ; for index, value in result
}

; ��ȡһ��Ŀ¼�µ��ı��ļ�, ����ȡ�������岢д���µ� txt �ļ���
ReadFunctionsInFolder()
{
    result := Run_Folder("", Func("ReadFunctionsInFile"))

    If (!result)
        Return

    FileSelectFile, savePath, S, file.txt, Save file, Text Documents (*.txt)
    If (!savePath)
        Return

    content := ""
    for index, value in result
    {
        content .= "[" . index . "]`n" . value . "`n`n"
    }

    If (!content)
        Return

    FileOpen(savePath, "w").Write(content).Close()

    Run % savePath
}

; ����һ���ļ������к����Ķ���, �п���ʶ�����
ReadFunctionsInFile(filePath := "")
{
    If (!filePath)
        FileSelectFile, filePath, 3, , ѡ���ļ� ; 1 + 2 �ļ���·�����������

    if (!FileExist(filePath))
        Return ""

    SplitPath, filePath, , , fileExt
    FileRead, fileContent, %filePath%

    pattern := ""
    pos := 1 ;��ʼλ��

    If (fileExt = "ahk")
        pattern := "((?<=[\n|\r])\s*\w*\s*\([^\n\r()]*\)\s*(?={))"
    Else If (fileExt = "kt")
        pattern := "((?<=fun)[ |<].+?\s*?\([\s|\S]*?\)\s*?(?=[:={]))"
    Else
        Return ""
    ; ʶ�������������
    ; ����Ӹ�������������ܱ���
    ; [A-Z] A-Z �����ַ�
    ; \w ��Ч�� [a-zA-Z0-9_]
    ; {xxx}* {xxx} ���Գ������ɴ� [0, +)
    ; [^\n\r()] �������� : \n, \r, (, ), ����֮����ַ�����
    ; \s �հ׷�
    ; (?=xxx) ����Ԥ���Ƿ��� 'xxx'
    ; (?<=xxx) ����Ԥ��

    Loop
    {
        oldPos := pos
        newPos := RegExMatch(fileContent, Pattern, match, pos)

        pos := newPos + StrLen(match1)

        r := Trim(match1, "`n`r ")
        If (r && !CheckInclude_Arr(keywords, MapFuncName(r))) ; ɸ�����ִ��Լ��ؼ���(�� r �ĺ������� keywords �����Ƚ�)
            result .= r . "`n"

        If (oldPos = pos)
            Break ;λ�ò��ٱ仯����ֹ
    }

    Return result
}

Filter(str, pattern)
{
    RegExMatch(str, pattern, result)
    Return result1
}

MapFuncName(fullStr)
{
    pattern := "(\w*\s*(?=\())"
    Return Trim(Filter(fullStr, pattern), "`n`r ")
}

CheckInclude_Arr(array, hope)
{
    StringLower, hope, hope
    for index, value in array
    {
        StringLower, value, value
        if (value == hope)
            Return true
    }
    Return False
}

; ���������е�һ��ֵ
Send_Arr(array, key)
{
    SendInput % array[key]
}

; ����ҵ��ļ��򷵻�·��
SearchFile_EveryThing(name, fileType) {
    fullname := ""
    FindStr := "file: " . name . "*" . fileType

    dll := A_PtrSize = 8 ? "Everything64.dll" : "Everything32.dll"
    dll := RegExReplace(A_AhkPath, "[^\\]+$", dll)

    hModule := DllCall("LoadLibrary", "Str", dll, "Ptr"), dll .= "\"
    DllCall(dll . "Everything_SetSearch", "Str", FindStr)
    DllCall(dll . "Everything_SetRequestFlags", "int" , (EVERYTHING_REQUEST_FILE_NAME := 0x00000001) | (EVERYTHING_REQUEST_PATH := 0x00000002))
    DllCall(dll . "Everything_Query", "int", 1)

    VarSetCapacity(fullname, 255, 0)
    DllCall(dll . "Everything_GetResultFullPathName", "int", 0, "Str", fullname, "int", 255)
    DllCall("FreeLibrary", "Ptr", hModule)

    return fullname
}

ShowSplashText(title, message, timeout := 0)
{
    CloseWin()
    ; FM title's size
    ; WM title's style

    SplashTextOn, 600, 300
    Sleep, 50
    Progress, b CBFFFFFF FM12 WM500 FS15 WS200, `n`n%message%`n`n, %title%, ,
    if (timeout > 0)
    {
        SetTimer, CloseAction, -%timeout%
    }
    return False

    CloseAction:
    CloseWin()
    return True
}

Wifi_IsNear(ssid)
{
    Return RunCmd_IsValueExisted("netsh wlan show networks mode=bssid", ssid)
}

Wifi_IsConnected(ssid)
{
    Return Wifi_Current() = ssid
}

Wifi_Current()
{
    result := RunCmd_GetFullResult("netsh wlan show interfaces")
    Return Filter(result, "SSID\s+:\s(.+)") ; "" -> δ����
}

; չʾ���
Wifi_Connect(ssid)
{
    msg := RunCmd_GetFullResult("netsh wlan connect name=" . ssid)
    result := InStr(msg, "��", False, 1, 1) > 0
    If (msg)
        ShowSplashText("", msg, 800)

    Return result
}

; չʾ���
Wifi_Disconnect()
{
    msg := RunCmd_GetFullResult("netsh wlan disconnect")
    ShowSplashText("", msg, 800)
}

; ��ȡ ipv4 ��ַ
GetIPAddress()
{
    str := ""
    objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
    colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
    while colItems[objItem]
    {
        Return % objItem.IPAddress[0]
    }
}

; ��ȡ������
; �������� cmd ���ͨ���������ȡ���
GetText_Clipboard(order := "")
{
    result := ""
    previous := ClipboardAll ; backup

    Clipboard := "" ; clear

    If (order) ; using CMD
    {
        RunWait % ComSpec " /c " . order . " | CLIP", , Hide
        ClipWait 2
    }
    Else ; directly copy
    {
        Send, ^c
        ClipWait, 0.3
    }

    result := Clipboard
    Clipboard := previous ; restitute
    Return result
}