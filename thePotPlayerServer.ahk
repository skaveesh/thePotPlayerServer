#Persistent
#SingleInstance, force
SetBatchLines, -1

#include resource/AHKhttp.ahk
#include resource/AHKsock.ahk

paths := {}
paths["/"] := Func("Index")
paths["/playercmd"] := Func("PlayerCmd")
paths["/keycmd"] := Func("KeyCmd")
paths["404"] := Func("NotFound")

server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/resource/mime.types")
server.SetPaths(paths)
server.Serve(8000)
return

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("Page not found")
}

Index(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/resource/index.html")
    res.status := 200
}

PlayerCmd(ByRef req, ByRef res) {
    playerCmd := req.queries["cmd"]

    SendMessage,0x0111,playerCmd,,,ahk_class PotPlayer64 ; this is for normal commands

    res.SetBodyText("Player command: " + playerCmd)
    res.status := 200
}

KeyCmd(ByRef req, ByRef res) {
    keyCmd := req.queries["cmd"]
    vkKeyCmd := GetKeyVK(keyCmd)

    SendMessage,0x0400,0x5010,vkKeyCmd,,ahk_class PotPlayer64 ; this is for sending key command like VK_UP, VK_DOWN

    res.SetBodyText(Format("Key code: `{}` `nVK key code: `{}`" ,keyCmd ,vkKeyCmd))
    res.status := 200
}


/*	
Use one of the numbers from the commands below with the PotPlayer(msg)
function to call commands not included in this library.  

Use only the number, example: the Open File function = PotPlayer(10158)

These commands use 0x0111 as the Msg parameter.
local CMD_PLAY              = 20001;
local CMD_PAUSE             = 20000;
local CMD_STOP              = 20002;
local CMD_PREVIOUS          = 10123;
local CMD_NEXT              = 10124;
local CMD_PLAY_PAUSE        = 10014;
local CMD_VOLUME_UP         = 10035;
local CMD_VOLUME_DOWN       = 10036;
local CMD_TOGGLE_MUTE       = 10037;
local CMD_TOGGLE_PLAYLIST   = 10011;
local CMD_TOGGLE_CONTROL    = 10383;
local CMD_OPEN_FILE         = 10158;
local CMD_TOGGLE_SUBS       = 10126;
local CMD_TOGGLE_OSD        = 10351;
local CMD_CAPTURE           = 10224;


These commands use 0x0400 as the Msg parameter
POT_GET_VOLUME   0x5000 // 0 ~ 100
POT_SET_VOLUME   0x5001 // 0 ~ 100
POT_GET_TOTAL_TIME  0x5002 // ms unit
POT_GET_PROGRESS_TIME 0x5003 // ms unit
POT_GET_CURRENT_TIME 0x5004 // ms unit
POT_SET_CURRENT_TIME 0x5005 // ms unit
POT_GET_PLAY_STATUS  0x5006 // -1:Stopped, 1:Paused, 2:Running
POT_SET_PLAY_STATUS  0x5007 // 0:Toggle, 1:Paused, 2:Running
POT_SET_PLAY_ORDER  0x5008 // 0:Prev, 1:Next
POT_SET_PLAY_CLOSE  0x5009
POT_SEND_VIRTUAL_KEY 0x5010 // Virtual Key(VK_UP, VK_DOWN....)
*/