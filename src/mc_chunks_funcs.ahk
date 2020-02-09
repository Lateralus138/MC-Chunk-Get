FindMinecraftChunk(x,y,array:=0){
	for idx, item in [x,y]
		if item is not integer
			return
	while (mod(x,16)!=0)
		x-=1
	while (mod(y,16)!=0)
		y-=1
	return !array	?	x "," y " to " x+15 "," y+15
					:	{	"From":	{	"X":x
									,	"Y":y}
						,	"To":	{	"X":x+15
									,	"Y":y+15}}
}
OnMessages(msgObj){
	if IsObject(msgObj){
		for msg, func in msgObj 
			OnMessage(msg,func)
		return ! ErrorLevel
	}
}
WM_MOUSEMOVE(prms*){
	global
	local		xy:=HiLoBytes(prms[2])
			,	x:=xy.Low	,	y:=xy.High
	cntrlId		:=WinExist("ahk_id " prms[4])
	overXBttn	:=((cntrlId=HeaderProgHwnd) And (x>=336) And (y<=32))
	overXHBttn	:=((cntrlId=HeaderHProgHwnd) And (x>=336) And (y<=32))
	overClear	:=(cntrlId=ClearProgHwnd)
	overXEdit	:=(cntrlId=XEHwnd)
	overYEdit	:=(cntrlId=YEHwnd)
	overCopy	:=(cntrlId=CopyProgHwnd)
	overShow	:=(cntrlId=ShowEdit)
	overTitle	:=(cntrlId=HeaderProgHwnd)
	overHTitle	:=(cntrlId=HeaderHProgHwnd)
	if overShow
	{	while GetKeyState("LButton","P")
			return
	}
}
WM_LBUTTONDOWN(prms*){
	global
	if overShow
	{	while GetKeyState("LButton","P")
			return
	}
	if overXBttn
		exitapp
	if overXHBttn
	{	Help.Destroy()
		Help:=""
	}
	if overTitle
	{	PostMessage, 0xA1, 2,,,% "ahk_id " Gui.Hwnd
		return
	}
	if overHTitle
	{	PostMessage, 0xA1, 2,,,% "ahk_id " Help.Hwnd
		return
	}
	if overClear
		ClearInterface()
	if overCopy
		SetClip(ResultVar)
}
SetClip(ByRef ResultVar){
	if ResultVar
	{	timedToolTip(quote(ResultVar) " copied to the clipboard",3000)
		Clipboard:=ResultVar
	}
}
ClearInterface(){
	global
	GuiControl,,XEVar,% ""
	GuiControl,,YEVar,% ""
	GuiControl,,ResultVar,% ""
	Gui.Submit("NoHide")
	GuiControl,,bTxtVar,% "Boundaries of X: " XEVar ", Y: " YEVar
}
WM_KEYDOWN(prms*){
	global
	if !(overXEdit Or overYEdit){
		if (Chr(prms[1])="c")
			ClearInterface()
		if (Chr(prms[1])="p")
			SetClip(ResultVar)
	}
}
TrimNonNumeric(string,added*){
	possible:="0,1,2,3,4,5,6,7,8,9"
	if added.MaxIndex()
		for idx, add in added
			possible.="," add
	loop,parse,string
		if A_LoopField in %possible%
			ret.=A_LoopField
	return ret
}
WM_KEYUP(prms*){
	global
	Gui.Submit("NoHide")
	XE:=TrimNonNumeric(XEVar,"-","+")
	YE:=TrimNonNumeric(YEVar,"-","+")
	hl:=HiLoBytes(prms[2])
	local		VK:=DecToHex(prms[1])
			,	SC:=StrReplace(DecToHex(hl.High),"C0")
	if (XEVar!=XE){
		WinGetPos,XEPos,YEPos,WEPos,HEPos,ahk_id %XEHwnd%
		WinGetPos,GXPos,GYPos,,,% "ahk_id " Gui.Hwnd
		timedToolTip("Numeric symbols and -/+ operators only",3000,XEPos-GXPos,(YEPos-GYPos)+HEPos,,"Client")
		GuiControl,,XEVar,%XE%
		send,{End}
	}
	if (YEVar!=YE){
		WinGetPos,XEPos,YEPos,WEPos,HEPos,ahk_id %YEHwnd%
		WinGetPos,GXPos,GYPos,,,% "ahk_id " Gui.Hwnd
		timedToolTip("Numeric symbols and -/+ operators only",3000,XEPos-GXPos,(YEPos-GYPos)+HEPos,,"Client")
		GuiControl,,YEVar,%YE%
		send,{End}
	}
	Gui.Submit("NoHide")
	GuiControl,,bTxtVar,% "Boundaries of X:" XEVar " , Y:" YEVar
	GuiControl,,ResultVar,% ((XEVar!="") And (YEVar!=""))?FindMinecraftChunk(XEVar,YEVar):""
	Gui.Submit("NoHide")
}
HiLoBytes(bytes,array:=0){
	return	!	array
			?	{"High":(bytes>>16) & 0xffff,"Low":bytes & 0xffff}
			:	[(bytes>>16) & 0xffff,bytes & 0xffff]
}
killToolTip(byId:=0){
	if current_tt:=WinExist("ahk_class tooltips_class32"){
		if (byId+0)
		{	if (winexist("ahk_id " byId)=current_tt)
			{	winclose,ahk_id %byId%
				return ! winexist("ahk_id " byId)
			}else	return
		}else
		{	winclose,ahk_id %current_tt%
			return ! winexist("ahk_id " current_tt)		
		}	
	}
}
bubbleToolTip(str,x:="",y:="",idx:=1,coordmode:="Screen",addStyles*){
	If (idx>20 Or !(idx+0))
		Return
	If addStyles.MaxIndex()
		For idx, hex in addStyles
			addedS+=hex
	CoordMode,ToolTip,%coordmode%
	ToolTip,% " ",%x%,%y%,%idx%
	id:=WinExist("ahk_class tooltips_class32")
	WinSet,Style,%addedS%+0x94000044,% "ahk_id " WinExist("ahk_id " id)
	ToolTip,%str%,%x%,%y%,%idx%
	CoordMode,ToolTip
	Return id
}
timedToolTip(txt,time:=1500,x:="",y:="",idx:=1,coordmode:="Screen"){
	id:=bubbleToolTip(txt,x,y,idx,coordmode)
	killTip:=Func("killToolTip").Bind(id)
	SetTimer,%killTip%,% "-" time
	return id
}
HexToDec(hex){
	l:=StrLen(hex)
	h:=	{	0:0		,1:1	,2:2	,3:3
		,	4:4		,5:5	,6:6	,7:7
		,	8:8		,9:9	,"A":10	,"B":11
		,	"C":12	,"D":13	,"E":14	,"F":15	}
	loop,%l%
		res+=(h[SubStr(hex,A_Index,1)]*(16**(l-A_Index)))
	return res
}
DecToHex(num){
	if num is not number
		return
	restore:=A_FormatInteger
	SetFormat,IntegerFast,H
	num+=0
	SetFormat,Integer,%restore%
	return num
}
quote(string,mode:=0) ; mode defaults to double quotes
{	mode:=!mode?"""":"`'"
	return mode string mode
}
#Include C:\Users\FluxApex\Documents\AutoHotkey\Projects\Abyss Search\Gui.aclass
; #Include, C:\Users\FluxApex\Documents\AutoHotkey\Libraries\_Gui.aclass