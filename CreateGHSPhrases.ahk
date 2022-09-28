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
;; code for script starts on line 1230
		; from RaptorX https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
		/**
		* ============================================================================ *
		* @Author           : RaptorX <graptorx@gmail.com>
		* @Script Name      : Script Object
		* @Script Version   : 0.24.3
		* @Homepage         :
		*
		* @Creation Date    : November 09, 2020
		* @Modification Date: September 02, 2021
		* @Modification G.S.: 08.2022
		; @Description Modification G.S.:
			- added field for GitHub-link, a Forum-link 
			and a credits-field, as well as a template 
			to quickly copy out into new scripts
			Contains methods for saving and loading 
			config-files containing an array - 
			basically an integration of Wolf_II's
			WriteIni/ReadIni with some adjustments
			added Update()-functionality for non-zipped
			remote files so that one can update a 
			A_ScriptFullPath-contained script from 
			f.e. GH.
			- Reworked the Update()-Method with help of 
			u/anonymous1184.
			- Added filter to not engange Update-method 
			if vfile contains the words "REPOSITORY_NAME" 
			or "BRANCH_NAME", indicating a template has
			not been adjusted yet - or is not intended to
			- added autoformatting for ingesting credits via
			the "CreditsRaw"-continuation-section in the 
			template below
										
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

		; /Template_Start
		/*
		for creditsRaw, use "/" in the "URL"-field when the snippet is not published yet (e.g. for code you've written yourself and not published yet)
		space author, SnippetNameX and URLX out by spaces or tabs, and remember to include "-" inbetween both fields
		when 2+ snippets are located at the same url, concatenate them with "|" and treat them as a single one when putting together the URL's descriptor string
		finally, make sure toingest 'CreditsRaw' into the 'credits'-field of the template below.
		*/
		; CreditsRaw=
		; (LTRIM
		; author1   -		 snippetName1		   		  			-	URL1
		; Gewerd Strauss		- snippetName2|SnippetName3 (both at the same URL)								-	/
		; )
		; FileGetTime, ModDate,%A_ScriptFullPath%,M
		; FileGetTime, CrtDate,%A_ScriptFullPath%,C
		; CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
		; ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
		; global script := {   base         : script
		;                     ,name         : regexreplace(A_ScriptName, "\.\w+")
		;                     ,version      : FileOpen(A_ScriptDir "\version.ini","r").Read()
		;                     ,author       : "Gewerd Strauss"
		; 					,authorID	  : "Laptop-C"
		; 					,authorlink   : ""
		;                     ,email        : ""
		;                     ,credits      : CreditsRaw
		; 					,creditslink  : ""
		;                     ,crtdate      : CrtDate
		;                     ,moddate      : ModDate
		;                     ,homepagetext : ""
		;                     ,homepagelink : ""
		;                     ,ghtext 	  : "GH-Repo"
		;                     ,ghlink       : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME"
		;                     ,doctext	  : ""
		;                     ,doclink	  : ""
		;                     ,forumtext	  : ""
		;                     ,forumlink	  : ""
		;                     ,donateLink	  : ""
		;                     ,resfolder    : A_ScriptDir "\res"
		;                     ,iconfile	  : ""
		; 					,rfile  	  : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME/archive/refs/heads/BRANCH_NAME.zip"
		; 					,vfile_raw	  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
		; 					,vfile 		  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
		; 					,vfile_local  : A_ScriptDir "\version.ini" 
		;                     ,config:		[]
		; 					,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
		;                     ,configfolder : A_ScriptDir "\INI-Files"}
		/*	
			; For throwing errors via script.debug
			script.Error:={	 Level		:""
							,Label		:""
							,Message	:""	
							,Error		:""		
							,Vars:		:[]
							,AddInfo:	:""}
			if script.error
				script.Debug(script.error.Level,script.error.Label,script.error.Message,script.error.AddInfo,script.error.Vars)
		*/
		; script.Load()
		; , script.Update(,,) ;; DO NOT ACTIVATE THISLINE UNTIL YOU DUMBO HAS FIXED THE DAMN METHOD. God damn it.
		; /Template_End
		class script
		{
			static DBG_NONE     := 0
				,DBG_ERRORS   := 1
				,DBG_WARNINGS := 2
				,DBG_VERBOSE  := 3

			static name       := ""
				,version      := ""
				,author       := ""
				,authorID	  := ""
				,authorlink   := ""
				,email        := ""
				,credits      := ""
				,creditslink  := ""
				,crtdate      := ""
				,moddate      := ""
				,homepagetext := ""
				,homepagelink := ""
				,ghtext 	  := ""
				,ghlink       := ""
				,doctext	  := ""
				,doclink	  := ""
				,forumtext	  := ""
				,forumlink	  := ""
				,donateLink   := ""
				,resfolder    := ""
				,iconfile     := ""
				,vfile_local  := ""
				,vfile_remote := ""
				,config       := ""
				,configfile   := ""
				,configfolder := ""
				,icon         := ""
				,systemID     := ""
				,dbgFile      := ""
				,rfile		  := ""
				,vfile		  := ""
				,dbgLevel     := this.DBG_NONE
				,versionScObj := "0.21.3"


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
			Update(vfile:="", rfile:="",bSilentCheck:=false,Backup:=true)
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
				vfile:=(vfile=="")?this.vfile:vfile
				,rfile:=(rfile=="")?this.rfile:rfile
				{
					if RegexMatch(vfile,"\d+") || RegexMatch(rfile,"\d+")	 ;; allow skipping of the routine by simply returning here
						return
					; Error Codes
					if (vfile="") 											;; disregard empty vfiles
						return
					if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
						exception({code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."})
					if  (regexmatch(vfile, "(REPOSITORY_NAME|BRANCH_NAME)"))
						Return												;; let's not throw an error when this happens because fixing it is irrelevant to development in 95% of all cases

					; This function expects a ZIP file
					if (!regexmatch(rfile, "\.zip"))
						exception({code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."})

					; Check if we are connected to the internet
					http := comobjcreate("WinHttp.WinHttpRequest.5.1")
					, http.Open("GET", "https://www.google.com", true)
					, http.Send()
					try
						http.WaitForResponse(1)
					catch e
						throw {code: ERR_NOCONNECT, msg: e.message}
					if (!bSilentCheck)
							Progress, 50, 50/100, % "Checking for updates", % "Updating"

					; Download remote version file
					http.Open("GET", vfile, true)
					http.Send(), http.WaitForResponse()

					if !(http.responseText)
					{
						Progress, OFF
						try
							throw exception("There was an error trying to download the ZIP file for the update.`n","script.Update()","The server did not respond.")
						Catch, e
							msgbox, 8240,% this.Name " -  No response from server", % e.Message "`n`nCheck again later`, or contact the author/provider. Script will resume normal operation."
					}
					regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)		;; as this.version is not updated automatically, instead read the local version file
					
					; FileRead, loVersion,% A_ScriptDir "\version.ini"
					d:=http.responseText
					regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)
					if (!bSilentCheck)
					{
						Progress, 100, 100/100, % "Checking for updates", % "Updating"
						sleep 500 	; allow progress to update
					}
					Progress, OFF

					; Make sure SemVer is used
					if (!loVersion || !remVersion)
					{
						try
							throw exception("Invalid version.`n The update-routine of this script works with SemVer.","script.Update()","For more information refer to the documentation in the file`n" )
						catch, e
							msgbox, 8240,% "Invalid Version", % e.What ":" e.Message "`n`n" e.Extra "'" e.File "'."
					}
					; Compare against current stated version
					ver1 := strsplit(loVersion, ".")
					, ver2 := strsplit(remVersion, ".")
					, bRemoteIsGreater:=[0,0,0]
					, newversion:=false
					for i1,num1 in ver1
					{
						for i2,num2 in ver2
						{
							if (i1 == i2)
							{
								if (num2 > num1)
								{
									bRemoteIsGreater[i1]:=true
									break
								}
								else if (num2 = num1)
									bRemoteIsGreater[i1]:=false
								else if (num2 < num1)
									bRemoteIsGreater[i1]:=-1
							}
						}
					}
					if (!bRemoteIsGreater[1] && !bRemoteIsGreater[2]) ;; denotes in which position (remVersion>loVersion) → 1, (remVersion=loVersion) → 0, (remVersion<loVersion) → -1 
						if (bRemoteIsGreater[3] && bRemoteIsGreater[3]!=-1)
							newversion:=true
					if (bRemoteIsGreater[1] || bRemoteIsGreater[2])
						newversion:=true
					if (bRemoteIsGreater[1]=-1)
						newversion:=false
					if (bRemoteIsGreater[2]=-1) && (bRemoteIsGreater[1]!=1)
						newversion:=false
					if (!newversion)
					{
						if (!bSilentCheck)
							msgbox, 8256, No new version available, You are using the latest version.`n`nScript will continue running.
						return
					}
					else
					{
						; If new version ask user what to do				"C:\Users\CLAUDI~1\AppData\Local\Temp\AHK_LibraryGUI
						; Yes/No | Icon Question | System Modal
						msgbox % 0x4 + 0x20 + 0x1000
							, % "New Update Available"
							, % "There is a new update available for this application.`n"
							. "Do you wish to upgrade to v" remVersion "?"
							, 10	; timeout

						ifmsgbox timeout
						{
							try
								throw exception("The message box timed out.","script.Update()","Script will not be updated.")
							Catch, e
								msgbox, 4144,% this.Name " - " "New Update Available" ,   % e.Message "`nNo user-input received.`n`n" e.Extra "`nResuming normal operation now.`n"
							return
						}
						ifmsgbox no
						{		;; decide if you want to have this or not. 
							; try
							; 	throw exception("The user pressed the cancel button.","script.Update()","Script will not be updated.") ;{code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}
							; catch, e
							; 	msgbox, 4144,% this.Name " - " "New Update Available" ,   % e.Message "`n`n" e.Extra "`nResuming normal operation now.`n"
							return
						}

						; Create temporal dirs
						ghubname := (InStr(rfile, "github") ? regexreplace(a_scriptname, "\..*$") "-latest\" : "")
						filecreatedir % Update_Temp := a_temp "\" regexreplace(a_scriptname, "\..*$")
						filecreatedir % zipDir := Update_Temp "\uzip"

						; ; Create lock file
						; fileappend % a_now, % lockFile := Update_Temp "\lock"

						; Download zip file
						urldownloadtofile % rfile, % file:=Update_Temp "\temp.zip"

						; Extract zip file to temporal folder
						shell := ComObjCreate("Shell.Application")

						; Make backup of current folder
						if !Instr(FileExist(Backup_Temp:= A_Temp "\Backup " regexreplace(a_scriptname, "\..*$") " - " StrReplace(loVersion,".","_")),"D")
							FileCreateDir, % Backup_Temp
						else
						{
							FileDelete, % Backup_Temp
							FileCreateDir, % Backup_Temp
						}
						; Gui +OwnDialogs
						MsgBox 0x34, `% this.Name " - " "New Update Available", Last Chance to abort Update.`n`n(also remove this once you're done debugging the updater)`nDo you want to continue the Update?
						IfMsgBox Yes 
						{
							Err:=CopyFilesAndFolders(A_ScriptDir, Backup_Temp,1)
							, Err2:=CopyFilesAndFolders(Backup_Temp ,A_ScriptDir  ,0)
							, items1 := shell.Namespace(file).Items
							for item_ in items1
							{
								root := item_.Path
								, items:=shell.Namespace(root).Items
								for item in items
									shell.NameSpace(A_ScriptDir).CopyHere(item, 0x14)
							}
							MsgBox, 0x40040,,Update Finished
							FileRemoveDir, % Backup_Temp,1
							FileRemoveDir, % Update_Temp,1
							reload
						}
						Else IfMsgBox No
						{	; no update, cleanup the previously downloaded files from the tmp
							MsgBox, 0x40040,,Update Aborted
							FileRemoveDir, % Backup_Temp,1
							FileRemoveDir, % Update_Temp,1

						}
					}
				}
			}

			
			Autostart(status,UseRegistry:=0)
			{
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
				if (UseRegistry)
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
				else
				{
					startUpDir:=(A_Startup "\" A_ScriptName " - Shortcut.lnk")
					if (status) ; add to startup
						FileCreateShortcut, % A_ScriptFullPath, % startUpDir
					else
						FileDelete, % startUpDir
				}

				
			}

			
			Splash(img:="", speed:=10, pause:=2)
			{
				/**
				Function: Splash
				Shows a custom image as a splash screen with a simple fading animation

				Parameters:
				img   (opt) - file to be displayed
				speed (opt) - fast the fading animation will be. Higher value is faster.
				pause (opt) - long in seconds the image will be paused after fully displayed.
				*/
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

			
			Debug(level:=1, label:=">", msg:="", AddInfo:="",InvocationLine:="", vars*)
			{
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

				if !this.dbglevel
					return
				if (InvocationLine!="")
					DebugInvokedOn:="Source Code: Function invoked on line " RegexReplace(InvocationLine,"\D") "`nError invoked in function body of " " on line " Exception("",-1).Line
				for i,var in vars
				{
					if IsObject(var)
						var:=RegExReplace(ScriptObj_Obj2Str(var),"\.\d* = ","")
					varline .= "`n" var
				}
				dbgMessage := label " [invoked on " RegexReplace(InvocationLine,"\D") "]" "`n" DebugInvokedOn "`n>" msg "`n" varline

				if (level <= this.dbglevel)
					outputdebug % dbgMessage
				else if this.dbgFile
					FileAppend, % dbgMessage, % this.dbgFile
				else
					MsgBox 0x10, % this.Name " - " "Error encountered: " this.Error.Error , % Clipboard:=dbgmessage
					; script.Error:={	 Level		:""
					;     ,Label		:""
					;     ,Message	:""	
					;     ,Error		:""		
					;     ,Vars		:[]
					;     ,AddInfo	:""}
				script.ErrorCache[A_Now]:=script.Error
			}

			
			About(scriptName:="", version:="", author:="",credits:="", homepagetext:="", homepagelink:="", donateLink:="", email:="")
			{
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
				static doc
				scriptName := scriptName ? scriptName : this.name
				, version := version ? version : this.version
				, author := author ? author : this.author
				, credits := credits ? credits : this.credits
				, creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
				, ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
				, ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
				, doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
				, doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
				, forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
				, forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
				, homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
				, homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
				, donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
				, email := email ? email : this.email
				
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
				; Clipboard:=html
				if (creditslink and credits) || IsObject(credits) || RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
				{
					if RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
					{
						CreditsLines:=strsplit(credits,"`n")
						Credits:={}
						for k,v in CreditsLines
						{
							if ((InStr(v,"author1") && InStr(v,"snippetName1") && InStr(v,"URL1")) || (InStr(v,"snippetName2|snippetName3")))
								continue
							val:=strsplit(strreplace(v,"`t"," ")," - ")
							Credits[Trim(val.2)]:=Trim(val.1) "|" Trim((strlen(val.3)>5?val.3:""))
						}
					}
					; Clipboard:=html
					if IsObject(credits)
					{
						CreditsAssembly:="credits for used code:`n"
						for k,v in credits
						{
							; if Instr()
							if (k="")
								continue
							if (strsplit(v,"|").2="")
								CreditsAssembly.="<p>" k " - " strsplit(v,"|").1 "`n"
							else
								CreditsAssembly.="<p><a href=" """" strsplit(v,"|").2 """" ">" k " - " strsplit(v,"|").1 "</a></p>`n"
						}
						html.=CreditsAssembly
						; Clipboard:=html
					}
					else
					{
						sTmp=
						(
									<p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
									<hr>
						)
						html.=sTmp
					}
					; Clipboard:=html
				}
				if forumlink and forumtext
				{
					sTmp=
					(

								<p><a href="https://%forumlink%" target="_blank">%forumtext%</a></p>
					)
					html.=sTmp
					; Clipboard:=html
				}
				if homepagelink and homepagetext
				{
					sTmp=
					(

								<p><a href="https://%homepagelink%" target="_blank">%homepagetext%</a></p>

					)
					html.=sTmp
					; Clipboard:=html
				}
				sTmp=
				(

										</div>
							%donateSection%
						</body>
					</html>
				)
				html.=sTmp
				btnxPos := 300/2 - 75/2
				, axHight:=12
				, donateHeight := donateLink ? 6 : 0
				, forumHeight := forumlink ? 1 : 0
				, ghHeight := ghlink ? 1 : 0
				, creditsHeight := creditslink ? 1 : 0
				, creditsHeight+=credits.Count()*1.5 ; + d:=(credits.Count()>0?2.5:0)
				, homepageHeight := homepagelink ? 1 : 0
				, docHeight := doclink ? 1 : 0
				, axHight+=donateHeight
				, axHight+=forumHeight
				, axHight+=ghHeight
				, axHight+=creditsHeight
				, axHight+=homepageHeight
				, axHight+=docHeight
				if (axHight="")
					axHight:=12
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

			
			GetLicense()
			{
				/*
				Function: GetLicense
				Parameters:
				Notes:
				*CreditsRaw		global

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

			
			SaveLicense(licenseType, licenseNumber)
			{
				/*
				Function: SaveLicense
				Parameters:
				Notes:
				*/
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

			
			IsLicenceValid(licenseType, licenseNumber, URL)
			{
				/*
				Function: IsLicenceValid
				Parameters:
				Notes:
				*/
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

			
			EDDRequest(URL, Action, licenseType, licenseNumber)
			{
				/*
				Function: EDDRequest
				Parameters:
				Notes:
				*/
				strQuery := url "?edd_action=" Action
						.  "&item_id=" licenseType
						.  "&license=" licenseNumber
						.  (this.systemID ? "&url=" this.systemID : "")

				try
				{
					http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
					, http.Open("GET", strQuery)
					, http.SetRequestHeader("Pragma", "no-cache")
					, http.SetRequestHeader("Cache-Control", "no-cache, no-store")
					, http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; Win32)")
					, http.Send()
					, http.WaitForResponse()

					return http.responseText
				}
				catch err
					return err.what ":`n" err.message
			}

		/*


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

		*/

			Load(INI_File:="")
			{
				if (INI_File="")
					INI_File:=this.configfile
				Result := []
				, OrigWorkDir:=A_WorkingDir
				if (d_fWriteINI_st_count(INI_File,".ini")>0)
				{
					INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ;; reduce number of ".ini"-patterns to 1
					if (d_fWriteINI_st_count(INI_File,".ini")>0)
						INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ;		 and remove the last instance
				}
				if (this.config.MaxIndex()>0 && this.config.MaxIndex()!="")	;; only run this routine when the config actually contains values and is not simply an empty file.
				{
					if !FileExist(INI_File) ;; create new INI_File if not existing
					{
						msgbox, 8240,% this.Name " -  No Save File found", % e.Message "`n`nNo save file was found.`nPlease reinitialise settings if possible."
						return
					}
					SplitPath, INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
					if !Instr(d:=FileExist(INI_File_Dir),"D:")
						FileCreateDir, % INI_File_Dir
					if !FileExist(INI_File_File ".ini") ;; check for ini-file file ending
						FileAppend,, % INI_File ".ini"
					SetWorkingDir, INI-Files
					IniRead, SectionNames, % INI_File ".ini"
					for each, Section in StrSplit(SectionNames, "`n") {
						IniRead, OutputVar_Section, % INI_File ".ini", %Section%
						for each, Haystack in StrSplit(OutputVar_Section, "`n")
						{
							If (Instr(Haystack,"="))
							{
								RegExMatch(Haystack, "(.*?)=(.*)", $)
							, Result[Section, $1] := $2
							}
							else
								Result[Section, Result[Section].MaxIndex()+1]:=Haystack
						}
					}
					if A_WorkingDir!=OrigWorkDir
						SetWorkingDir, %OrigWorkDir%
					this.config:=Result
				}
					
			}
			Save(INI_File:="")
			{
				if (INI_File="")
					INI_File:=this.configfile
				SplitPath, INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
				if (d_fWriteINI_st_count(INI_File,".ini")>0)
				{
					INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
					if (d_fWriteINI_st_count(INI_File,".ini")>0)
						INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
				}
				if (this.config.MaxIndex()>0)
					("Saving")
				if !Instr(d:=FileExist(INI_File_Dir),"D:")
					FileCreateDir, % INI_File_Dir
				if !FileExist(INI_File_File ".ini") ; check for ini-file file ending
					FileAppend,, % INI_File ".ini"
				for SectionName, Entry in this.config
				{
					Pairs := ""
					for Key, Value in Entry
					{
						WriteInd++
						if !Instr(Pairs,Key "=" Value "`n")
							Pairs .= Key "=" Value "`n"
					}
					IniWrite, %Pairs%, % INI_File ".ini", %SectionName%
				}
			}




		}

		d_fWriteINI_st_removeDuplicates(string, delim="`n")
		{ ; remove all but the first instance of 'delim' in 'string'
			; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
			/*
				RemoveDuplicates
				Remove any and all consecutive lines. A "line" can be determined by
				the delimiter parameter. Not necessarily just a `r or `n. But perhaps
				you want a | as your "line".

				string = The text or symbols you want to search for and remove.
				delim  = The string which defines a "line".

				example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
				output:  aaa|bbb|ccc|ddd
			*/
			delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
			Return RegExReplace(string, "(" delim ")+", "$1")
		}
		d_fWriteINI_st_count(string, searchFor="`n")
		{ ; count number of occurences of 'searchFor' in 'string'
			; copy of the normal function to avoid conflicts.
			; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
			/*
				Count
				Counts the number of times a tolken exists in the specified string.

				string    = The string which contains the content you want to count.
				searchFor = What you want to search for and count.

				note: If you're counting lines, you may need to add 1 to the results.

				example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
				output:  4
			*/
			StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
			return ErrorLevel
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


		CopyFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)
		{
			; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and
			; returns the number of files/folders that could not be copied.
			; First copy all the files (but not the folders):
			; FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
			; ErrorCount := ErrorLevel
			; Now copy all the folders:
			Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
			{
				FileCopyDir, % A_LoopFileFullPath, % DestinationFolder "\" A_LoopFileName , % DoOverwrite
				ErrorCount += ErrorLevel
				if ErrorLevel  ; Report each problem folder by name.
					MsgBox,% "Could not copy " A_LoopFileFullPath " into " DestinationFolder "."
			}
			return ErrorCount
		}

		ttip_ScriptObj(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
		{
			/*
				v.0.2.1
				Date: 24 Juli 2021 19:40:56: 
				
				Modes:  
				1: remove tt after "to" milliseconds 
				2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
				3: not sure anymore what the plan was lol - remove 
				4: shows tooltip slightly offset from current mouse, does not repeat
				5: keep that tt until the function is called again  

				CoordMode:
				-1: Default: currently set behaviour
				1: Screen
				2: Window

				to: 
				Timeout in milliseconds
				
				xp/yp: 
				xPosition and yPosition of tooltip. 
				"NaN": offset by +50/+50 relative to mouse
				IF mode=4, 
				----  Function uses tooltip 20 by default, use parameter
				"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
				separately from each other, hence a removal of ttip20 will not remove tt14 

				---
				v.0.2.1
				- added Obj2Str-Conversion via "ScriptObj_Obj2Str()"
				v.0.1.1 
				- Initial build, 	no changelog yet
			
			*/
			
			;if (text="TTIP: Test")
				;m(to)
				cCoordModeTT:=A_CoordModeToolTip
			if (text="") || (text=-1)
				gosub, lScriptObj_TTIP_Removettip
			if IsObject(text)
				text:=ScriptObj_Obj2Str(text)
			static ttip_text
			static lastcall_tip
			static currTip2
			global ttOnOff
			currTip2:=currTip
			cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
			CoordMode, % cMode
			tooltip,

			
			ttip_text:=text
			lUnevenTimers:=false 
			MouseGetPos,xp1,yp1
			if (mode=4) ; set text offset from cursor
			{
				yp:=yp1+15
				xp:=xp1
			}	
			else
			{
				if (xp="NaN")
					xp:=xp1 + 50
				if (yp="NaN")
					yp:=yp1 + 50
			}
			tooltip, % ttip_text,xp,yp,% currTip
			if (mode=1) ; remove after given time
			{
				SetTimer, lScriptObj_TTIP_Removettip, % "-" to
			}
			else if (mode=2) ; remove, but repeatedly show every "to"
			{
				; gosub,  A
				global to_1:=to
				global to2_1:=to2
				global tTimes:=Times
				Settimer,lScriptObj_TTIP_SwitchOnOff,-100
			}
			else if (mode=3)
			{
				lUnevenTimers:=true
				SetTimer, lScriptObj_RpeatedShow, %  to
			}
			else if (mode=5) ; keep until function called again
			{
				
			}
			CoordMode, % cCoordModeTT
			return text
			lScriptObj_TTIP_SwitchOnOff:
			ttOnOff++
			if mod(ttOnOff,2)	
			{
				gosub, lScriptObj_TTIP_Removettip
				sleep, % to_1
			}
			else
			{
				tooltip, % ttip_text,xp,yp,% currTip
				sleep, % to2_1
			}
			if (ttOnOff>=ttimes)
			{
				Settimer, lScriptObj_TTIP_SwitchOnOff, off
				gosub, lScriptObj_TTIP_Removettip
				return
			}
			Settimer, lScriptObj_TTIP_SwitchOnOff, -100
			return

			lScriptObj_RpeatedShow:
			ToolTip, % ttip_text,,, % currTip2
			if lUnevenTimers
				sleep, % to2
			Else
				sleep, % to
			return
			lScriptObj_TTIP_Removettip:
			ToolTip,,,,currTip2
			return
		}
		ScriptObj_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
			static String,Blank
			if(FullPath=1)
				String:=FullPath:=Blank:=""
			if(IsObject(Obj)){
				for a,b in Obj{
					if(IsObject(b))
						ScriptObj_Obj2Str(b,FullPath "." a,BottomBlank)
					else{
						if(BottomBlank=0)
							String.=FullPath "." a " = " b "`n"
						else if(b!="")
							String.=FullPath "." a " = " b "`n"
						else
							Blank.=FullPath "." a " =`n"
					}
			}}
			return String Blank
		}

;;
FileGetTime, ModDate,%A_ScriptFullPath%,M
FileGetTime, CrtDate,%A_ScriptFullPath%,C
CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
global script := {   base         : script
                    ,name         : regexreplace(A_ScriptName, "\.\w+")
                    ,version      : "2.8.1"
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
SendInput, {AltUp}
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
	if A_IsCompiled
		menu, tray, NoStandard
	menu, tray, add,
	Menu, Misc, add, Open Script-folder, lOpenScriptFolder
	Menu, Misc, add, Search for GHS changes , lUpdateLibrary
	menu, Misc, Add, Reload, lReload
	menu, Misc, Add, Exit Program, lExit
	menu, Misc, Add, About, Label_AboutFile
	menu, Misc, Add, How to use it, lExplainHowTo
	SplitPath, A_ScriptName,,,, scriptname
	Menu, tray, add, Miscellaneous, :Misc
	menu, tray, add,
	return
}
lExit:
ExitApp
return
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
