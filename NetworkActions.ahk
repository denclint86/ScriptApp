#Include MainFunctions.ahk

global GDUT_SSID := "gdut"
global RETRY_COUNT := 5

GDUT()
{
    If(GDUT_TryConnect())
        GDUT_TryLogin()
}

; �������� gdut
GDUT_TryConnect()
{
    count := RETRY_COUNT

    While (count)
    {
        If (Wifi_IsConnected(GDUT_SSID))
            Return True
        If (Wifi_IsNear(GDUT_SSID))
            If (Wifi_Connect(GDUT_SSID))
                Return True
        count--
    }

    ShowSplashText("GDUT", "failed to connect", 800)
    Return False ; ��γ����޹�
}

GDUT_TryLogin()
{
    count := RETRY_COUNT

    While (count)
    {
        Try
        {
            result := ""

            url := loginHeadUrl . GetIPAddress() . loginTailUrl

            result := Web_Get(url)

            If (result)
            {
                ShowSplashText("GDUT", GDUT_ParseMsg(result), 800)
                Return True
            }
        }
        Catch
        {
        }
        count--
    }

    ShowSplashText("GDUT", "failed to login", 800)
    Return False ; ��γ����޹�
}

GDUT_ParseMsg(json)
{
    RegExMatch(json, "i)""msg""\s*:\s*""(.+?)""", data)
    return data1
}