# b2Search
Search inside folders and files

Windows Instructions:

1- Open cmd as Administrator
2- run install_bbSearch.bat in command prompt
3- Open c:/bbSearchCfg.txt and change <Editor> field as the location of your editor program
	Example: <Editor> C:\Program Files\IDM Computer Solutions\UltraEdit\uedit64.exe
	Save file.
4- Right click any folder and select bbSearch to start searching

Linux Instruction:
1- run the install script under linux setup directory
2- install perl-tk
3- install nautilus-actions
4- 


Tips:
Check Boxes:
CS : Case Sensitive Search
WW : Find Whole Word
Cm : Do not search inside c comments (Between /* and */ )
Fn : Find c function definition, ignore funciton calls and function declerations
Def: Find the string after #define

Select a search result with left click and righ click to highligh 20 lines of the file containing the searched strings
When in hihglight mode right click again  to the same selection to destroy highligh screen
When in hihglight mode to highlight different selection first left click to the new selection and right click

Double left clikc a search result to open the file containing the search result with Ultraedit, also jump to the line which the match occurs

Search button becomes Stop button when a search is started. You can stop the search by left clicking the stop button.

Multiple file masks can be given separated by ;
	Example .c;.h
	
