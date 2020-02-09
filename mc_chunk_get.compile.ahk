;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ╓────────────────────────────────────────────────────────────────────────────╖        ;
; ║ Plans for a rewrite with my newer _Gui class & in Python for CrossPlatform ║        ;
; ╙────────────────────────────────────────────────────────────────────────────╜        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                       ;
; MC Chunk Get - Ian Pride - © NPS Services - 2018-2020									;
; Lateralus138 A.K.A. FluxApex															;
; There was a long hiatus on this.                                                      ;
;                                                                                       ;
; Simple Gui that retrieves the 2 sets of x,z coordinates of the 2 opposite corners of 	;
; a chunk based on the sinlge x,z coordinates you provide - gets chunk perimeter of a 	;
; location in Minecraft.																;
;                                                                                       ;
; Any Minecrafter knows what this is needed for, but for those who don't I'll give a	;
; brief (vague) explanation:															;
; A chunk in Minecraft is a 16x16 block area in a 2d plane (x,z coordinates). There are ;
; various reasons this is important, but especially for building slime and villager		;
; breeder farms and to know where chunk boundaries are for controlling mob spawning.	;
;                                                                                       ;
; Of course, this is already available online on some great sites that I appreciate,	;
; but I wanted something offline and small so I don't always need to pull up a browser.	;
; This utility does not provide any other information (no slime chunks).				;
;                                                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Directives                                                                     ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#NoEnv
#SingleInstance,Force
#NoTrayIcon
SetBatchLines, -1
SetWinDelay, 0
OnMessages(	{	0x200:"WM_MOUSEMOVE"
			,	0x201:"WM_LBUTTONDOWN"
			,	0x100:"WM_KEYDOWN"
			,	0x101:"WM_KEYUP"	})
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Vars                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Const																					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TITLE 	:= "MC Chunk Get"
COLOR	:=	{	"MAIN_BG"			:"0xD782AF"		;
			,	"MAIN_GRAY"			:"0x272822"		;
			,	"MAIN_2"			:"0x34A549"		;
			,	"MAIN_3"			:"0x86BF7A"		;
			,	"MAIN_FG"			:"0xD8E9D6"		;
			,	"MAIN_RED"			:"0xE81123"		;
			,	"MAIN_BLACK"		:"0x1D1D1D"		;
			,	"MAIN_WHITE"		:"0xFEFEFE"		}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Vars                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui:=New Gui("Main")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Interface                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui.Margin(0,0)
Gui.Options("-Caption","+Border")
Gui.Color(COLOR.MAIN_FG,COLOR.MAIN_WHITE)
Gui.Font("Segoe UI","q2","s14","c" COLOR.MAIN_FG)
Gui.CustomButton(	TITLE,,COLOR.MAIN_FG,,,384,32,COLOR.MAIN_GRAY
				,	COLOR.MAIN_GRAY,"HeaderProgVar","HeaderTxtVar"
				,	"HeaderProgHwnd","HeaderTxtHwnd")
Gui.Font("Segoe UI","s18","c" COLOR.MAIN_WHITE)
Gui.CustomButton(	"X",,COLOR.MAIN_WHITE,336,0,48,32,COLOR.MAIN_RED
				,	COLOR.MAIN_RED,"XProgVar","XTxtVar"
				,	"XProgHwnd","XTxtHwnd")
Gui.Font("Segoe UI","c" COLOR.MAIN_BLACK,"s12")
Gui.Text("Provide x,z cooridnates to get its current boundaries","w368","x8","y+4","Section","+Center",+0x200)
Gui.Text("X:","xs","y+8","w24","h24","+Center",+0x200)
Gui.Edit("","x+0","yp","w108","h24","-E0x384","HwndXEHwnd","vXEVar","c" COLOR.MAIN_RED)
Gui.Text("Z:","x+0","yp","w24","h24","+Center",+0x200)
Gui.Edit("","x+0","yp","w108","h24","-E0x384","HwndYEHwnd","vYEVar","c" COLOR.MAIN_RED)
Gui.Font("Segoe UI","s10")
Gui.CustomButton(	"&Clear",,COLOR.MAIN_FG,"+8","p",96,24,COLOR.MAIN_GRAY
				,	COLOR.MAIN_GRAY,"ClearProgVar","ClearTxtVar"
				,	"ClearProgHwnd","ClearTxtHwnd")
