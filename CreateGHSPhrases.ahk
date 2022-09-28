#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
;#Persistent
; #Warn All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;DetectHiddenWindows, On
;SetKeyDelay -1
SetBatchLines -1
SetTitleMatchMode, 2
Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,78 ;Set custom Script icon
;ntfy:=Notify()
;;_____________________________________________________________________________________
;{#[General Information for file management]
#Include, <ScriptObj/ScriptObj>
FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
global script := {   base         : script
                    ,name         : regexreplace(A_ScriptName, "\.\w+")
                    ,version      : "2.7.1"
                    ,author       : "Gewerd Strauss"
					,authorlink   : "https://github.com/Gewerd-Strauss"
                    ,email        : ""
                    ,credits      : "berban,RaptorX,Lexikos,jNizM"
					,creditslink  : "https://github.com/Gewerd-Strauss/Create-GHS-Phrases#code-by-others"
                    ,crtdate      : CrtDate
                    ,moddate      : ModDate
                    ,homepagetext : "Report a bug"
                    ,homepagelink : "https://github.com/Gewerd-Strauss/Create-GHS-Phrases/issues"
                    ,ghtext 	  : "Github Repository"
                    ,ghlink       : "https://github.com/Gewerd-Strauss/Create-GHS-Phrases"
                    ,doctext	  : "Documentation"
                    ,doclink	  : "https://github.com/Gewerd-Strauss/Create-GHS-Phrases#create-ghs-phrases"
                    ,forumtext	  : "Forum"
                    ,forumlink	  : ""
                    ,donateLink   : ""  
                    ,configfolder : A_ScriptDir "\INI-Files"
                    ,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
                    ,libraryurl   : "https://gist.githubusercontent.com/Gewerd-Strauss/66c07fc5616a8336b52e3609cc9f36ef/raw/f9d2b785ba8259b58b768d2f4b13a498890de26c/gistfile1.txt"} ; please edit this link to select a different location to download the library from if so desired. This is done so users can easily set up and use the library for a different language. Please note that the section titles must remain the same, or more extensive code edits must be performed. If that is the case and problems arise, please open an issue on GitHub.
                    ; ,resfolder    : A_ScriptDir "\res"
                    ; ,iconfile     : A_ScriptDir "\res\sct.ico"
;}______________________________________________________________________________________
;{#[File Overview]
Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,234 ;Set custom Script icon
 ;Set custom Script icon
;menu, Tray, Add, About, Label_AboutFile
;}______________________________________________________________________________________
;{#[Autorun Section]
bDownloadToFile:=1 ;!bDownloadToVariable 
f_CreateTrayMenu(VN)
if bDownloadToFile
{
	if FileExist(script.configfile) ; check if library exists. Additionally, 
		DataArr:=fReadIni(script.configfile) ; load the data of the
	Else
		gosub, lWriteLibraryFromHardCode
}
OnMessage(0x404, "f_TrayIconSingleClickCallBack")
return




;}______________________________________________________________________________________
;{#[Hotkeys Section]
!0::
Numpad0::
aSel:=StrSplit(fClip(),"`n")
global vNumErr:=1
str:=""
global ErrorString:=""
for k, v in aSel
{
	ErrorArr:=[]
	str.="`n"
	v:=StrReplace(v ,"`r","")
	v:=StrReplace(v,":","") ; remove ":" from string if existing
	{
		stype:=SubStr(v,1,1)
		if d:=(DataArr["P-Phrases"].HasKey(v) && !InStr(v,"+")?) ;(stype="P")
		{
			bHasVal1:=true
			str.=v ": " DataArr["P-Phrases"][v] 
		}
		Else
			bHasVal1:=false
		if DataArr["H-Phrases"].HasKey(v) && !InStr(v,"+") ;(stype="H")
		{
			bHasVal2:=true
			str.=v ": " DataArr["H-Phrases"][v] 
		}
		Else
			bHasVal2:=false
		if DataArr["Physical properties"].HasKey(v) && !InStr(v,"+") 
		{
			bHasVal3:=true
			str.=v ": " DataArr["Physical properties"][v] 
		}
		Else
			bHasVal3:=false
		if DataArr["Environmental properties"].HasKey(v) && !InStr(v,"+") 
		{
			bHasVal4:=true
			str.=v ": " DataArr["Environmental properties"][v]
		}
		else
			bHasVal4:=false
		if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(v) && !InStr(v,"+") 
		{
			bHasVal5:=true
			str.=v ": " DataArr["Supplemental label elements/information on certain substances and mixtures"][v]
		}
		else
			bHasVal5:=false
		if (!bHasVal1) and (!bHasVal2) and (!bHasVal3) and (!bHasVal4) and (!bHasVal5) ;|| InStr(v,"")
			if (v!="") and !InStr(v,"#")
				ErrorArr[v]:= "Error " vNumErr ": Key '" v "' could not be found on file. Please search and insert manually."
	}
	str:=StrReplace(f_ProcessErrors(ErrorArr,DataArr,str)," : ",A_Space)
}
newStr:=str 
ClipBoard:=newStr.= (ErrorString!="")?"`n`n`nERROR LOG (REMOVE AFTERWARDS)`n-----------------------------" ErrorString "`n-----------------------------":""
; newStr2:= str (ErrorString!="")?"`n`n`nERROR LOG (REMOVE AFTERWARDS)`n-----------------------------" ErrorString "`n-----------------------------":"" ;; why does this not concat properly??
fClip(newStr)
return


;}______________________________________________________________________________________
;{#[Label Section]


return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
script.about()
return
;}______________________________________________________________________________________
;{#[Functions Section]
/*
	
	H P E number 
*/
f_ProcessErrors(ErrorArr,DataArr,str)
{
	strCompoundAssembled:=""
	for k,v in ErrorArr
		strCompoundAssembled:=k
	for k,v in ErrorArr
	{
		; 1st-level combination search
		if DataArr["P-Phrases"].HasKey(k) 
			return str strCompoundAssembled.=": " DataArr["P-Phrases"][k]
		else if DataArr["H-Phrases"].HasKey(k) 
			return str strCompoundAssembled.=": " DataArr["H-Phrases"][k]
		else if DataArr["Physical properties"].HasKey(k) 
			return str strCompoundAssembled.=": " DataArr["Physical properties"][k]
		else if DataArr["Environmental properties"].HasKey(k) 
			return str strCompoundAssembled.=": " DataArr["Environmental properties"][k]
		else if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(k) 
			return str strCompoundAssembled.=": " DataArr["Supplemental label elements/information on certain substances and mixtures"][k]
		; 2nd-level compound creation
		strCompoundAssembled:=k 
		CompoundStatementArr:=StrSplit(k,"+")
		bWasFoundArr:=[]
		ErrorsFound:=[]
		for s,w in CompoundStatementArr
		{
			if DataArr["P-Phrases"].HasKey(w) ;(stype="P")
			{
				bHasVal1:=true
				strCompoundAssembled.=": " DataArr["P-Phrases"][w] 
			}
			Else
				bHasVal1:=false
			if DataArr["H-Phrases"].HasKey(w) ;(stype="H")
			{
				bHasVal2:=true
				strCompoundAssembled.=": " DataArr["H-Phrases"][w] 
			}
			Else
				bHasVal2:=false
			if DataArr["Physical properties"].HasKey(w)
			{
				bHasVal3:=true
				strCompoundAssembled.=": " DataArr["Physical properties"][w] 
			}
			Else
				bHasVal3:=false
			if DataArr["Environmental properties"].HasKey(w)
			{
				bHasVal4:=true
				strCompoundAssembled.=": " DataArr["Environmental properties"][w]
			}
			else
				bHasVal4:=false
			if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(w)
			{
				bHasVal5:=true
				strCompoundAssembled.=": " DataArr["Supplemental label elements/information on certain substances and mixtures"][w]
			}
			else
				bHasVal5:=false
			bIndentPhrase:=false
			if (!bHasVal1 && !bHasVal2 && !bHasVal3 && !bHasVal4 && !bHasVal5)
			{
				v:=RegExReplace(v,"(Error \d+:)", "Error " vNumErr ":")
				ErrorsFound.push(vNumErr)
				ErrorString.= "`n"  v " Specific phrase missing: " w
				bIndentPhrase:=true
				bPhaseWasIndented:=true
				strCompoundAssembled.= ": " w 
				vNumErr++
			}
			strCompoundAssembled.=" "
		}
		ErrorString:=RegExReplace(ErrorString,"^(?!.*Specific phrase missing.*).+$")
	}
	if bIndentPhrase  || bPhaseWasIndented ; aka we have errors
		return str A_Tab strCompoundAssembled
	else
		return str strCompoundAssembled
}

f_CreateTrayMenu(IniObj:="")
{ ; facilitates creation of the tray menu
	menu, tray, add,
	Menu, Misc, add, Open Script-folder, lOpenScriptFolder
	Menu, Misc, add, Search for GHS changes , lUpdateLibrary
	menu, Misc, Add, Reload, lReload
	menu, Misc, Add, About, Label_AboutFile
	menu, Misc, Add, How to use it, lExplainHowTo
	SplitPath, A_ScriptName,,,, scriptname
	Menu, tray, add, Miscellaneous, :Misc
	menu, tray, add,
	return
}
lOpenScriptFolder:
run, % A_ScriptDir
return
lReload: 
reload
return
lUpdateLibrary:
FileDelete, % script.configfile
reload
return
f_TrayIconSingleClickCallBack(wParam, lParam)
{ ; taken and adapted from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
	VNI:=1.0.3.12
	; 0x201 WM_LBUTTONDOWN
	; 0x202 WM_LBUTTONUP
	if (lParam = 0x202) || (lParam = 0x201)
	{
		menu, tray, show
		return 0
	}
}

HasVal(haystack, needle) 
{	; code from jNizM on the ahk forums: https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
    ; if !(IsObject(haystack)) || (haystack.Length() = 0)
    ; 	return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}
f_ThrowError(Source,Message,ErrorCode:=0,ReferencePlace:="S")
{ ; throws an error-message, possibly with further postprocessing
	if (ReferencePlace="D")
		Reference:="Documentation"
	else 
		Reference:="Source Code: Function called on line " ReferencePlace "`nError invoked in function body on line " Exception("", -1).Line
	if (ErrorCode!=0)
	{
		str=
	(
	Function: %Source%
	Errorcode: "%ErrorCode%" - Refer to %Reference%

	Error: 
	%Message%
	)
	}
	else
	{
		str=
	(
	Function: %Source%	
	Errorcode: Refer to %Reference%

	Error: 
	%Message%
	)
	}
	MsgBox, % str
	return
}


;}_____________________________________________________________________________________
;{#[Include Section]



;}_____________________________________________________________________________________

