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
;ntfy:=Notify()
;;_____________________________________________________________________________________
;{#[General Information for file management]

; #Include <scriptObj>
; last edited by Gewerd Strauss @ 27.11.2021
; from RaptorX https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
/**
 * ============================================================================ *
 * @Author           : RaptorX <graptorx@gmail.com>
 * @Script Name      : Script Object
 * @Script Version   : 0.20.3
 * @Homepage         :
 *
 * @Creation Date    : November 09, 2020
 * @Modification Date: July 02, 2021
 * @Modification G.S.: November 27, 2021
 ; @Description Modification G.S.: added field for GitHub-link, a Forum-link 
 								   and a credits-field, as well as a template 
								   to quickly copy out into new scripts
 * 
 * @Description      :
 * -------------------
 * This is an object used to have a few common functions between scripts
 * Those are functions and variables related to basic script information,
 * upgrade and configuration.
 *
 * ============================================================================ *
 */
; scriptName   (opt) - Name of the script which will be
; 		                     shown as the title of the window and the main header
; 		version      (opt) - Script Version in SimVer format, a "v"
; 		                     will be added automatically to this value
; 		author       (opt) - Name of the author of the script
; 		credits 	 (opt) - Name of credited people
; 		creditslink  (opt) - Link to credited file, if any
; 		crtdate		 (opt) - Date of creation
; 		moddate		 (opt) - Date of modification
; 		homepagetext (opt) - Display text for the script website
; 		homepagelink (opt) - Href link to that points to the scripts
; 		                     website (for pretty links and utm campaing codes)
; 		ghlink 		 (opt) - GitHubLink
; 		ghtext 		 (opt) - GitHubtext
; 		forumlink    (opt) - forumlink to the scripts forum page
; 		forumtext    (opt) - forumtext 
; 		donateLink   (opt) - Link to a donation site
; 		email        (opt) - Developer email

; Template
; global script := {base         : script
;                  ,name         : regexreplace(A_ScriptName, "\.\w+")
;                  ,version      : "0.1.0"
;                  ,author       : ""
;                  ,email        : ""
;                  ,credits      : ""
;                  ,creditslink  : ""
;                  ,crtdate      : ""
;                  ,moddate      : ""
;                  ,homepagetext : ""
;                  ,homepagelink : ""
;                  ,ghlink       : ""
;                  ,ghtext 		 : ""
;                  ,doclink      : ""
;                  ,doctext		 : ""
;                  ,forumlink    : ""
;                  ,forumtext	 : ""
;                  ,donateLink   : ""
;                  ,resfolder    : A_ScriptDir "\res"
;                  ,iconfile     : A_ScriptDir "\res\sct.ico"
;                  ,configfile   : A_ScriptDir "\settings.ini"
;                  ,configfolder : A_ScriptDir ""
; 				   }

class script
{
	static DBG_NONE     := 0
	      ,DBG_ERRORS   := 1
	      ,DBG_WARNINGS := 2
	      ,DBG_VERBOSE  := 3

	static name         := ""
	      ,version      := ""
	      ,author       := ""
	      ,email        := ""
		  ,credits      := ""
		  ,creditslink  := ""
	      ,crtdate      := ""
	      ,moddate      := ""
	      ,homepagetext := ""
	      ,homepagelink := ""
		  ,ghlink		:= ""
		  ,ghtext 		:= ""
          ,doclink      := ""
          ,doctext		:= ""
		  ,forumlink 	:= ""
		  ,forumtext 	:= ""
	      ,resfolder    := ""
	      ,icon         := ""
	      ,config       := ""
	      ,systemID     := ""
	      ,dbgFile      := ""
	      ,dbgLevel     := this.DBG_NONE


	/**
		Function: Update
		Checks for the current script version
		Downloads the remote version information
		Compares and automatically downloads the new script file and reloads the script.

		Parameters:
		vfile - Version File
		        Remote version file to be validated against.
		rfile - Remote File
		        Script file to be downloaded and installed if a new version is found.
		        Should be a zip file that will be unzipped by the function

		Notes:
		The versioning file should only contain a version string and nothing else.
		The matching will be performed against a SemVer format and only the three
		major components will be taken into account.

		e.g. '1.0.0'

		For more information about SemVer and its specs click here: <https://semver.org/>
	*/
	Update(vfile, rfile)
	{
		; Error Codes
		static ERR_INVALIDVFILE := 1
		,ERR_INVALIDRFILE       := 2
		,ERR_NOCONNECT          := 3
		,ERR_NORESPONSE         := 4
		,ERR_INVALIDVER         := 5
		,ERR_CURRENTVER         := 6
		,ERR_MSGTIMEOUT         := 7
		,ERR_USRCANCEL          := 8

		; A URL is expected in this parameter, we just perform a basic check
		; TODO make a more robust match
		if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
			throw {code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."}

		; This function expects a ZIP file
		if (!regexmatch(rfile, "\.zip"))
			throw {code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."}

		; Check if we are connected to the internet
		http := comobjcreate("WinHttp.WinHttpRequest.5.1")
		http.Open("GET", "https://www.google.com", true)
		http.Send()
		try
			http.WaitForResponse(1)
		catch e
			throw {code: ERR_NOCONNECT, msg: e.message}

		Progress, 50, 50/100, % "Checking for updates", % "Updating"

		; Download remote version file
		http.Open("GET", vfile, true)
		http.Send(), http.WaitForResponse()

		if !(http.responseText)
		{
			Progress, OFF
			throw {code: ERR_NORESPONSE, msg: "There was an error trying to download the ZIP file.`n"
											. "The server did not respond."}
		}
		m(http.responseText)
		regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)
		regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)

		Progress, 100, 100/100, % "Checking for updates", % "Updating"
		sleep 500 	; allow progress to update
		Progress, OFF

		; Make sure SemVer is used
		if (!loVersion || !remVersion)
			throw {code: ERR_INVALIDVER, msg: "Invalid version.`nThis function works with SemVer. "
											. "For more information refer to the documentation in the function"}

		; Compare against current stated version
		ver1 := strsplit(loVersion, ".")
		ver2 := strsplit(remVersion, ".")

		for i1,num1 in ver1
		{
			for i2,num2 in ver2
			{
				if (newversion)
					break

				if (i1 == i2)
					if (num2 > num1)
					{
						newversion := true
						break
					}
					else
						newversion := false
			}
		}

		if (!newversion)
			throw {code: ERR_CURRENTVER, msg: "You are using the latest version"}
		else
		{
			; If new version ask user what to do
			; Yes/No | Icon Question | System Modal
			msgbox % 0x4 + 0x20 + 0x1000
				 , % "New Update Available"
				 , % "There is a new update available for this application.`n"
				   . "Do you wish to upgrade to v" remVersion "?"
				 , 10	; timeout

			ifmsgbox timeout
				throw {code: ERR_MSGTIMEOUT, msg: "The Message Box timed out."}
			ifmsgbox no
				throw {code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}

			; Create temporal dirs
			ghubname := (InStr(rfile, "github") ? regexreplace(a_scriptname, "\..*$") "-latest\" : "")
			filecreatedir % tmpDir := a_temp "\" regexreplace(a_scriptname, "\..*$")
			filecreatedir % zipDir := tmpDir "\uzip"

			; Create lock file
			fileappend % a_now, % lockFile := tmpDir "\lock"

			; Download zip file
			urldownloadtofile % rfile, % tmpDir "\temp.zip"

			; Extract zip file to temporal folder
			oShell := ComObjCreate("Shell.Application")
			oDir := oShell.NameSpace(zipDir), oZip := oShell.NameSpace(tmpDir "\temp.zip")
			oDir.CopyHere(oZip.Items), oShell := oDir := oZip := ""

			filedelete % tmpDir "\temp.zip"

			/*
			******************************************************
			* Wait for lock file to be released
			* Copy all files to current script directory
			* Cleanup temporal files
			* Run main script
			* EOF
			*******************************************************
			*/
			if (a_iscompiled){
				tmpBatch =
				(Ltrim
					:lock
					if not exist "%lockFile%" goto continue
					timeout /t 10
					goto lock
					:continue

					xcopy "%zipDir%\%ghubname%*.*" "%a_scriptdir%\" /E /C /I /Q /R /K /Y
					if exist "%a_scriptfullpath%" cmd /C "%a_scriptfullpath%"

					cmd /C "rmdir "%tmpDir%" /S /Q"
					exit
				)
				fileappend % tmpBatch, % tmpDir "\update.bat"
				run % a_comspec " /c """ tmpDir "\update.bat""",, hide
			}
			else
			{
				tmpScript =
				(Ltrim
					while (fileExist("%lockFile%"))
						sleep 10

					FileCopyDir %zipDir%\%ghubname%, %a_scriptdir%, true
					FileRemoveDir %tmpDir%, true

					if (fileExist("%a_scriptfullpath%"))
						run %a_scriptfullpath%
					else
						msgbox `% 0x10 + 0x1000
							 , `% "Update Error"
							 , `% "There was an error while running the updated version.``n"
								. "Try to run the program manually."
							 ,  10
						exitapp
				)
				fileappend % tmpScript, % tmpDir "\update.ahk"
				run % a_ahkpath " " tmpDir "\update.ahk"
			}
			filedelete % lockFile
			exitapp
		}
	}

	/**
		Function: Autostart
		This Adds the current script to the autorun section for the current
		user.

		Parameters:
		status - Autostart status
		         It can be either true or false.
		         Setting it to true would add the registry value.
		         Setting it to false would delete an existing registry value.
	*/
	Autostart(status)
	{
		if (status)
		{
			RegWrite, REG_SZ
			        , HKCU\SOFTWARE\microsoft\windows\currentversion\run
			        , %a_scriptname%
			        , %a_scriptfullpath%
		}
		else
			regdelete, HKCU\SOFTWARE\microsoft\windows\currentversion\run
			         , %a_scriptname%
	}

	/**
		Function: Splash
		Shows a custom image as a splash screen with a simple fading animation

		Parameters:
		img   (opt) - file to be displayed
		speed (opt) - fast the fading animation will be. Higher value is faster.
		pause (opt) - long in seconds the image will be paused after fully displayed.
	*/
	Splash(img:="", speed:=10, pause:=2)
	{
		global

			gui, splash: -caption +lastfound +border +alwaysontop +owner
		$hwnd := winexist(), alpha := 0
		winset, transparent, 0

		gui, splash: add, picture, x0 y0 vpicimage, % img
		guicontrolget, picimage, splash:pos
		gui, splash: show, w%picimagew% h%picimageh%

		setbatchlines 3
		loop, 255
		{
			if (alpha >= 255)
				break
			alpha += speed
			winset, transparent, %alpha%
		}

		; pause duration in seconds
		sleep pause * 1000

		loop, 255
		{
			if (alpha <= 0)
				break
			alpha -= speed
			winset, transparent, %alpha%
		}
		setbatchlines -1

		gui, splash:destroy
		return
	}

	/**
		Funtion: Debug
		Allows sending conditional debug messages to the debugger and a log file filtered
		by the current debug level set on the object.

		Parameters:
		level - Debug Level, which can be:
		        * this.DBG_NONE
		        * this.DBG_ERRORS
		        * this.DBG_WARNINGS
		        * this.DBG_VERBOSE

		If you set the level for a particular message to *this.DBG_VERBOSE* this message
		wont be shown when the class debug level is set to lower than that (e.g. *this.DBG_WARNINGS*).

		label - Message label, mainly used to show the name of the function or label that triggered the message
		msg   - Arbitrary message that will be displayed on the debugger or logged to the log file
		vars* - Aditional parameters that whill be shown as passed. Useful to show variable contents to the debugger.

		Notes:
		The point of this function is to have all your debug messages added to your script and filter them out
		by just setting the object's dbgLevel variable once, which in turn would disable some types of messages.
	*/
	Debug(level:=1, label:=">", msg:="", vars*)
	{
		if !this.dbglevel
			return

		for i,var in vars
			varline .= "|" var

		dbgMessage := label ">" msg "`n" varline

		if (level <= this.dbglevel)
			outputdebug % dbgMessage
		if (this.dbgFile)
			FileAppend, % dbgMessage, % this.dbgFile
	}

	/**
		Function: About
		Shows a quick HTML Window based on the object's variable information

		Parameters:
		scriptName   (opt) - Name of the script which will be
		                     shown as the title of the window and the main header
		version      (opt) - Script Version in SimVer format, a "v"
		                     will be added automatically to this value
		author       (opt) - Name of the author of the script
		credits 	 (opt) - Name of credited people
		ghlink 		 (opt) - GitHubLink
		ghtext 		 (opt) - GitHubtext
		doclink 	 (opt) - DocumentationLink
		doctext 	 (opt) - Documentationtext
		forumlink    (opt) - forumlink
		forumtext    (opt) - forumtext
		homepagetext (opt) - Display text for the script website
		homepagelink (opt) - Href link to that points to the scripts
		                     website (for pretty links and utm campaing codes)
		donateLink   (opt) - Link to a donation site
		email        (opt) - Developer email

		Notes:
		The function will try to infer the paramters if they are blank by checking
		the class variables if provided. This allows you to set all information once
		when instatiating the class, and the about GUI will be filled out automatically.
	*/
	About(scriptName:="", version:="", author:="",credits:="", homepagetext:="", homepagelink:="", donateLink:="", email:="")
	{
		static doc

		scriptName := scriptName ? scriptName : this.name
		version := version ? version : this.version
		author := author ? author : this.author
		credits := credits ? credits : this.credits
		creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
		ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
		ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
		doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
		doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
		forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
		forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
		homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
		homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
		donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
		email := email ? email : this.email

 		if (donateLink)
		{
			donateSection =
			(
				<div class="donate">
					<p>If you like this tool please consider <a href="https://%donateLink%">donating</a>.</p>
				</div>
				<hr>
			)
		}

		html =
		(
			<!DOCTYPE html>
			<html lang="en" dir="ltr">
				<head>
					<meta charset="utf-8">
					<meta http-equiv="X-UA-Compatible" content="IE=edge">
					<style media="screen">
						.top {
							text-align:center;
						}
						.top h2 {
							color:#2274A5;
							margin-bottom: 5px;
						}
						.donate {
							color:#E83F6F;
							text-align:center;
							font-weight:bold;
							font-size:small;
							margin: 20px;
						}
						p {
							margin: 0px;
						}
					</style>
				</head>
				<body>
					<div class="top">
						<h2>%scriptName%</h2>
						<p>v%version%</p>
						<hr>
						<p>by %author%</p>
		)
		if ghlink and ghtext
		{
			sTmp=
			(

						<p><a href="https://%ghlink%" target="_blank">%ghtext%</a></p>
			)
			html.=sTmp
		}
		if doclink and doctext
		{
			sTmp=
			(

						<p><a href="https://%doclink%" target="_blank">%doctext%</a></p>
			)
			html.=sTmp
		}
		if creditslink and credits
		{
			; Clipboard:=html
			sTmp=
			(

						<p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
						<hr>
			)
			html.=sTmp
		}
		if forumlink and forumtext
		{
			sTmp=
			(

						<p><a href="https://%forumlink%" target="_blank">%forumtext%</a></p>
			)
			html.=sTmp
		}
		if homepagelink and homepagetext
		{
			sTmp=
			(

						<p><a href="https://%homepagelink%" target="_blank">%homepagetext%</a></p>

			)
			html.=sTmp
		}
		sTmp=
		(

								</div>
					%donateSection%
				</body>
			</html>
		)
		html.=sTmp
		; Clipboard:=html
		; html.= "`n
		; (
		; 	HEllo World
		; )"
		; Clipboard:=html
 		btnxPos := 300/2 - 75/2
		axHight:=12
		donateHeight := donateLink ? 6 : 0
		forumHeight := forumlink ? 1 : 0
		ghHeight := ghlink ? 1 : 0
		creditsHeight := creditslink ? 1 : 0
		homepageHeight := homepagelink ? 1 : 0
		docHeight := doclink ? 1 : 0
		axHight+=donateHeight
		axHight+=forumHeight
		axHight+=ghHeight
		axHight+=creditsHeight
		axHight+=homepageHeight
		axHight+=docHeight
		gui aboutScript:new, +alwaysontop +toolwindow, % "About " this.name
		gui margin, 2
		gui color, white
		gui add, activex, w300 r%axHight% vdoc, htmlFile
		gui add, button, w75 x%btnxPos% gaboutClose, % "&Close"
		doc.write(html)
		gui show, AutoSize
		return

		aboutClose:
			gui aboutScript:destroy
		return
	}

	/*
		Function: GetLicense
		Parameters:
		Notes:
	*/
	GetLicense()
	{
		global

		this.systemID := this.GetSystemID()
		cleanName := RegexReplace(A_ScriptName, "\..*$")
		for i,value in ["Type", "License"]
			RegRead, %value%, % "HKCU\SOFTWARE\" cleanName, % value

		if (!License)
		{
			MsgBox, % 0x4 + 0x20
			      , % "No license"
			      , % "Seems like there is no license activated on this computer.`n"
			        . "Do you have a license that you want to activate now?"

			IfMsgBox, Yes
			{
				Gui, license:new
				Gui, add, Text, w160, % "Paste the License Code here"
				Gui, add, Edit, w160 vLicenseNumber
				Gui, add, Button, w75 vTest, % "Save"
				Gui, add, Button, w75 x+10, % "Cancel"
				Gui, show

				saveFunction := Func("licenseButtonSave").bind(this)
				GuiControl, +g, test, % saveFunction
				Exit
			}

			MsgBox, % 0x30
			      , % "Unable to Run"
			      , % "This program cannot run without a license."

			ExitApp, 1
		}

		return {"type"    : Type
		       ,"number"  : License}
	}

	/*
		Function: SaveLicense
		Parameters:
		Notes:
	*/
	SaveLicense(licenseType, licenseNumber)
	{
		cleanName := RegexReplace(A_ScriptName, "\..*$")

		Try
		{
			RegWrite, % "REG_SZ"
			        , % "HKCU\SOFTWARE\" cleanName
			        , % "Type", % licenseType

			RegWrite, % "REG_SZ"
			        , % "HKCU\SOFTWARE\" cleanName
			        , % "License", % licenseNumber

			return true
		}
		catch
			return false
	}

	/*
		Function: IsLicenceValid
		Parameters:
		Notes:
	*/
	IsLicenceValid(licenseType, licenseNumber, URL)
	{
		res := this.EDDRequest(URL, "check_license", licenseType ,licenseNumber)

		if InStr(res, """license"":""inactive""")
			res := this.EDDRequest(URL, "activate_license", licenseType ,licenseNumber)

		if InStr(res, """license"":""valid""")
			return true
		else
			return false
	}

	GetSystemID()
	{
		wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\cimv2")
		(wmi.ExecQuery("Select * from Win32_BaseBoard")._newEnum)[Computer]
		return Computer.SerialNumber
	}

	/*
		Function: EDDRequest
		Parameters:
		Notes:
	*/
	EDDRequest(URL, Action, licenseType, licenseNumber)
	{
		strQuery := url "?edd_action=" Action
		         .  "&item_id=" licenseType
		         .  "&license=" licenseNumber
		         .  (this.systemID ? "&url=" this.systemID : "")

		try
		{
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			http.Open("GET", strQuery)
			http.SetRequestHeader("Pragma", "no-cache")
			http.SetRequestHeader("Cache-Control", "no-cache, no-store")
			http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; Win32)")

			http.Send()
			http.WaitForResponse()

			return http.responseText
		}
		catch err
			return err.what ":`n" err.message
	}

	; Activate()
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=activate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	return JSON.parse(strJSON)
	; 	}
	; Deactivate()
	; 	{
	; 	Loop, Parse, % "/|", |
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=deactivate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId . A_LoopField
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	this.oLicense := JSON.parse(strJSON)
	; 	if (this.oLicense.success)
	; 	break
	; 	}
	; 	}
	; GetVersion()
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=get_version&item_id=" . this.oLicense.item_id . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	return JSON.parse(strJSON)
	; 	}
	; RenewLink()
	; 	{
	; 	strUrl := this.strEddRootUrl . "checkout/?edd_license_key=" . this.strEddLicense . "&download_id=" . this.oLicense.item_id
	; 	Diag(A_ThisFunc . " strUrl", strUrl, "")
	; 	return strUrl
	; 	}
}

licenseButtonSave(this, CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	GuiControlGet, LicenseNumber
	if this.IsLicenceValid(this.eddID, licenseNumber, "https://www.the-automator.com")
	{
		this.SaveLicense(this.eddID, LicenseNumber)
		MsgBox, % 0x30
		      , % "License Saved"
		      , % "The license was applied correctly!`n"
		        . "The program will start now."
		
		Reload
	}
	else
	{
		MsgBox, % 0x10
		      , % "Invalid License"
		      , % "The license you entered is invalid and cannot be activated."

		ExitApp, 1
	}
}

licenseButtonCancel(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	MsgBox, % 0x30
	      , % "Unable to Run"
	      , % "This program cannot run without a license."

	ExitApp, 1
}

FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
global script := {   base         : script
                    ,name         : regexreplace(A_ScriptName, "\.\w+")
                    ,version      : "1.0.1"
                    ,author       : "Gewerd Strauss"
					,authorlink   : "https://github.com/Gewerd-Strauss"
                    ,email        : ""
                    ,credits      : ""
					,creditslink  : ""
                    ,crtdate      : "02.12.2021"
                    ,moddate      : ""
                    ,homepagetext : ""
                    ,homepagelink : ""
                    ,ghtext 	  : ""
                    ,ghlink       : ""
                    ,doctext	  : ""
                    ,doclink	  : ""
                    ,forumtext	  : ""
                    ,forumlink	  : ""
                    ,donateLink   : ""
                    ,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
                    ,configfolder : A_ScriptDir "\INI-Files"}
                    ; ,resfolder    : A_ScriptDir "\res"
                    ; ,iconfile     : A_ScriptDir "\res\sct.ico"
SplitPath, A_ScriptName,,,, A_ScriptNameNoExt
ScriptName=InesrtHandP.ahk 
VN=1.0.1.1                                                                    
LE=16.11.2021 21:36:47                                                       
AU=Gewerd Strauss
;}______________________________________________________________________________________
;{#[File Overview]
Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,234 ;Set custom Script icon
 ;Set custom Script icon
;menu, Tray, Add, About, Label_AboutFile
;}______________________________________________________________________________________
;{#[Autorun Section]
f_CreateTrayMenu(VN)
if bDownloadToFile
{
    if FileExist(script.configfile) ; check if library exists. Additionally, 
        DataArr:=fReadIni(script.configfile) ; load the data of the
    Else
        gosub, lWriteLibraryFromHardCode
}

if FileExist(sPathLibraryFile:=A_ScriptDir "\INI-Files\" A_ScriptNameNoExt ".ini")
    DataArr:=fReadIni(script.configfile) ; load the data of the
Else
    gosub, lWriteLibraryFromHardCode
; if (2<1)
; {   ;; Old experiment to fetch the h and p phrases from URL, but I decided against it in order to 
; 	UrlDownloadToFile, https://ec.europa.eu/taxation_customs/dds2/SAMANCTA/EN/Safety/HP_EN.htm,Test.ini ; read the european comission state of the H&P phrases. Need to figure out how the _FUCK_ I can parse this shitshow.
; 	LineNums:=0
; 	str:=A_ScriptDir "\Test.ini"
; 	loop, read,%str%
; 		LineNums++
; }

;OfficialPhrasesEU:=FileOpen(A_ScriptDir\Test.ini)
OnMessage(0x404, "f_TrayIconSingleClickCallBack")
return


;}______________________________________________________________________________________
;{#[Hotkeys Section]
!0::
Sel:=strsplit(fClip(),"`n")

global vNumErr:=1
str:=""
global ErrorString:=""
for k, v in Sel
{
    ErrorArr:=[]
    str.="`n"
    v:=StrReplace(v ,"`r","")
	v:=StrReplace(v,":","") ; remove ":" from string if existing
	v=%v%
    {
        stype:=substr(v,1,1)
        if DataArr["P-Phrases"].HasKey(v) && !Instr(v,"+") ;(stype="P")
        {
            bHasVal1:=true
            str.=v ": " DataArr["P-Phrases"][v] 
        }
        Else
            bHasVal1:=false
        if DataArr["H-Phrases"].HasKey(v) && !Instr(v,"+") ;(stype="H")
        {
            bHasVal2:=true
            str.=v ": " DataArr["H-Phrases"][v] 
        }
        Else
            bHasVal2:=false
        if DataArr["Physical properties"].HasKey(v) && !Instr(v,"+") 
        {
            bHasVal3:=true
            str.=v ": " DataArr["Physical properties"][v] 
        }
        Else
            bHasVal3:=false
        if DataArr["Environmental properties"].HasKey(v) && !Instr(v,"+") 
        {
            bHasVal4:=true
            str.=v ": " DataArr["Environmental properties"][v]
        }
        else
            bHasVal4:=false
        if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(v) && !Instr(v,"+") 
        {
            bHasVal5:=true
            str.=v ": " DataArr["Supplemental label elements/information on certain substances and mixtures"][v]
        }
        else
            bHasVal5:=false
        if (!bHasVal1) and (!bHasVal2) and (!bHasVal3) and (!bHasVal4) and (!bHasVal5) ;|| Instr(v,"")
            if (v!="") and !Instr(v,"#")
			{
                ErrorArr[v]:= "Error " vNumErr ": Key '" v "' could not be found on file. Please search and insert manually."
			}
    }
      
    str:=StrReplace(f_ProcessErrors(ErrorArr,DataArr,str)," : ",A_Space)
}
Clipboard:=str
; m(ErrorString)
newStr:=str "`n`n`nERROR LOG (REMOVE AFTERWARDS)`n-----------------" ErrorString "`n-----------------"
fClip(newStr)
return


;}______________________________________________________________________________________
;{#[Label Section]


return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
MsgBox,, File Overview, Name: %ScriptName%`nAuthor: %AU%`nVersionNumber: %VN%`nLast Edit: %LE%`n`nScript Location: %A_ScriptDir%
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
		{
			
			return str strCompoundAssembled.=": " DataArr["P-Phrases"][k]
		}
		else if DataArr["H-Phrases"].HasKey(k) 
		{
			return str strCompoundAssembled.=": " DataArr["H-Phrases"][k]
		}
		else if DataArr["Physical properties"].HasKey(k) 
		{
			return str strCompoundAssembled.=": " DataArr["Physical properties"][k]
		}
		else if DataArr["Environmental properties"].HasKey(k) 
		{
			return str strCompoundAssembled.=": " DataArr["Environmental properties"][k]
		}
		else if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(k) 
		{
			return str strCompoundAssembled.=": " DataArr["Supplemental label elements/information on certain substances and mixtures"][k]
			
		}




		; 2nd-level compound creation
        strCompoundAssembled:=k 
        CompoundStatementArr:=strsplit(k,"+")
		bWasFoundArr:=[]
		ErrorsFound:=[]
        for s,w in CompoundStatementArr
        {

            if DataArr["P-Phrases"].HasKey(w) ;(stype="P")
            {
                bHasVal1:=true
                strCompoundAssembled.=": " DataArr["P-Phrases"][w] 
                ; CompoundStatementArr.Remove(s)
            }
            Else
                bHasVal1:=false
            if DataArr["H-Phrases"].HasKey(w) ;(stype="H")
            {
                bHasVal2:=true
                strCompoundAssembled.=": " DataArr["H-Phrases"][w] 
                ; CompoundStatementArr.Remove(s)
            }
            Else
                bHasVal2:=false
            if DataArr["Physical properties"].HasKey(w)
            {
                bHasVal3:=true
                strCompoundAssembled.=": " DataArr["Physical properties"][w] 
                ; ErrorArr.Remove(k)
				; CompoundStatementArr.Remove(s)
            }
            Else
                bHasVal3:=false
            if DataArr["Environmental properties"].HasKey(w)
            {
                bHasVal4:=true
                strCompoundAssembled.=": " DataArr["Environmental properties"][w]
                ; CompoundStatementArr.Remove(s)
            }
            else
                bHasVal4:=false
            if DataArr["Supplemental label elements/information on certain substances and mixtures"].HasKey(w)
            {
                bHasVal5:=true
                strCompoundAssembled.=": " DataArr["Supplemental label elements/information on certain substances and mixtures"][w]
                ; CompoundStatementArr.Remove(s)
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
				strCompoundAssembled.= ": " w 
			vNumErr++
			}
                strCompoundAssembled.=" "
        }
    if !(bHasVal1 || bHasVal2 || bHasVal3 || bHasVal4 || bHasVal5) and SubStr(v,1,1)!="#"
	{
       ErrorString:=StrReplace(ErrorString.= "`n"  v , "Error 01:", "Error 02:") ;,"^(?!.*Specific phrase missing.*).+$")

	}
	ErrorString:=RegExReplace(ErrorString,"^(?!.*Specific phrase missing.*).+$")
	

d= ; problem: H221 is identified and printed, but it is also found in the string, so it was clearly found.
; need to figure out how to fix that. Also, the final error log might not be necessary anymore because we are already giving distinct messages. 
; Need a means of tabulating in the lines of text that have errors to make them easier to find for others.
(
H221+H2122+H2232: Flammable gas.   


ERROR LOG (REMOVE AFTERWARDS)
-----------------
Error 01: Key 'H221+H2122+H2232' could not be found on file. Please search and insert manually.Specific phrase missing: H221
Error 01: Key 'H221+H2122+H2232' could not be found on file. Please search and insert manually.Specific phrase missing: H2122
Error 01: Key 'H221+H2122+H2232' could not be found on file. Please search and insert manually.Specific phrase missing: H2232
Error 01: Key 'H221+H2122+H2232' could not be found on file. Please search and insert manually.
-----------------
)
    }
	if bIndentPhrase ; aka we have errors
		return str A_Tab strCompoundAssembled
	else
    	return str strCompoundAssembled
}

