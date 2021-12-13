# Create-GHS-Phrases
A small script for automatically inserting Hazard-, Precautionary- and EUH-phrases according from file.

# How to use this

1. Write down all Phrase-Keys (`H202`,`P304`,etc) of a chemical below each other. Combinations are connected by `+`:

```
Stannous Octaoate:
H317
H318
H361
H412
P273
P280
P305+P351+P338
```

Then, highlight all the phrase-keys you want to translate, and press <kbd>Alt</kbd> + <kbd>0</kbd>

```
Stannous Octaoate:

H317: May cause an allergic skin reaction.
H318: Causes serious eye damage.
H361: Suspected of damaging fertility or the unborn child <state specific effect if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H412: Harmful to aquatic life with long lasting effects.
P273: Avoid release to the environment.
P280: Wear protective gloves/protective clothing/eye protection/face protection.
P305+P351+P338: IF IN EYES: Rinse cautiously with water for several minutes. Remove contact lenses, if present and easy to do. Continue rinsing.


ERROR LOG (REMOVE AFTERWARDS)
-----------------
-----------------
```

The error-log gives information on phrases whose Key (that is the `H317`, for instance could not be found in the library file). See [Errors](#errors)

# Errors

Using the following input 
```
Stannous Octaoate
H317
H318
H361
H412
P2732
P280
P305+P3511+P338
```

will create an error:
```
Stannous Octaoate

H317: May cause an allergic skin reaction.
H318: Causes serious eye damage.
H361: Suspected of damaging fertility or the unborn child <state specific effect if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H412: Harmful to aquatic life with long lasting effects.
	P2732: P2732 
P280: Wear protective gloves/protective clothing/eye protection/face protection.
	P305+P3511+P338: IF IN EYES: P3511 Remove contact lenses, if present and easy to do. Continue rinsing. 


ERROR LOG (REMOVE AFTERWARDS)
-----------------
Error 1: Key 'P2732' could not be found on file. Please search and insert manually. Specific phrase missing: P2732
Error 2: Key 'P305+P3511+P338' could not be found on file. Please search and insert manually. Specific phrase missing: P3511
-----------------
```
On the one hand, the error log will display all errors found in the file, and point you to whatever key is specifically missing. Lines with missing keys will be indented. The missing key will be displayed as `Key: Key`, e.g `P3511: P3511`, or  inserted at the respective position if it is a multi-phrase statement, e.g. `P305+P3511+P338`:

	P305+P3511+P338: IF IN EYES: P3511 Remove contact lenses, if present and easy to do. Continue rinsing. 
 
# Known limitations and bugs

1. The following two keys have slightly differemt wording:
    
```
H360FD=May damage fertility. May damage the unborn child.
H360Fd=May damage fertility. Suspected of damaging the unborn child.
```
However, because the programm cannot distinguish between lowercase and uppercase letters in the key, both keys result in `May damage fertility. Suspected of damaging the unborn child.`. As both phrases are extremely similar, I am currently not focussing to fix this. I have some approaches to do it, but no time as of right now.
    
--- 

# Requirements
Requires the GHS phrases in specific format, dowloaded from the necessary gist [here](https://gist.github.com/Gewerd-Strauss/66c07fc5616a8336b52e3609cc9f36ef).
The phrases were retrieved from https://ec.europa.eu/taxation_customs/dds2/SAMANCTA/EN/Safety/HP_EN.htm on 02.12.2021. I do not take responsibility for keeping the gist up-to-date. Neither does the script check for changes. The file can be redownloaded by deleting the ini-file located at `A_ScriptDir\INI-Files\CreateGHSPhrases.ini`, where A_ScriptDir is the location of the Script/Executable.

Also requires the scriptObj-File. Original by [RaptorX](https://github.com/RaptorX/ScriptObj), modified version used in this project by [myself](https://github.com/Gewerd-Strauss/ScriptObj). Should be located at the default library location for autohotkey, that being `%A_MyDocuments%\AutoHotkey\Lib\`. For more info, see the documentation on [#include](https://www.autohotkey.com/docs/commands/_Include.htm)


# Executing the program.

Be mindful to keep the folderstructure of the script and the settings-file.

## If you have Autohotkey installed

Just launch the script file the same way you launch any other. Then use the hotkey outlined at the beginning.

## If you don't have Autohotkey installed

Launch the executable. Then use the hotkey outlined at the beginning.

# A small note about languages and regions of validity.

The library-file stored at the address mentioned above, as well as the version contained in the code for the case the hosted gist isn't available only contain the english GHS phrases for the EU. I do not claim them to be complete, or valid for other regions. For the EU, I could not find a more comprehensive collection elsewhere at the time of writing this. If you live elsewhere, please check if the phrases apply in the same way to your location. If you want a translated version, replace the phrases in the settings-file (basically everything behind the "="-sign) with your equivalent. Note that if the file is restored, you'll have to redo it again.

If you are editing this intending to use this program with phrases in a different language, please note that the section titles in the settings file must remain the same. That includes only:

* H-Phrases
* P-Phrases
* Physical Properties
* Environmental Properties
* Supplemental label elements/information on certain substances and mixtures

In principle, these sections are superfluous when it comes to _finding_ a phrase. You could just as easily have only one section called "P-Phrases" and easily push all phrases in there, regardless of wether or not they are actually P-Phrases. That is solely to make it easier for the user. HOWEVER... it is not possible to create a new section and have it read as well - at least not without some additions to the script. 

Therefore, when translating the phrases please do not change any section title, those being "[H-Phrases]","[P-Phrases]" etc in the library file. You can change, remove or add any key-value line to any of these sections, by simply writing in the following way into the library file: `YourKeyHere=YourPhraseHere`, e.g.

When using this script then, the phrase "YourKeyHere" will then be changed to
"YourKeyHere=YourPhraseHere", the same way it is outlined in the documentation.

Example: `H229=Pressurised container: May burst if heated.` → `This Is a technically valid key...=...and this is a technically valid phrase.`

In the above example, the result of executing `Alt+0` on the following line of selected text

`This Is a technically valid key...`

will result in the following line:

`This Is a technically valid key......and this is a technically valid phrase.`



# Code by others

* fClip.ahk, original by [berban](https://github.com/berban/Clip), used version by [me](https://github.com/Gewerd-Strauss/fClip.ahk).
* scriptObj.ahk, original by [RaptorX](https://github.com/RaptorX/ScriptObj), used version slightly modified by [me](https://github.com/Gewerd-Strauss/ScriptObj).
* f_TrayIconSingleClickCallBack, adopted from [Lexikos](https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954)
* HasVal, original from [jNizM](https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173)
* wolf_II's [ReadINI-function](https://www.autohotkey.com/boards/viewtopic.php?p=256940#p256940)
* fIsConnected, retrieved from lxiko's "[AHKRare](https://github.com/Ixiko/AHK-Rare)", a collection of useful snippet functions. 

