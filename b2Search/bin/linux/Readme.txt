1- Open cmd as Administrator
2- run install_bbSearch.bat in command prompt
3- Open c:/bbSearchCfg.txt and
			change <Editor> field as the location of your ultraedit exe
				Example: <Editor> C:\Program Files\IDM Computer Solutions\UltraEdit\uedit64.exe
			change separator field
				/ for ultraedit,  -n for notepadd++, + for gedit, -- --lc for ultraedit linux, :(fileNAme:lineNo without blank between : and lineNo)
	Save file.
4- Right click any folder and select bbSearch to start searching



Tips:
Check Boxes:
CS : Case Sensitive Search
WW : Find Whole Word
Cm : Do not search inside c comments (Between /* and */ )
Fn : Find c function definition, ignore funciton calls and function declerations
Def: Find the string after #define
Bin: Search inside binary files

Right click on a search result to highlight 20 lines of the file containing the searched strings
	When in hihglight mode right click again  to the same selection to destroy highlight screen
	When in hihglight mode to highlight different selection right click on another search result

Double left click a search result to open the file containing the search result with Selected Editor program, also jump to the line which the match occurs

Search button becomes Stop button when a search is started. You can stop the search by left clicking the stop button.

Multiple file masks can be given separated by ;
	Example .c;.h