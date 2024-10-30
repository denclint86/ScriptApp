#Include DudeDealer.ahk
#Include NetworkActions.ahk
#Include MainFunctions.ahk
#Include AutoBackup.ahk
#Include Crypt.ahk
#NoTrayIcon ; ����ʾСͼ��

#SingleInstance force ; ����ģʽ

global dudesPath := A_AppData . "\WannaTakeThisDownTown" ; �����ļ���·��
global password := PasswordInput() ; Ҫ����������
; global password :=  ; Ҫ����������

if !FileExist(dudesPath)
    FileCreateDir, %dudesPath%

Sleep 300

global configs := FullDudeReader(dudesPath . "\configs.dude","")
global apps := FullDudeReader(dudesPath . "\apps.dude","")
global privacies := FullDudeReader(dudesPath . "\privacies.dude", password)
global paths := FullDudeReader(dudesPath . "\paths.dude", password)
global urls := FullDudeReader(dudesPath . "\urls.dude", password)
global nameless := FullDudeReader(dudesPath . "\nameless.dude", "")

global vsPAth := paths["vs"]

global loginHeadUrl := urls["i1"] . privacies["no"] . urls["i2"] . privacies["sdcd"] . urls["i3"]
global loginTailUrl := urls["i4"]
global logoutHeadUrl := urls["o1"]
global logoutTailUrl := urls["o2"]

; class Person {
; static defaultAge := 18  ; ��̬����

; name := ""  ; ʵ������
; age := 0

; __New(name, age := "") {
; ���캯��
; this.name := name
; if (age != "") {
; this.age := age
;     } else {
;         this.age := Person.defaultAge  ; ���ʾ�̬����
;     }
; }

; sayHello() {
;     ; ʵ������
;     MsgBox % "Hello, my name is " this.name " and I'm " this.age " years old."
; }
; }

; p1 := new Person("John", 25)
; p2 := new Person("Jane")

; ���÷���
; p1.sayHello()
; p2.sayHello()

if(ObjCount(privacies) != 1)
{
    BuildHotstrings_Send(privacies)
    BuildHotStrings_Run(paths)
    BuildHotStrings_Run(urls)

    Try
    {
        Backup()
    }
    Catch
    {
        Sleep 20000
        Backup()
    }
}

Return

:*:rd\::
    t := ReadFunctionsInFile()
    If (t)
        Clipboard := t
Return

:*:read\::
    t := ReadFunctionsInFolder()
    If (t)
        Clipboard := t
Return

; ������� ip
:*:ip\::
    SendInput % GetIPAddress()
Return

; �������������� localhost
:*:wyy\::
    Run %ComSpec% /c npx NeteaseCloudMusicApi, , Minimize
Return

; �ű�Ŀ¼
:*:app\::
    Run % A_ScriptDir
Return

:*:``12::
    Reload
Return

; �ֶ�����
:*:bu\::
    BackUp()
Return

:*:ed\::
    UpdateData(configs, password)
Return

:*:dd\::
    Run % dudesPath
Return

:*:cg\::
    password := ChangePassword(password)
Return

:*:ex\::
ExitApp

; �����߼�ϵͳ����
:*:se\::
    Run sysdm.cpl
Return

; ������Դ������
:*:rf\::
    RunWait %ComSpec% /c taskkill /f /im explorer.exe & start explorer.exe, , Hide
Return

; ͨ�� powershell �ű������ȵ�
:*:hs\::
    ; ��Ҫ����Ȩ�޲������нű�, ���н�����ԭȨ������
    ; Set-ExecutionPolicy Unrestricted
    ; Set-ExecutionPolicy Restricted
    RunCmd_GetFullResult("powershell.exe -Command Set-ExecutionPolicy Unrestricted")
    ShowSplashText("Hotspot", RunCmd_GetFullResult("powershell.exe -Command D:; cd " . A_ScriptDir . "; .\hotspot.ps1"), 1500)
    RunCmd_GetFullResult("powershell.exe -Command Set-ExecutionPolicy Restricted")
Return

; ʹ����˯��
:*:sl\::
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

; �� wifi
:*:dc\::
    Wifi_Disconnect()
Return

; ��У԰��
:*:lk\::
    Gdut()
Return

; �����ں�̨���� shizuku
:*:szk\::
    RunWait %ComSpec% /c adb devices, , Hide
    RunWait %ComSpec% /c adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh, , Hide
Return

;----�����ǿ�ݼ�----

^!S:: ; ctrl + shift + s -> bing ����ѡ�е��ı�
    Action_UseBrowser("Search", urls["sc"]) ; sc -> search
Return

^!T::
    Action_UseBrowser("Translate", urls["ts"]) ; ts -> translate
Return
#T::
    Action_Translate()
Return
^!Z::
    Run_OnLocalHost(urls["lh"])
Return

^!W:: ; ���� alt + F4 ����
    SendInput !{F4}
Return

; bվ������̫��������д��������һ���൱�ڵ�� 4 ��
; ֻҪ��ס '/' ���������Ҽ�����
~Right & /::
    Loop % 4
    {
        Sleep 10
        SendInput {Right}
    }
Return
~left & /::
    Loop % 4
    {
        Sleep 10
        SendInput {left}
    }
Return

; �������� - ͬ��
~Up & /::
    SoundSet +5
Return
~Down & /::
    SoundSet -5
Return

^1:: ; �༭���е� ahk �ű�
    Loop % apps.MaxIndex()
    {
        a := A_ScriptDir "/" apps[A_Index]
        Run %vsPAth% %a%
    }
Return

^`:: ; �༭ Main.ahk
    Run %vsPAth% %A_ScriptFullPath%
Return

Alt & x:: ; �Ҽ�����¼�
    SendInput {AppsKey}
Return

; �໥ӳ�� [�����ʽ��] ��ݼ�
#IfWinActive ahk_exe Code.exe
    ^!l::
        Send !+f
    return
#IfWinActive

#IfWinActive ahk_exe studio64.exe
    !+f::
        Send ^!l
    return
#IfWinActive