lWriteLibraryFromHardCode:
{
	
	LibraryBackup=
(
[H-Phrases]
H200=Unstable explosives.
H201=Explosive; mass explosion hazard.
H202=Explosive, severe projection hazard.
H203=Explosive; fire, blast or projection hazard.
H204=Fire or projection hazard.
H205=May mass explode in fire.
H220=Extremely flammable gas.
H221=Flammable gas.
H222=Extremely flammable aerosol.
H223=Flammable aerosol.
H224=Extremely flammable liquid and vapour.
H225=Highly flammable liquid and vapour.
H226=Flammable liquid and vapour.
H228=Flammable solid.
H229=Pressurised container: May burst if heated.
H230=May react explosively even in the absence of air.
H231=May react explosively even in the absence of air at elevated pressure and/or temperature.
H240=Heating may cause an explosion.
H241=Heating may cause a fire or explosion.
H242=Heating may cause a fire.
H250=Catches fire spontaneously if exposed to air.
H251=Self-heating: may catch fire.
H252=Self-heating in large quantities; may catch fire.
H260=In contact with water releases flammable gases which may ignite spontaneously.
H261=In contact with water releases flammable gases.
H270=May cause or intensify fire; oxidiser.
H271=May cause fire or explosion; strong oxidiser.
H272=May intensify fire; oxidiser.
H280=Contains gas under pressure; may explode if heated.
H281=Contains refrigerated gas; may cause cryogenic burns or injury.
H290=May be corrosive to metals.
H300=Fatal if swallowed.
H301=Toxic if swallowed.
H302=Harmful if swallowed.
H304=May be fatal if swallowed and enters airways.
H310=Fatal in contact with skin.
H311=Toxic in contact with skin.
H312=Harmful in contact with skin.
H314=Causes severe skin burns and eye damage.
H315=Causes skin irritation.
H317=May cause an allergic skin reaction.
H318=Causes serious eye damage.
H319=Causes serious eye irritation.
H330=Fatal if inhaled.
H331=Toxic if inhaled.
H332=Harmful if inhaled.
H334=May cause allergy or asthma symptoms or breathing difficulties if inhaled.
H335=May cause respiratory irritation.
H336=May cause drowsiness or dizziness.
H340=May cause genetic defects <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H341=Suspected of causing genetic defects <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H350=May cause cancer <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H350i=May cause cancer by inhalation.
H351=Suspected of causing cancer <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H360=May damage fertility or the unborn child <state specific effect if known > <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H360F=May damage fertility.
H360D=May damage the unborn child.
H360FD=May damage fertility. May damage the unborn child.
H360Fd=May damage fertility. Suspected of damaging the unborn child.
H360Df=May damage the unborn child. Suspected of damaging fertility.
H361=Suspected of damaging fertility or the unborn child <state specific effect if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H361f=Suspected of damaging fertility.
H361d=Suspected of damaging the unborn child.
H361fd=Suspected of damaging fertility. Suspected of damaging the unborn child.
H362=May cause harm to breast-fed children.
H370=Causes damage to organs <or state all organs affected, if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H371=May cause damage to organs <or state all organs affected, if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H372=Causes damage to organs <or state all organs affected, if known> through prolonged or repeated exposure <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H373=May cause damage to organs <or state all organs affected, if known> through prolonged or repeated exposure <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H400=Very toxic to aquatic life.
H401=Toxic to aquatic life
H410=Very toxic to aquatic life with long lasting effects.
H411=Toxic to aquatic life with long lasting effects.
H412=Harmful to aquatic life with long lasting effects.
H413=May cause long lasting harmful effects to aquatic life.
H300+310=Fatal if swallowed or in contact with skin.
H300+330=Fatal if swallowed or if inhaled.
H310+330=Fatal in contact with skin or if inhaled.
H300+310+330=Fatal if swallowed, in contact with skin or if inhaled.
H301+311=Toxic if swallowed or in contact with skin.
H301+331=Toxic if swallowed or if inhaled.
H311+331=Toxic in contact with skin or if inhaled.
H301+311+331=Toxic if swallowed, in contact with skin or if inhaled.
H302+312=Harmful if swallowed or in contact with skin.
H302+332=Harmful if swallowed or if inhaled.
H312+332=Harmful in contact with skin or if inhaled.
H302+312+332=Harmful if swallowed, in contact with skin or if inhaled.
[P-Phrases]
P101=If medical advice is needed, have product container or label at hand.
P102=Keep out of reach of children.
P103=Read label before use.
P201=Obtain special instructions before use.
P202=Do not handle until all safety precautions have been read and understood.
P210=Keep away from heat, hot surfaces, sparks, open flames and other ignition sources. No smoking.
P211=Do not spray on an open flame or other ignition source.
P220=Keep away from clothing and other combustible materials.
P222=Do not allow contact with air.
P223=Do not allow contact with water.
P230=Keep wetted with...
P231=Handle under inert gas/...
P232=Protect from moisture.
P233=Keep container tightly closed.
P234=Keep only in original packaging.
P235=Keep cool.
P240=Ground and bond container and receiving equipment.
P241=Use explosion-proof [electrical/ventilating/lighting/...] equipment.
P242=Use non-sparking tools.
P243=Take action to prevent static discharges.
P244=Keep valves and fittings free from oil and grease.
P250=Do not subject to grinding/shock/friction/... .
P251=Do not pierce or burn, even after use.
P260=Do not breathe dust/fume/gas/mist/vapours/spray.
P261=Avoid breathing dust/fume/gas/mist/vapours/spray.
P262=Do not get in eyes, on skin, or on clothing.
P263=Avoid contact during pregnancy and while nursing.
P264=Wash ... thoroughly after handling.
P270=Do no eat, drink or smoke when using this product.
P271=Use only outdoors or in a well-ventilated area.
P272=Contaminated work clothing should not be allowed out of the workplace.
P273=Avoid release to the environment.
P280=Wear protective gloves/protective clothing/eye protection/face protection.
P281=Use personal protective equipment as required
P282=Wear cold insulating gloves and either face shield or eye protection.
P283=Wear fire resistant or flame retardant clothing.
P284=[In case of inadequate ventilation] wear respiratory protection.
P285=In case of inadequate ventilation wear respiratory protection.
P231+P232=Handle and store contents under inert gas/.... Protect from moisture.
P235+P410=Keep cool. Protect from sunlight.
P301+P310=IF SWALLOED: Immediately call a POISON CENTER/doctor/...
P301=IF SWALLOWED:
P302=IF ON SKIN:
P303=IF ON SKIN (or hair):
P304=IF INHALED:
P305=IF IN EYES:
P306=IF ON CLOTHING:
P307=IF exposed:
P308=IF exposed or concerned:
P309=IF exposed or if you feel unwell:
P310=Immediately call a POISON CENTER/doctor/...
P311=Call a POISON CENTER/doctor/...
P312=Call a POISON CENTER/doctor/... if you feel unwell.
P313=Get medical advice/attention.
P314=Get medical advice/attention if you feel unwell.
P315=Get immediate medical advice/attention.
P320=Specific treatment is urgent (see ... on this label).
P321=Specific treatment (see ... on this label).
P322=Specific treatment (see ... on this label).
P330=Rinse mouth.
P331=Do NOT induce vomiting.
P332=If skin irritation occurs:
P333=If skin irritation or rash occurs:
P334=Immerse in cool water [or wrap in wet bandages].
P335=Brush off loose particles from skin.
P336=Thaw frosted parts with lukewarm water. Do no rub affected area.
P337=If eye irritation persists:
P338=Remove contact lenses, if present and easy to do. Continue rinsing.
P340=Remove person to fresh air and keep comfortable for breathing.
P342=If experiencing respiratory symptoms:
P350=Gently wash with pletny of soap and water.
P351=Rinse cautiously with water for several minutes.
P352=Wash with plenty of water/...
P353=Rinse skin with water [or shower].
P360=Rinse immediately contaminated clothing and skin with plenty of water before removing clothes.
P361=Take off immediately all contaminated clothing.
P362=Take off contaminated clothing.
P363=Wash contaminated clothing before reuse.
P364=And wash it before reuse.
P370=In case of fire:
P371=In case of major fire and large quantities:
P372=Explosion risk.
P373=DO NOT fight fire when fire reaches explosives.
P374=Fight fire with normal precautions from a reasonable distance.
P375=Fight fire remotely due to the risk of explosion.
P376=Stop leak if safe to do so.
P377=Leaking gas fire: Do not extinguish, unless leak can be stopped safely.
P378=Use ... to extinguish.
P380=Evacuate area.
P381=In case of leakage, eliminate all ignition sources.
P390=Absorb spillage to prevent material damage.
P391=Collect spillage.
P301+P310=IF SWALLOWED: Immediately call a POISON CENTER/doctor/...
P301+P312=IF SWALLOWED: Call a POISON CENTER/doctor/... if you feel unwell.
P301+P330+P331=IF SWALLOWED: rinse mouth. Do NOT induce vomiting.
P302+P334=IF ON SKIN: Immerse in cool water or wrap in wet bandages.
P302+P352=IF ON SKIN: Wash with plenty of water/...
P303+P361+P353=IF ON SKIN (or hair): Take off immediately all contaminated clothing. Rinse skin with water [or shower].
P304+P340=IF INHALED: Remove person to fresh air and keep comfortable for breathing.
P305+P351+P338=IF IN EYES: Rinse cautiously with water for several minutes. Remove contact lenses, if present and easy to do. Continue rinsing.
P306+P360=IF ON CLOTHING: rinse immediately contaminated clothing and skin with plenty of water before removing clothes.
P308+P313=IF exposed or concerned: Get medical advice/attention.
P332+P313=If skin irritation occurs: Get medical advice/attention.
P333+P313=If skin irritation or rash occurs: Get medical advice/attention.
P337+P313=If eye irritation persists: Get medical advice/attention.
P342+P311=If experiencing respiratory symptoms: Call a POISON CENTER/doctor/...
P370+P376=In case of fire: Stop leak if safe to do so.
P370+P378=In case of fire: Use... to extinguish.
P370+P380+P375=In case of fire: Evacuate area. Fight fire remotely due to the risk of explosion.
P371+P380+P375=In case of major fire and large quantities: Evacuate area. Fight fire remotely due to the risk of explosion.
P401=Store in accordance with... .
P402=Store in a dry place.
P403=Store in a well-ventilated place.
P404=Store in a closed container.
P405=Store locked up.
P406=Store in a corrosion resistant/... container with a resistant inner liner.
P407=Maintain air gap between stacks or pallets.
P410=Protect from sunlight.
P411=Store at temperatures not exceeding...°C/...°F.
P412=Do not expose to temperatures exceeding 50°C/ 122°F.
P413=Store bulk masses greater than ... kg/... lbs at temperatures not exceeding ...°C/...°F.
P420=Store separately.
P422=Store contents under...
P402+P404=Store in a dry place. Store in a closed container.
P403+P233=Store in a well-ventilated place. Keep container tightly closed.
P403+P235=Store in a well-ventilated place. Keep cool.
P410+P403=Protect from sunlight. Store in a well-ventilated place.
P410+P412=Protect from sunlight. Do no expose to temperatures exceeding 50°C/ 122°F.
P501=Dispose of contents/container to...
P502=Refer to manufacturer/supplier for information on recovery/recycling.
[Physical properties]
EUH001=Explosive when dry.
EUH014=Reacts violently with water.
EUH018=In use may form flammable/explosive vapour-air mixture.
EUH019=May form explosive peroxides.
EUH044=Risk of explosion if heated under confinement.
EUH029=Contact with water liberates toxic gas.
EUH031=Contact with acids liberates toxic gas.
EUH032=Contact with acids liberates very toxic gas.
EUH066=Repeated exposure may cause skin dryness or cracking.
EUH070=Toxic by eye contact
EUH071=Corrosive to the respiratory tract.
[Environmental properties]
EUH059=Hazardous to the ozone layer.
[Supplemental label elements/information on certain substances and mixtures]
EUH201=Contains lead. Should not be used on surfaces liable to be chewed or sucked by children. 
EUH201A=Warning! Contains lead.
EUH202=Cyanoacrylate. Danger. Bonds skin and eyes in seconds. Keep out of the reach of children.
EUH203=Contains chromium (VI). May produce an allergic reaction.
EUH204=Contains isocyanates. May produce an allergic reaction.
EUH205=Contains epoxy constituents. May produce an allergic reaction.
EUH206=Warning! Do not use together with other products. May release dangerous gases (chlorine).
EUH207=Warning! Contains cadmium. Dangerous fumes are formed during use. See information supplied by the manufacturer. Comply with the safety instructions.
EUH208=Contains (name of sensitising substance). May produce an allergic reaction.
EUH209=Can become highly flammable in use.
EUH209A=Can become highly flammable in use.
EUH210=Safety data sheet available on request.
EUH401=To avoid risks to human health and the environment, comply with the instructions for use.
)
}
; m("figure out how to write a continuation section to file successfully")
f_ThrowError("Main Code Body","Library-file containing the H&P-phrases does not exist, initiating from default settings. ", script.name . "_"0, Exception("",-1).Line)
if !InStr(FileExist(script.configfolder),"D") ; check if folder structure exists
	FileCreateDir, % script.configfolder 
	;FileCreateDir, % A_ScriptDir "\INI-Files"
    ; 'd:=script.configfolder:= script.configfolder . "HI\"
