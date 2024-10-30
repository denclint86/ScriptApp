#Include Crypt.ahk
#Include MainFunctions.ahk

global dudesPath := A_AppData . "\WannaTakeThisDownTown"
global configsDefault := "1<[]>configs`n2<[]>paths`n3<[]>privacies`n4<[]>urls`n5<[]>apps"
global appsDefault := "1<[]>AutoBackup.ahk`n2<[]>DudeDealer.ahk`n3<[]>Main.ahk`n4<[]>MainFunctions.ahk`n5<[]>NetworkActions.ahk"
global othersDefault := "default<[]>default"

global globalValues := {}
globalValues["\configs.dude"] := configsDefault
globalValues["\apps.dude"] := appsDefault
globalValues["\nameless.dude"] := othersDefauecklt

; �������ı����ؼ�ֵ��
SimpleReader(content)
{
    values := {}
    Loop, Parse, content, `n, `r ; �ָ��ı�Ϊѭ���ķ�ʽ
    {
        if (Trim(A_LoopField) = "")
        {
            continue
        }

        position := InStr(A_LoopField, "<[]>")

        if (position > 0) {
            key := Trim(SubStr(A_LoopField, 1, position - 1))
            value := Trim(SubStr(A_LoopField, position + 4))
            values[key] := value
        }
    }

    Return values
}

; ��������Ĭ�ϵļ�ֵ��
DefaultReader(filePath)
{
    for key, value in globalValues ; globalValues -> ["/a.dude"] to "assd<[]>asasfafs"
    {
        if (filePath = dudesPath . key) ; ������������õ�ֵ��ʹ��
        {
            Return SimpleReader(value)
        }
    }

    Return SimpleReader(othersDefault) ; ��û����ʹ��һ���򵥼�ֵ��
}

; д��Ĭ��ֵ
DefautWriter(filePath, password)
{
    if(FileExist(filePath))
    {
        FileDelete, %filePath%
    }

    for key, value in globalValues
    {
        if (filePath = dudesPath . key)
        {
            Return RawWriter(filePath, value, password)
        }
    }

    RawWriter(filePath, othersDefault, password)
}