f_CreateTrayMenu(IniObj)
{ ; facilitates creation of the tray menu
    menu, tray, add,
    Menu, Misc, add, Open Script-folder, lOpenScriptFolder
    menu, Misc, Add, Reload, lReload
    menu, Misc, Add, About, Label_AboutFile
	menu, Misc, Add, How to use it, lExplainHowTo
    SplitPath, A_ScriptName,,,, ScriptName
    f_AddStartupToggleToTrayMenu(ScriptName,"Misc")
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
f_AddStartupToggleToTrayMenu(ScriptName,MenuNameToInsertAt:="Tray")
{ ; add a toggle to create a link in startup folder for this script to the respective menu
    VNI=1.0.0.1
    global startUpDir 
    global MenuNameToInsertAt2
    global bBootSetting
    MenuNameToInsertAt2:=MenuNameToInsertAt
    startUpDir:=(A_Startup "\" A_ScriptName " - Shortcut.lnk")
    Menu, %MenuNameToInsertAt%, add, Start at Boot, lStartUpToggle
    If FileExist(startUpDir)
    {
        Menu, %MenuNameToInsertAt%, Check, Start at Boot
        bBootSetting:=1
    }
    else
    {
        Menu, %MenuNameToInsertAt%, UnCheck, Start at Boot
        bBootSetting:=0
    }
    return
    lStartUpToggle: ; I could really use a better way to know the name of the menu item that was selected
    if !bBootSetting 
    {
        bBootSetting:=1
        FileCreateShortcut, %A_ScriptFullPath%, %startUpDir%
        Menu, %MenuNameToInsertAt2%, Check, Start at Boot
    }
    else if bBootSetting
    {
        bBootSetting:=0
        FileDelete, %startUpDir%
        Menu, %MenuNameToInsertAt2%, UnCheck, Start at Boot
    }
    return
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
DL_TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
	{
	 DL_TF_GetData(OW, Text, FileName)
	 IfNotInString, Text, %SearchText%
		Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
	 TF_MatchList:=DL__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			 StringReplace, LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
			 OutPut .= LoopField "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return DL_TF_ReturnOutPut(OW, OutPut, FileName)
	}

	DL_TF_GetData(byref OW, byref Text, byref FileName)
	{
	 If (text = 0 "") ; v3.6 -> v3.7 https://github.com/hi5/TF/issues/4 and https://autohotkey.com/boards/viewtopic.php?p=142166#p142166 in case user passes on zero/zeros ("0000") as text - will error out when passing on one 0 and there is no file with that name
		{
		 IfNotExist, %Text% ; additional check to see if a file 0 exists
			{
			 MsgBox, 48, TF Lib Error, % "Read Error - possible reasons (see documentation):`n- Perhaps you used !""file.txt"" vs ""!file.txt""`n- A single zero (0) was passed on to a TF function as text"
			 ExitApp
			}
		}
	 OW=0 ; default setting: asume it is a file and create file_copy
	 IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
		{
		 If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
			{
			 Text:=SubStr(Text,2)
			 OW=1 ; overwrite file (if it is a file)
			}
		 IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
			{
			 If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
				Text:= "!" . Text
			 OW=2 ; no file, so it is a var or Text passed on directly to TF
			}
		}
	 Else ; there is a newline character in Text so it has to be a variable
		{
		 OW=2
		}
	 If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
		{
		 Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
		 FileName=%Text% ; Store FileName
		 FileRead, Text, %Text% ; Read file and return as var Text
		 If (ErrorLevel > 0)
			{
			 MsgBox, 48, TF Lib Error, % "Can not read " FileName
			 ExitApp
			}
		}
	 Return
	}


	; DL__MakeMatchList()
	; Purpose:
	; Make a MatchList which is used in various functions
	; Using a MatchList gives greater flexibility so you can process multiple
	; sections of lines in one go avoiding repetitive fileread/append actions
	; For TF 3.4 added COL = 0/1 option (for TF_Col* functions) and CallFunc for
	; all TF_* functions to facilitate bug tracking
	DL__MakeMatchList(Text, Start = 1, End = 0, Col = 0, CallFunc = "Not available")
		{
		ErrorList=
		(join|
	Error 01: Invalid StartLine parameter (non numerical character)`nFunction used: %CallFunc%
	Error 02: Invalid EndLine parameter (non numerical character)`nFunction used: %CallFunc%
	Error 03: Invalid StartLine parameter (only one + allowed)`nFunction used: %CallFunc%
		)
		StringSplit, ErrorMessage, ErrorList, |
		Error = 0

		If (Col = 1)
			{
			LongestLine:=TF_Stat(Text)
			If (End > LongestLine) or (End = 1) ; FIXITHERE BUG
				End:=LongestLine
			}

		TF_MatchList= ; just to be sure
		If (Start = 0 or Start = "")
			Start = 1

		; some basic error checking

		; error: only digits - and + allowed
		If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
			Error = 1

		If (RegExReplace(End, "[0-9 ]", "") <> "")
			Error = 2

		; error: only one + allowed
		If (TF_Count(Start,"+") > 1)
			Error = 3

		If (Error > 0 )
			{
			MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
			ExitApp
			}

		; Option #0 [ added 30-Oct-2010 ]
		; Startline has negative value so process X last lines of file
		; endline parameter ignored

		If (Start < 0) ; remove last X lines from file, endline parameter ignored
			{
			Start:=TF_CountLines(Text) + Start + 1
			End=0 ; now continue
			}

		; Option #1
		; StartLine has + character indicating startline + incremental processing.
		; EndLine will be used
		; Make TF_MatchList

		IfInString, Start, `+
			{
			If (End = 0 or End = "") ; determine number of lines
				End:= TF_Count(Text, "`n") + 1
			StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
			Loop, %Section0%
				{
				StringSplit, SectionLines, Section%A_Index%, `+
				LoopSection:=End + 1 - SectionLines1
				Counter=0
					TF_MatchList .= SectionLines1 ","
				Loop, %LoopSection%
					{
					If (A_Index >= End) ;
						Break
					If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
						{
						TF_MatchList .= (SectionLines1 + A_Index) ","
						Counter=0
						}
					Else
						Counter++
					}
				}
			StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
			Return TF_MatchList
			}

		; Option #2
		; StartLine has - character indicating from-to, COULD be multiple sections.
		; EndLine will be ignored
		; Make TF_MatchList

		IfInString, Start, `-
			{
			StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
			Loop, %Section0%
				{
				StringSplit, SectionLines, Section%A_Index%, `-
				LoopSection:=SectionLines2 + 1 - SectionLines1
				Loop, %LoopSection%
					{
					TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
					}
				}
			StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
			Return TF_MatchList
			}

		; Option #3
		; StartLine has comma indicating multiple lines.
		; EndLine will be ignored

		IfInString, Start, `,
			{
			TF_MatchList:=Start
			Return TF_MatchList
			}

		; Option #4
		; parameters passed on as StartLine, EndLine.
		; Make TF_MatchList from StartLine to EndLine

		If (End = 0 or End = "") ; determine number of lines
				End:= TF_Count(Text, "`n") + 1
		LoopTimes:=End-Start
		Loop, %LoopTimes%
			{
			TF_MatchList .= (Start - 1 + A_Index) ","
			}
		TF_MatchList .= End ","
		StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		Return TF_MatchList
		}


	; Write to file or return variable depending on input
	DL_TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) 
	{
		If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
			{
			IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
			{
				If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
				{
					OW = 1
					Goto lCreateNewFile
				}
				Else
					Return
			}
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			SplitPath, FileName,, Dir, Ext, Name
			If (Dir = "") ; if Dir is empty Text & script are in same directory
				Dir := A_WorkingDir
			IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
				FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
			FileDelete, % Dir "\" Name "_copy." Ext
			FileAppend, %Text%, % Dir "\" Name "_copy." Ext
			Return Errorlevel ? False : True
			}
		lCreateNewFile:
		If (OW = 1) ; input was file, will be overwritten by output
		{
			IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
			{
				If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
					Return
			}
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			SplitPath, FileName,, Dir, Ext, Name
			If (Dir = "") ; if Dir is empty Text & script are in same directory
				Dir := A_WorkingDir
			IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
				FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
			FileDelete, % Dir "\" Name "." Ext
			FileAppend, %Text%, % Dir "\" Name "." Ext
			Return Errorlevel ? False : True
		}
		If (OW = 2) ; input was var, return variable
		{
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			Return Text
		}
	}
;}_____________________________________________________________________________________
;{#[Include Section]



;}_____________________________________________________________________________________

lWriteLibraryFromHardCode:

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
; m("figure out how to write a continuation section to file successfully")
f_ThrowError("Main Code Body","Library-file containing the H&P-phrases does not exist, initiating from default settings. ", A_ScriptNameNoExt . "_"0, Exception("",-1).Line)
if !Instr(FileExist(A_ScriptDir "\INI-Files"),"D") ; check if folder structure exists
	FileCreateDir, % A_ScriptDir "\INI-Files"

; sPathLibraryFile
UrlDownloadToFile, https://gist.githubusercontent.com/Gewerd-Strauss/66c07fc5616a8336b52e3609cc9f36ef/raw/f9d2b785ba8259b58b768d2f4b13a498890de26c/gistfile1.txt,%sPathLibraryFile%
sPathLibraryFile:=script.configfile
FileReadLine, bDownloadFailed,%sPathLibraryFile%,1
if (bDownloadFailed="404: Not Found")
{
	FileDelete, %sPathLibraryFile%
	FileAppend, %LibraryBackup%, %sPathLibraryFile%
}


; UrlDownloadToFile, https://gist.githubusercontent.com/Gewerd-Strauss/66c07fc5616a8336b52e3609cc9f36ef/raw/f9d2b785ba8259b58b768d2f4b13a498890de26c/gistfile1.txt,%sPathLibraryFile%
; FileReadLine, bDownloadFailed,%sPathLibraryFile%,1
; if (bDownloadFailed="404: Not Found")
; {
; 	FileDelete, %sPathLibraryFile%
; 	FileAppend, %LibraryBackup%, %sPathLibraryFile%
; }
; DataArr:=fReadIni(sPathLibraryFile) ; load the data of the


gosub, lExplainHowTo
DataArr:=fReadIni(script.configfile) ; load the data of the

return
lExplainHowTo:
m("Missing Definitions of Phrases. Creating Library-File in """ A_ScriptDir """ for future uses.","Phrases taken from ""https://ec.europa.eu/taxation_customs/dds2/SAMANCTA/EN/Safety/HP_EN.htm""`n","fetched on 15.11.2021")
m("In order to use this, write the H-and P-phrases below each other:","`nH317`nH319`nH361`n","Alternatively, combinations of phrases must be written like this:","P305+P351+P338")
m("After finishing collecting all phrases of a chemical, highlight/select each set of phrases on their own.","Then, press Alt+0 (The number row-0, not the 0 of the NumBlock).","The corresponding phrases will then be inserted into the document.")
m("The Error-Log gives an overview if phrases cannot be found in the file, and need to be added to that file first.")
m("I obviously do not guarantee the validity of the phrases which come with this file, because they might change and are probably dependent on where you life.")
m("To edit phrases, open the library file and edit the respective phrase","`nYou can also add phrases, by following the style in the file. Make sure you don't edit the [Headers], such as [P-Phrases].")


return



fIsConnected(URL="https://google.com") 
{ ; retrieved from lxiko's "AHKRare" https://github.com/Ixiko/AHK-Rare          ;-- Returns true if there is an available internet connection
	return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
} ;</10.01.000020>
 ;Clip() - Send and Retrieve Text Using the Clipboard
 ;by berban - updated February 18, 2019
 ;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156

 ;modified by Gewerd Strauss

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


/* original by berban https://github.com/berban/Clip/blob/master/Clip.ahk
	; Clip() - Send and Retrieve Text Using the Clipboard
; by berban - updated February 18, 2019
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
	Clip(Text="", Reselect="")
	{
		Static BackUpClip, Stored, LastClip
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
		}
		Return
		Clip:
		Return Clip()
	}
*/

