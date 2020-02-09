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
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Functions                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include C:\Users\FluxApex\Documents\AutoHotkey\Projects\MC Chunks\mc_chunks_funcs.ahk
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