; ͨ��·�����ı���ȡ�ļ�
FullDudeReader(filePath, password)
{
    password := FormatPassword(filePath, password) ; ��ȡ"������"
    readable := Readable(filePath, password) ; ���ı�
    if(!FileExist(filePath)) ; д��һ�� �����Ǽ���ļ����������򴴽��� password Ϊ�����Ĭ���ļ�
    {
        DefautWriter(filePath, password)
        ShowSplashText("Full Reader", """" . filePath . """: write default data", 1500)
        Return DefaultReader(filePath)
    }
    if(readable = "")
    {
        Return DefaultReader(filePath)
    }
    else
    {
        Return SimpleReader(readable)
    }
}

; ֱ�����ԭ�ļ����ݲ�д�� content
RawWriter(filePath, content, password, tell := False){
    password := FormatPassword(filePath, password)

    content := Encrypt(content, password) ; encrypt raw text into "AS7ASBBSJW..."

    if (FileExist(filePath))
    {
        FileDelete, %filePath% ; delete first
    }
    Try
    {
        FileAppend, , %filePath%
        FileAppend, %content%, %filePath%
        if(tell)
        {
            ShowSplashText("Raw Writer", """" . filePath . """: successful", 1500)
        }
        Return True
    }
    Catch
    {
        ShowSplashText("Raw Writer", """" . filePath . """: failed", 1500)
        Return False
    }
}

; δ��ʹ�ã��������ҷ���
; �޸��ļ��ĺ���û��ʹ������������Կ��Ը��Ǿ�ֵ
FullDudeWriter(filePath, values, password)
{
    password := FormatPassword(filePath, password) ; real password
    content := "" ; raw text

    existingValues := FullDudeReader(filePath, password) ; pairs that existed

    for key, value in values
    {
        if existingValues.HasKey(key)
        {
            ; if existed then override the old value
            content .= key "<[]>" existingValues[key] "`n"
        }
        else
        {
            ; directly write into content
            content .= key "<[]>" value "`n"
        }
    }

    RawWriter(filePath, content, password) ; write the raw text into file
}

; editor
UpdateData(list, password) {
    global
    pw := password
    lt := list
    nm := lt.MaxIndex()
    editable := False

    Gui, Destroy
    Gui, Font, s14
    Gui, Add, DropDownList, vChoice gOnChoiceChange
    Loop % nm
    {
        GuiControl, , Choice, % lt[A_Index]
    }
    Gui, Add, Edit, vEdited r30 w600 h20
    Gui, Add, Button, gDoSave w80 h30, Save
    Gui, Add, Button, gDoCancel x+20 w80 h30, Cancel
    Gui, Show,, Editing Dudes
    Return

    OnChoiceChange:
    Gui, Submit, NoHide
    Loop % nm
    {
        if(lt[A_Index] = Choice)
        {
            address := FormatAddress(lt[A_Index])
            if ( Readable(address, pw) != "")
            {
                editable := True
            }
            else
            {
                ShowSplashText("Change Password", "wrong password", 2000)
                Gui, Destroy
                Return
            }
            GuiControl, Text, Edited, % FormatData(FullDudeReader(address, pw))
        }
    }
    Return

    DoSave:
    Gui, Submit, NoHide
    if (Choice = "")
    {
        Msg("haven't choose file!")
        Return
    }
    Loop % nm
    {
        if(lt[A_Index] = Choice)
        {
            address := FormatAddress(lt[A_Index])
            FormatAddress(lt[A_Index])
            RawWriter(address, Edited, pw, True)
        }
    }
    Return

    DoCancel:
    GuiClose:
    GuiEscape:
    Gui, Destroy
    Return
}

; change the data to different password
ChangePassword(password){
    configs := FullDudeReader(dudesPath . "\configs.dude","default")
    count := configs.MaxIndex()
    old := ""
    InputBox, old, , Enter your old password:
    Loop % count
    {
        address := FormatAddress(configs[A_Index])
        if(Readable(address, old) = "")
        {
            ShowSplashText("Change Password", "wrong password", 2000)
            Return password
        }
    }
    new := ""
    InputBox, new, , Enter your new password:

    Try
    {

        Loop % count
        {
            ; MsgBox, % configs[A_Index]
            address := FormatAddress(configs[A_Index])
            values := FullDudeReader(address, old)
            str := FormatData(values)
            RawWriter(address, str, new)
        }
        ShowSplashText("Change Password", "successful", 1000)
        Return new
    }
    Catch
    {
        ShowSplashText("Change Password", "wrong password", 1000)
        Return password
    }
}

; ask to enter password
PasswordInput()
{
    InputBox, str, , Enter your password:`n`nOr set a new password:
    Return str
}

; ��������һ������
; ����������ļ�, �ɹ�ʱ�������ı� ��asdsa<[]>asdas\n...��
Readable(filePath, password)
{
    password := FormatPassword(filePath, password)
    FileRead, str, %filePath%
    Return Decrypt(str, password)
}

; ����Ƿ�ΪĳЩ��ʹ��������ļ�, �������������ΪĬ������
FormatPassword(filePath, password)
{
    for key, value in globalValues
    {
        if (filePath = dudesPath . key)
        {
            Return "default"
        }
    }
    Return password
}

; ����ֵ�Զ������Ϊһ���ַ���
FormatData(values)
{
    content := ""
    for key, value in values
    {
        content .= key "<[]>" value "`n"
    }
    Return content
}

; �����ļ������� '.../.../.../name.dude'
FormatAddress(name)
{
    return dudesPath "\" name ".dude"
}

; �����ַ���, Ӧ�ò����ߵ� catch ��
; AES-256
Encrypt(str, password)
{
    Try
    {
        values := Crypt.Encrypt.StrEncrypt(str, password, 3, 1)
        Return values
    }
    Catch
    {
        Return ""
    }
}

; ���������򷵻ؿ��ִ�
; AES-256
Decrypt(str, password)
{
    Try
    {
        values := Crypt.Encrypt.StrDecrypt(str, password, 3, 1)
        Return values
    }
    Catch
    {
        Return ""
    }
}