; sPathLibraryFile
if fIsConnected()   ; load from gist.
{
	UrlDownloadToFile, % script.libraryurl ,% script.configfile
	FileReadLine, bDownloadStatus,% script.configfile, % 1
	if (bDownloadStatus="404: Not Found")
	{
		FileDelete, % script.configfile ; URL faulty and cannot retrieve correct text. Fallback on hard-coded version
		FileAppend, % LibraryBackup, % script.configfile
	}    
}
else                ; load from hard coded var
	FileAppend, % LibraryBackup, % script.configfile
DataArr:=fReadIni(script.configfile) ; load the data to use.
gosub, lExplainHowTo
return

lExplainHowTo:
run,% script.doclink
return

fReadINI(INI_File,bIsVar=0) ; return 2D-array from INI-file
{
	Result := []
	if !bIsVar ; load a simple file
	{
		SplitPath, INI_File,, WorkDir
		OrigWorkDir:=A_WorkingDir
		SetWorkingDir, % WorkDir
		IniRead, SectionNames, %INI_File%
		for each, Section in StrSplit(SectionNames, "`n") {
			IniRead, OutputVar_Section, %INI_File%, %Section%
			for each, Haystack in StrSplit(OutputVar_Section, "`n")
				RegExMatch(Haystack, "(.*?)=(.*)", $)
				, Result[Section, $1] := $2
		}
		if A_WorkingDir!=OrigWorkDir
			SetWorkingDir, %OrigWorkDir%
	}
	else ; convert string
	{
		Lines:=StrSplit(bIsVar,"`n")
		bIsInSection:=false
		for k,v in lines
		{
			If SubStr(v,1,1)="[" && SubStr(v,StrLen(v),1)="]"
			{
                    SectionHeader:=SubStr(v,2)
                    SectionHeader:=SubStr(SectionHeader,1,StrLen(SectionHeader)-1)
                    bIsInSection:=true
                    currentSection:=SectionHeader
			}
			if bIsInSection
			{
                    RegExMatch(v, "(.*?)=(.*)", $)
                    if ($2!="")
					Result[currentSection,$1] := $2
			}
		}
	}
	return Result
}

