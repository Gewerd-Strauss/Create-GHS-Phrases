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

Then, highlight all the phrases you want to translate, and press <kbd>Alt</kbd> + <kbd>0</kbd>

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
 

--- 

Requires the GHS phrases in specific format, dowloaded from the necessary gist [here](https://gist.github.com/Gewerd-Strauss/66c07fc5616a8336b52e3609cc9f36ef).
The phrases were retrieved from https://ec.europa.eu/taxation_customs/dds2/SAMANCTA/EN/Safety/HP_EN.htm on 02.12.2021. I do not take responsibility for keeping the gist up-to-date. Neither does the script check for changes. The file can be redownloaded by deleting the ini-file located at `A_ScriptDir\INI-Files\CreateGHSPhrases.ini`, where A_ScriptDir is the location of the Script/Executable.

Also requires the scriptObj-File. Original by [RaptorX](https://github.com/RaptorX/ScriptObj), modified version used in this project by [myself](https://github.com/Gewerd-Strauss/ScriptObj). Should be located at the default library location for autohotkey, that being `%A_MyDocuments%\AutoHotkey\Lib\`. For more info, see the documentation on [#include](https://www.autohotkey.com/docs/commands/_Include.htm)

# Code by others

* fClip.ahk, original by [berban](https://github.com/berban/Clip), used version by [me](https://github.com/Gewerd-Strauss/fClip.ahk).
* scriptObj.ahk, original by [RaptorX](https://github.com/RaptorX/ScriptObj), used version by [me](https://github.com/Gewerd-Strauss/ScriptObj).
* f_TrayIconSingleClickCallBack, adopted from [Lexikos](https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954)
* HasVal, original from [jNizM](https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173)
* 