Gui.Font("Segoe UI","s12")
Gui.Text("Boundaries of X: , Z: ","xs","y+8","w368","vbTxtVar")
Gui.Font("Segoe UI","s14","c" COLOR.MAIN_RED)
Gui.Edit("","xs","y+8","w264","HwndShowEdit","-E0x384","+ReadOnly","vResultVar")
Gui.Font("Segoe UI","s10")
Gui.CustomButton(	"Co&py",,COLOR.MAIN_FG,"+8","p",96,24,COLOR.MAIN_GRAY
				,	COLOR.MAIN_GRAY,"CopyProgVar","CopyTxtVar"
				,	"CopyProgHwnd","CopyTxtHwnd")
Gui.Picture("imageres.dll","Icon77","xs","y+8","w24","h24","gHelpGui")
Gui.Text("About " TITLE,"x+8","yp","h24","c" COLOR.MAIN_GRAY,"+0x200")
Gui.Text("","xs","y+0","w368","h8")
Gui.Show(TITLE,"AutoSize")
Gui.Submit("NoHide")
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Functions                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    Gui.Submit("NoHide")
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
Class Gui {
	__New(guiLabel:="")
	{	this.guiName:=	guiLabel
						? 	(SubStr(guiLabel,StrLen(guiLabel))=":")
								?	guiLabel
								:	guiLabel ":"
						:	""
		this.Options("+LastFound")
		this.Hwnd:=WinExist()
		this.Options("-LastFound")
		this.LabelName:=SubStr(this.guiName,1,StrLen(this.guiName)-1)
	}
	Flash(Off:=0)
	{	global
		Gui,% this.guiName this.endFuncName(A_ThisFunc),% Off?"Off":""
	}
	Options(opts*)
	{	global
		Gui,% this.guiName this.listFromArray(opts)
	}
	Show(title:="",params*)
	{	Gui	,	% this.guiName this.endFuncName(A_ThisFunc)
			,	% params.MaxIndex()?this.listFromArray(params):"",%title%
	}
	Hide()
	{	Gui,% this.guiName this.endFuncName(A_ThisFunc)
	}
	Cancel()
	{	Gui,% this.guiName this.endFuncName(A_ThisFunc)
	}
	Destroy()
	{	Gui,% this.guiName this.endFuncName(A_ThisFunc)
	}
	Font(fontName,options*)
	{	Gui,% this.guiName "Font",% this.listFromArray(options),%fontName%
	}
	Margin(x,y)
	{	Gui,% this.guiName "Margin",%x%,%y%
	}
	Color(winClr:=0xFFFFFF,cntrlClr:=0x000000)
	{	Gui,% this.guiName "Color",% winClr?winClr:0x000000,% cntrlClr?cntrlClr:0x000000
	}
	Submit(noHide:=0)
	{	Gui,% this.guiName "Submit",% noHide?"NoHide":""
	}
	Text(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Edit(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	UpDown(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Picture(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Button(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Checkbox(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Radio(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	DropDownList(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	ComboBox(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	ListBox(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	ListView(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	TreeView(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Link(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Hotkey(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	DateTime(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	MonthCal(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Slider(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Progress(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	GroupBox(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Tab3(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	StatusBar(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	ActiveX(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	Custom(content:="",params*)
	{	global
		Gui,% this.guiName "Add",% this.endFuncName(A_ThisFunc),% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	New(content:="",params*)
	{	global
		Gui,% this.guiName "New",% params.MaxIndex()?this.listFromArray(params):"",%content%	
	}
	endFuncName(funcName)
	{	return StrSplit(funcName,".")[StrSplit(funcName,".").MaxIndex()]
	}
	CustomButton(	string,progSize:=100,txtClr:=""
				,	x:="+0",y:="+0",w:="",h:=""
				,	bgClr:="",fgClr:=""
				,	progVar:="",txtVar:="",progHwnd:="",txtHwnd:=""
				,	overlay:=false,hidden := false,wind := "Wind")
	{	global
		%progVar%:=progVar?progSize:"",%txtVar%:=txtVar?string:""
		this.Progress(progSize,"x" x,"y" y,"w" w,"h" h,"Background" bgClr,"c" fgClr,progVar?"v" progVar:"",progHwnd?"Hwnd" progHwnd:"",hidden?"Hidden":"")
		this.Text(string,txtClr?"c" txtClr:"","xp","yp","w" w,"h" h,"+BackgroundTrans","+Center",0x256,txtVar?"v" txtVar:"",txtHwnd?"Hwnd" txtHwnd:"",hidden?"Hidden":"")
		if overlay
			this.OverlayButton(w,h,h "-" h,wind,"ahk_id " %progHwnd%)
	}
	OverlayButton(w,h,radius:="",wind:="",win*)
	{	if id:=WinExist(win[1],win[2],win[3],win[4])
		{	if InStr(radius,"-")
			{	radiusArr:=StrSplit(radius,"-")
				if (radiusArr.MaxIndex()=2)
					radiusArr[1]:=radiusArr[1]-1,radiusArr[2]:=radiusArr[2]-1 ;radiusArr[1]-=1,radiusArr[2]-=1
				else
					radiusArr[1]:=30,radiusArr[2]:=30
			}
			WinSet,Region,% "1-1 " "w" w-1 " h" h-1 " R" radiusArr[1] "-" radiusArr[2] " " wind,ahk_id %id%
		}
	}
	ButtonSize(textSize,string)
	{	h:=textSize*3
		w:=textSize*StrLen(string)
		return {"W":w,"H":h}
	}
	listFromArray(array)
	{	if array.MaxIndex()
		{	list:=""
			for idxi, itemi in array
				list.=itemi A_Space			
		}
		return list
	}
}
HelpGui(){
	global
	local helpBlock, l1, l2, l3
l1=
(join `n
'MC Chunk Get' is a simple, little program to quickly
 retrieve chunk boundary coordinates. Great for
 planning/gridding anything you want to align on
 chunk edges (towns, farms, etc...) & especiallly
 great for large projects where you don't want to
 keep doing the math yourself. This application
 calculates as soon as you provide both cooridinates
 so it works quickly.
)
l2=
(join `n
Get the diagonal coordinates of the boundaries
 of a chunk by providing any x, z coodinates 
 inside of that chunk.
)
l3=
(join `n
E.g. X: 2, Z: 2 is passed and 0,0 - 15,15 is given.
)
helpBlock := l1 "`n`n" l2 "`n`n" l3
	Help:=New Gui("Help")
	Help.Margin(0,0)
	Help.Options("-Caption","+Border","+OwnerMain")
	Help.Color(COLOR.MAIN_FG,COLOR.MAIN_WHITE)
	Help.Font("Segoe UI","q2","s14","c" COLOR.MAIN_FG)
	Help.CustomButton(	"About " TITLE,,COLOR.MAIN_FG,,,384,32,COLOR.MAIN_GRAY
					,	COLOR.MAIN_GRAY,"HeaderHProgVar","HeaderHTxtVar"
					,	"HeaderHProgHwnd","HeaderHTxtHwnd")
	Help.Font("Segoe UI","s18","c" COLOR.MAIN_WHITE)
	Help.CustomButton(	"X",,COLOR.MAIN_WHITE,336,0,48,32,COLOR.MAIN_RED
					,	COLOR.MAIN_RED,"XHProgVar","XHTxtVar"
					,	"XHProgHwnd","XHTxtHwnd")
	Help.Font("Segoe UI","c" COLOR.MAIN_BLACK,"s12")
	Help.Text(helpBlock,"x8","y+16","w368")
	Help.Text("Me:","x8","y+8","h24")
	Help.Link("<a href="  quote("https://lateralus138.github.io") ">&GitHub.io</a>","x+8","yp","h24")
	Help.Link("<a href="  quote("https://github.com/Lateralus138") ">&Repositories</a>","x+8","yp","h24")
	Help.Link("<a href="  quote("https://twitter.com/TheFluxApex") ">&Twitter</a>","x+8","yp","h24")
	Help.Text("","x8","y+0","w368","h8")
	Help.Show()
}
; ╓──────╖
; ║ Subs ║
; ╙──────╜
HelpGuiEscape:
HelpGuiClose:
	Help.Destroy()
return
MainGuiClose:
    Help.Destroy()
    Main.Destroy()
    ExitApp