fIsConnected(URL="https://google.com") 
{ ; retrieved from lxiko's "AHKRare" https://github.com/Ixiko/AHK-Rare          ;-- Returns true if there is an available internet connection
	return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
} 
fClip(Text="", Reselect="",Restore:=1,DefaultMethod:=1)
{
	/*
		Parameters
		Text: variable whose contents to paste. 
		Reselect: set true if you want to reselect pasted text for further processing
		Restore: restore clipboard after using it. 
		DefaultMethod: keep true to use the original method. Recommended for anyone but Gewerd S./me, as I needed some extremely minute modifications in some places and expanded the whole function to be more readable for me. 
	*/
	if !DefaultMethod
	{
		BlockInput,On
		if InStr(Text,"&|") ;; check if needle contains cursor-pos. The needle must be &|, without brackets
		{
			move := StrLen(Text) - RegExMatch(Text, "[&|]")
			Text := RegExReplace(Text, "[&|]")
			sleep, 20
			MoveCursor:=true
		}
		Else
		{
			MoveCursor:=false
			move:=1 			;; offset the left-moves for the edgecase that this is not guarded by movecursor
		}
		Static BackUpClip, Stored, LastClip
		If (A_ThisLabel = A_ThisFunc)
		{
			If (Clipboard == LastClip)
				Clipboard := BackUpClip
			BackUpClip := LastClip := Stored := ""
		} 
		Else 
		{
			If !Stored 
			{
				Stored := True
				BackUpClip := ClipboardAll ; ClipboardAll must be on its own line
			} 
			Else
				SetTimer, %A_ThisFunc%, Off
			LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
			If (Text = "") ; No text is pasted, hence we pull it. 
			{
				SendInput, ^c 
				ClipWait, LongCopy ? 0.6 : 0.2, True
			} 
			Else 
			{
				Clipboard := LastClip := Text
				ClipWait, 10
				SendInput, ^v
				if MoveCursor
				{
					if WinActive("E-Mail – ") and Winactive("— Mozilla Firefox")
					{
						WinActivate
						sleep, 20
						BlockInput,On
						WinActivate, "E-Mail – "
						if !ReSelect and (ReSelect = False)
							SendInput, % "{Left " move-1 "}"
						else if (Reselect="")
							SendInput, % "{Left " move-1 "}"
					}	
					else
						if !ReSelect and (ReSelect = False)
							SendInput, % "{Left " move-2 "}"
					else if (Reselect="")
					{
						SendInput, % "{Left " move-2 "}"
					}
				}
			}
			SetTimer, %A_ThisFunc%, -700
			Sleep 200 ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
			If (Text = "") ; we are pulling, not pasting
			{
				SetTimer, %A_ThisFunc%, Off
				{
					f_unstickKeys()
					if !Restore
					{
						BlockInput, Off
						return LastClip := Clipboard
					}
					LastClip := Clipboard
					ClipWait, LongCopy ? 0.6 : 0.2, True
					BlockInput,Off
					Return LastClip
				}
			}
			Else If ReSelect and ((ReSelect = True) or (StrLen(Text) < 3000))
			{
				SetTimer, %A_ThisFunc%, Off
				SendInput, % "{Shift Down}{Left " StrLen(StrReplace(Text, "`r")) "}{Shift Up}"
			}
		}
		f_unstickKeys()  
		BlockInput, Off
		Return
		
	}
	else
	{
		if InStr(Text,"&|") ;; check if needle contains cursor-pos. The needle must be &|, without brackets
		{
			move := StrLen(Text) - RegExMatch(Text, "[&|]")
			Text := RegExReplace(Text, "[&|]")
			sleep, 20
			MoveCursor:=true
		}
		Else
		{
			MoveCursor:=false
			move:=1 			;; offset the left-moves for the edgecase that this is not guarded by movecursor
		}
		If (A_ThisLabel = A_ThisFunc) {
			If (Clipboard == LastClip)
				Clipboard := BackUpClip
			BackUpClip := LastClip := Stored := ""
		} Else {
			If !Stored {
				Stored := True
				BackUpClip := ClipboardAll ; ClipboardAll must be on its own line
			} Else
				SetTimer, %A_ThisFunc%, Off
			LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
			If (Text = "") {
				SendInput, ^c
				ClipWait, LongCopy ? 0.6 : 0.2, True
			} Else {
				Clipboard := LastClip := Text
				ClipWait, 10
				SendInput, ^v
			}
			SetTimer, %A_ThisFunc%, -700
			Sleep 20 ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
			If (Text = "")
				Return LastClip := Clipboard
			Else If ReSelect and ((ReSelect = True) or (StrLen(Text) < 3000))
				SendInput, % "{Shift Down}{Left " StrLen(StrReplace(Text, "`r")) "}{Shift Up}"
			if Move and !ReSelect{
				SendInput, % "{Left " move-2 "}"
			}
		}
		Return
		
	}
	fClip:
	f_unstickKeys()
	BlockInput,Off
	Return fClip()
}
f_unstickKeys()
{
	BlockInput, On
	SendInput, {Ctrl Up}
	SendInput, {V Up}
	SendInput, {Shift Up}
	SendInput, {Alt Up}
	BlockInput, Off
}
