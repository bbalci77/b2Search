#!/usr/bin/env perl

#use strict;
#use warnings;
use Tk;
use Tk::Balloon;
use Tk::Dialog;
use Tk::ROText;
use Time::HiRes qw/ time /;
use Tk::BrowseEntry;

$window = MainWindow->new;
$window->title("b2Search");
$window->Label(-text => "Search Text Inside Files and Directories")->pack(-side => 'top');
$window->protocol(WM_DELETE_WINDOW => \&finito);




my $frameCheck = $window->Frame()->pack(-side=>'top', -fill=>'x');


# Read last window size and position from config file
$mwindowX = getSearchParam("<LastWindowX>");
$mwindowY = getSearchParam("<LastWindowY>");
$mwidth = getSearchParam("<LastWindowWidth>");
$mlength = getSearchParam("<LastWindowHeight>");

my $str = sprintf("%dx%d",$mwidth,$mlength);

# Set Main Window Size and Poistion
$window->geometry($str."+".$mwindowX."+".$mwindowY);

my $checkCaseSensitive = $frameCheck->Checkbutton(-text=>"Cs", -variable=>\$varCaseSensitive, -command => sub{  recordSearchParam("<DefaultCaseSensitive>",$varCaseSensitive); })->pack(-side=>'left');
my $balloonCS = $frameCheck->Balloon();
$balloonCS->attach($checkCaseSensitive, -balloonmsg => "Case Sensitive");
my $checkWholeWord = $frameCheck->Checkbutton(-text=>"WW", -font=>'helvetica 8 underline', -variable=>\$varWholeWord, -command => sub{  recordSearchParam("<DefaultWholeWord>",$varWholeWord);})->pack(-side=>'left');
my $balloonWW = $frameCheck->Balloon();
$balloonWW->attach($checkWholeWord, -balloonmsg => "Whole Word");
my $checkNoSearchComments = $frameCheck->Checkbutton(-text=>"Cm", -variable=>\$varNoSearchComment, -command => sub{ recordSearchParam("<DefaultDontSearchComment>",$varNoSearchComment);})->pack(-side=>'left');
my $balloonCm = $frameCheck->Balloon();
$balloonCm->attach($checkNoSearchComments, -balloonmsg => "Don't Search Inside Comments");
my $checkSearchFunction = $frameCheck->Checkbutton(-text=>"Fn", -variable=>\$varSearchFunction, -command => sub{ recordSearchParam("<DefaultFunctionSearch>", $varSearchFunction);})->pack(-side=>'left');
my $balloonFn = $frameCheck->Balloon();
$balloonFn->attach($checkSearchFunction, -balloonmsg => "Only Find Function Definitions");
my $checkSearchDefine = $frameCheck->Checkbutton(-text=>"Def", -variable=>\$varSearchDefine, -command => sub{ recordSearchParam("<DefaultDefineSearch>", $varSearchDefine);})->pack(-side=>'left');
my $balloonDf = $frameCheck->Balloon();
$balloonDf->attach($checkSearchDefine, -balloonmsg => "Only Find Defines");
my $checkSearchBinary = $frameCheck->Checkbutton(-text=>"Bin", -variable=>\$varSearchBinary, -command => sub{ recordSearchParam("<DefaultBinarySearch>", $varSearchBinary);})->pack(-side=>'left');
my $balloonBin = $frameCheck->Balloon();
$balloonBin->attach($checkSearchBinary, -balloonmsg => "Search Binary Files");

$frameCheck->Label(-text => "Version:00.01.0057.120418.134040")->pack(-side => 'right');

my $framePattern = $window->Frame()->pack(-side=>'top', -fill=>'x');
# String to search for inside files
$framePattern->Label(-text => "Search For")->pack(-side=>'left');
#$entPattern = $framePattern -> Entry(-width=>140, -background=>'white') -> pack(-side=>'left',-fill=>'both', -expand=>1);
$entPattern = $framePattern -> BrowseEntry(-width=>140,-background=>'white',
                      -browsecmd => sub {browseEntPattern($entPattern);}, -listwidth => 400, -listheight => 20,-listcmd => sub{populateEntPattern($historyFile,$entPattern);},
                      -variable => \$search_string)->pack(-side => 'left',-fill=>'both', -expand=>1, );
$entPattern->bind('<Key-Return>', \&but);
$entPattern->bind('<<Paste>>', sub {$entPattern->deleteSelected;});
$entPattern->bind('<Up>', sub {
	($globalHistorySelectionIndex, $globalLastHistoryPattern, $search_string) = UpArrowFnc($historyFile, $globalHistorySelectionIndex, $globalLastHistoryPattern);
	$entPattern->focus;
	$entPattern->selectionRange(0,'end');});
$entPattern->bind('<Down>', sub {
	($globalHistorySelectionIndex, $globalLastHistoryPattern, $search_string) = DownArrowFnc($historyFile, $globalHistorySelectionIndex, $globalLastHistoryPattern);
		$entPattern->focus;
	$entPattern->selectionRange(0,'end');});
$entPattern->bind('<Control-a>', sub {$entPattern->selectionRange(0,'end');});
$entPattern->bind('<Double-1>', sub{$entPattern->selectionRange(0,'end');});

my $frameMask = $window->Frame()->pack(-side=>'top', -fill=>'x');
# File mask, must be separated with ;
$frameMask->Label(-text => "File Mask  ")->pack(-side=>'left');
$entFileMask = $frameMask -> Entry(-width=>140, -background=>'white') -> pack(-side=>'left',-fill=>'both', -expand=>1);
#$entFileMask->insert(end, 'txt');
$entFileMask->bind('<Key-Return>', \&but);
$entFileMask->bind('<<Paste>>', sub {$entFileMask->deleteSelected;});
$entFileMask->bind('<Control-a>', sub {$entFileMask->selectionRange(0,'end');});


my $frameDirectory = $window->Frame()->pack(-side=>'top', -fill=>'x');
# Directory, search is done recursively starting from directory
$frameDirectory->Label(-text => "Directory   ")->pack(-side=>'left');
#$entDir = $frameDirectory -> Entry(-width=>140, -background=>'white') -> pack(-side=>'left',-fill=>'both', -expand=>1);
$entDir = $frameDirectory -> BrowseEntry(-width=>140,-background=>'white',
                      -browsecmd => sub {browseEntPattern($entDir);}, -listwidth => 400, -listheight => 20,-listcmd => sub{populateEntPattern($historyDirFile, $entDir);},
                      -variable => \$search_dir)->pack(-side => 'left',-fill=>'both', -expand=>1, );
$entDir->insert(end, @ARGV[0]);
$search_dir = @ARGV[0];
$entDir->bind('<Key-Return>', \&but);
$entDir->bind('<<Paste>>', sub {$entDir->deleteSelected;});
$entDir->bind('<Control-a>', sub {$entDir->selectionRange(0,'end');});
$entDir->bind('<Up>', sub {
	($globalDirHistorySelectionIndex, $globalLastHistoryDir, $search_dir) = UpArrowFnc($historyDirFile, $globalDirHistorySelectionIndex, $globalLastHistoryDir);
	$entDir->focus;
	$entDir->selectionRange(0,'end');});
$entDir->bind('<Down>', sub {
	($globalDirHistorySelectionIndex, $globalLastHistoryDir, $search_dir) = DownArrowFnc($historyDirFile, $globalDirHistorySelectionIndex, $globalLastHistoryDir);
	$entDir->focus;
	$entDir->selectionRange(0,'end');});
$entDir->bind('<Double-1>', sub{$entPattern->selectionRange(0,'end');});

$searchButton = $window->Button(-text => "Search", -command => \&but )->pack();



createHighlightWindow("Highlight", 1);
$window2->withdraw;
$window2->update;



$entInfo = $window -> Entry(-width=>140, -background=>'lightgray', -state=>'disabled')->pack(-fill=>'x', -expand=>1);

$lb = $window->Scrolled("ROText", -scrollbars => "osoe",
                      -width=>140, -height=>50, -background=>'white')->pack(-fill=>'both', -expand=>1);
$lb->bind('<Double-1>', \&leftDoubleClick);
$lb->bind('<1>', \&leftClickFnc);
$lb->bind('<3>', \&rightClickFnc);
$lb->menu(undef);

$lb->tagConfigure("header", -foreground => "blue");
$lb->tagConfigure("pattern", -foreground => "red");


# Set default states of the check buttons, read default states from configuration file

my $configValue;

$configValue = getSearchParam("<DefaultWholeWord>");
if (1 == $configValue)
{
	$checkWholeWord->select();
}


$configValue = getSearchParam("<DefaultDontSearchComment>");
if (1 == $configValue)
{
	$checkNoSearchComments->select();
}



$configValue = getSearchParam("<DefaultCaseSensitive>");
if (1 == $configValue)
{
	$checkCaseSensitive->select();
}


$configValue = getSearchParam("<DefaultFunctionSearch>");
if (1 == $configValue)
{
	$checkSearchFunction->select();
}


$configValue = getSearchParam("<DefaultDefineSearch>");
if (1 == $configValue)
{
	$checkSearchDefine->select();
}

$configValue = getSearchParam("<DefaultBinarySearch>");
if (1 == $configValue)
{
	$checkSearchBinary->select();
}

$configValue = getSearchParam("<LastSearchPattern>");
$entPattern->insert('end', $configValue);
$search_string = $configValue;


$configValue = getSearchParam("<LastSearchMask>");
$entFileMask->insert('end', $configValue);



if (@ARGV[0] eq '')
{
	$configValue = getSearchParam("<LastSearchLocation>");
	$entDir->insert('end', $configValue);
	$search_dir = $configValue;
}

# make the pattern entry selected, and select all the text
# to help the user start typing or pasting without the need to clear the entry
$entPattern->focus;
$entPattern->selectionRange(0,'end');

add_edit_popup($window, $entPattern);
add_edit_popup($window, $entFileMask);
add_edit_popup($window, $entDir);

MainLoop;


sub browseEntPattern
{
	my $obj = $_[0];
	$obj->selectionRange(0,'end');
}


sub populateEntPattern
{
	my $fileName = $_[0];
	my $obj = $_[1];
	my $lineCount = countLines($fileName);
	my $tempPattern;
	my $tempTime;
	my $historyCount = 0;
	my %searches = {};


	$selectorValue = $lineCount;
	$obj->delete(0,'end');


	while($historyCount < 20)
	{
		($tempPattern, $tempTime) = getPatternFromHistory($fileName, $selectorValue);

	  if (! exists $searches{$tempPattern})
	  {
	  	$obj->insert('end', $tempPattern);
	  	$historyCount++;
	  	$searches{$tempPattern}++;
	  }
  	$selectorValue--;
  	if ($selectorValue <0)
  	{
  		last;
  	}
  }
}

#
# Adds a right-click Edit popup menu to a widget.
#
sub add_edit_popup
{
  my ($mw, $obj) = @_;
  my $menu = $mw->Menu(-tearoff=>0, -menuitems=>[
    [qw/command Cut/, -command=>['clipboardCut', $obj,]],
    [qw/command Copy/, -command=>['clipboardCopy', $obj,]],
    [qw/command Paste/, -command=>['clipboardPaste', $obj]],
    '',
    [command=>'Select All', -command=>[
      sub { $_[0]->selectionRange(0, 'end'); }, $obj, ]],
    [command=>'Unselect All', -command=>[
      sub { $_[0]->selectionClear; }, $obj, ]],
  ]);
  $obj->menu($menu);
  $obj->bind('<3>', ['PostPopupMenu', Ev('X'), Ev('Y'), ]);
  return $obj;
}



# FUNCTION START : getSearchParam
# This routine reads the value of the given tag from the configuration file.
# Arguments:
# Arg1 : Tag name
# Returns: Tag Value
sub getSearchParam
{
	open my $FH,$configFile or die "Couldn't open file, : b2SearchCfg.txt \n $!";

	my @data = <$FH>;
	my $counter = 0;
	my $choic;

	foreach (@data)
	{
		if(/$_[0]((\w|\W)+)$/)
		{
			$choic = $1;
	 		#Remove newline character
	 		chomp $choic;
	 		#Remove spaces at the begining
	 		$choic =~ s/^\s*//;
	 		#Remove spaces at the end
			$choic =~ s/\s*$//;
			last;
		}
	}
close $FH;
return $choic;
}


# FUNCTION START : recordSearchParam
# This routine records the given value to the configuration file for the given tag
# Arguments:
# Arg1 : Tag name
# Arg2 : New value
# Returns: nothing.
sub recordSearchParam
{
	open my $FH,$configFile or die "Couldn't open file, : b2SearchCfg.txt \n $!";

	my @data = <$FH>;
	my $counter = 0;

	foreach (@data)
	{
		if (s/$_[0]\s*(\w|\W)*/$_[0] $_[1]\n/)
		{
			last;
		}

	}
close $FH;

open my $FH, '>',$configFile or die "Couldn't open file, : b2SearchCfg.txt \n $!";
print $FH @data;
close $FH;
}



# FUNCTION START : leftClickFnc
# This routine is the left click callback function of the search
# Arguments: NA
# Returns: nothing.
#
sub leftClickFnc
{
	$lb->focus;
	$lb->selectLine();
}

sub leftDoubleClick {

	my ($line, $col) = split(/\./,$lb->index('insert'));

	$line = $line -1;
	$lb->selectLine();
	my @args;

	if ($^O eq 'linux')
	{
		# No blank between : and lineNo for subl text editor
		if ($prog eq "/usr/bin/subl")
		{
			@args = ("$prog @globalFileName[$line]$commandSep@globalLineNo[$line] $additionalCommand");
		}
		else
		{
			@args = ("$prog @globalFileName[$line] $commandSep@globalLineNo[$line] $additionalCommand");
		}

	}
	else
	{
		if ($^O eq 'MSWin32')
		{
			@args = ($prog,  "@globalFileName[$line] $commandSep@globalLineNo[$line] $additionalCommand");
		}
	}

	if (-f $prog)   # does it exist?
	{
		system(@args);
	}
	else
	{
		print "$prog doesn't exist.";
	}
}


# FUNCTION START : colorWord
# This routine searches the text box of the highlight window and
# colors all found pattern words to the given color
# Arguments:
# Arg1 : Color, the color to be used in the highlight process
# Arg2 : the string to search inside text
# Returns: nothing.
sub colorWord
{

	my $color = $_[0];
	my $string = $_[1];

 $entry->tagConfigure( $string, -foreground => $color, -font =>
[-family => 'Arial Unicode MS', -size => '8', -weight => 'bold']);

  my $current = '1.0';
  my $length = 0;
  my $current_last;
  my $length_last;


  while (1)
  {
    $current = $entry->search(-count => \$length, "-exact",'-nocase', $string, $current, 'end' );
    last if not $current;
    #warn "Posn=$current count=$length\n",
    $entry->see($current);
    $entry->tagAdd( "patternHL", $current, "$current + $length char" );
    $current = $entry->index("$current + $length char");
  }
}


# FUNCTION START : highlightFile
# This routine opens the given file, displays the matched line and following and preceding
# 20 lines. Also the matched string and the matched line is highlighted in different color.
# Arguments:
# Arg1 : Filename
# Arg2 : Line number of the match
# Returns: nothing.
sub highlightFile
{
	my $fileName = $_[0];
	my $lineNo = $_[1];
	my $totalLinesToDisplay;
	$totalLinesToDisplay = 100;

	open FH, $fileName or die "Couldn't open file, : $fileName \n $!";

	my $startLine;

	if ($lineNo < ($totalLinesToDisplay + 1))
	{
		 $startLine = 1;
	}
	else
	{
		$startLine = $lineNo - $totalLinesToDisplay;
	}

	my $tempLineNo;
	$tempLineNo = 1;
	my $markedLine;
	while (<FH>)
	{
		if( ($startLine <= $tempLineNo) && (($lineNo + $totalLinesToDisplay) >= $tempLineNo))
		{
			if ($lineNo == $tempLineNo)
			{
				$entry->insert('end', $tempLineNo. ' '. $_ ,"patternLine");
				$markedLine = $tempLineNo;

			}
			else
			{
				$entry->insert('end', $tempLineNo. ' '. $_);
			}
		}
		$tempLineNo++;
	}
	close FH;

	if ($searchString)
	{
		colorWord("red",$searchString);
	}

	# TODO: find the correct amount th shift the page in order to always see the selected line
	$entry->yviewScroll(($markedLine - $tempLineNo/2), units);
}


# FUNCTION START : createHighlightWindow
# This routine makes a recursive search starting from the given path.
# All files are searched for the pattern and all sub folders are expanded
# and the files inside the subfolders are searched recursively.
# Arguments:
# Arg1 : Filename : Written as title on the highlight window
# Arg2 : blCreate, if 1 window is created, if 0 existing window is made visible
# Returns: nothing.
sub createHighlightWindow
{
	my $fileName = $_[0];
	my $blCreate = $_[1];

	$window->update;
	my $windowX = $window->x + $window->width + 5;
	my $windowY  = $window->y;



	if ($blCreate)
		{
			$window2 = MainWindow->new();
			$window2->protocol(WM_DELETE_WINDOW => sub
			{
				$selectedItem = -1;
			  if (Exists($entry))
			  {
					$entry->destroy;
				}

				if (Exists($window2))
				{
					$window2->destroy;
				}

				$selectedItem = -1;
			});
			$entry = $window2->Text(-width => $window->width, -height => $window->height, -background=>'white')->pack;

			$entry->tagConfigure("patternHL", -foreground => "red");
			$entry->tagConfigure("patternLine", -background => "yellow");
		}
		my $str = sprintf("%dx%d",$window->width,$window->height);
		$window2->geometry($str."+".$windowX."+".$windowY);
		$window2->title("Highlight $fileName");
		$window2->update;
}


# FUNCTION START : rightClick
# Search Results Textbox right click callback
# Arguments: NA
#
sub rightClickFnc {

	$lb->unselectAll();
	$lb->adjustSelect();
	$lb->selectLine();

	my ($line, $col) = split(/\./,$lb->index('insert'));
	$line = $line - 1;


	# if no highligh window is created
	if (-1 == $selectedItem)
	{
	#	print "making entry visible\n";
	if (Exists($window2))
	{
		$window2->deiconify();
		$window2->raise();
		$window2->update();
		createHighlightWindow(@globalFileName[$line], 0);
	}
	else
	{
		createHighlightWindow(@globalFileName[$line], 1);
	}

	highlightFile(@globalFileName[$line], @globalLineNo[$line]);
	}

# if there is already a highlight window and the selected one is different from the existing d
# delete it and create another
if($line != $selectedItem)
{
	$selectedItem =$line;
	$entry->delete('1.0','end');
	createHighlightWindow(@globalFileName[$line], 0);
 	highlightFile(@globalFileName[$line], @globalLineNo[$line]);
}
else
{
#	print "same selected delete it\n";

	$window2->withdraw;
	$window2->raise;

	$selectedItem = -1;
}
}

# FUNCTION START : leftArrrowFnc
# History callback for Pattern Entry text box widget
# Arguments : Arg1: File name
#             Arg2: Line no
# Returns: Pattern from history
sub getPatternFromHistory
{
	my $fileName = $_[0];
	my $lineNo = $_[1];
	my $patternExtracted;
	my $timeExtracted;

	open(FILE, $fileName) or die "Could not open file: $!";


	my $templine = 1;

	while (<FILE>)
	{

    	if ($templine == $lineNo)
    	{
    	#	if($_ =~ m/\s*(<((\w|\d)*)>)/)
    	#	if($_ =~ /\s*(<pattern \s*((\w|\d)*)>)/)
    	    if(/^(s*((\w|\W)*))\s+timeTag/)
    		{
    			$patternExtracted =  $1;

    		#	$patternExtracted = $2;

    		}
    		if(/timeTag:\s*((\w|\W)*)/)
    		{
    		#	$patternExtracted = $2;
    			$timeExtracted = $1;

    		}
    		break;
    	}
    	$templine++;
    }
    close FILE;
    return ($patternExtracted, $timeExtracted);
}

# FUNCTION START : DownArrrowFnc
# History callback for Pattern Entry text box widget
# Arguments : NA
sub DownArrowFnc
{
	my $maxHistorySelectorValue;
	my $fileName = $_[0];
	my $historySelectionIndex = $_[1];
	my $lastHistoryPattern = $_[2];
	$maxHistorySelectorValue = countLines($fileName);
	my $loopCount = 0;
	my ($tempPattern, $tempTime);

		# loop until a different pattern from history is found
	while(1)
	{
		$loopCount = $loopCount + 1;

		# if the selector already shows the first entry, do not decrease it, go to the end
		if (1 == $historySelectionIndex)
		{
			$historySelectionIndex = countLines($historyFile);

		}
		else
		{
			$historySelectionIndex--;
		}

		($tempPattern, $tempTime) = getPatternFromHistory($fileName, $historySelectionIndex);


		if ($tempPattern ne $lastHistoryPattern)
		{
			last;
		}
		# else getting the same pattern from the history is useless

		# if all history is the same, break until one full search
		if ($loopCount >= $maxHistorySelectorValue)
		{
			last;
		}
	}


	$lastHistoryPattern = $tempPattern;

	my $balloon1 = $window->Balloon();
	$balloon1->attach($entPattern, -balloonmsg => "Time: $tempTime");

	return($historySelectionIndex, $lastHistoryPattern, $tempPattern);
}

# FUNCTION START : UpArrrowFnc
# History callback for Pattern Entry text box widget
# Arguments : NA
sub UpArrowFnc
{
	my $maxHistorySelectorValue;
	my $fileName = $_[0];
	my $historySelectionIndex = $_[1];
	my $lastHistoryPattern = $_[2];

	$maxHistorySelectorValue = countLines($fileName);
	my $loopCount = 0;
	my ($tempPattern, $tempTime);

	# loop until a different pattern from history is found
	while(1)
	{
		$loopCount = $loopCount + 1;
		# if the selector already shows the last entry, do not go further, go to the beginning ??
		if ($maxHistorySelectorValue <= $historySelectionIndex)
		{
			$historySelectionIndex = 1;
		}
		else
		{
			$historySelectionIndex++;
		}

		($tempPattern, $tempTime) = getPatternFromHistory($fileName,$historySelectionIndex);


		if ($tempPattern ne $lastHistoryPattern)
		{
			last;
		}
		# else getting the same pattern from the history is useless

		# if all history is the same, break until one full search
		if ($loopCount >= $maxHistorySelectorValue)
		{
			last;
		}
	}
;
	$lastHistoryPattern = $tempPattern;

	my $balloon1 = $window->Balloon();
	$balloon1->attach($entPattern, -balloonmsg => "Time: $tempTime");


	return($historySelectionIndex, $lastHistoryPattern, $tempPattern);
}

# FUNCTION START : record last searched item to the history file
# This function records the last searched pattern to the history file.
# Arguments : Arg1 : pattern
sub recordHistory
{
	my $patternToRecord = $_[0];
	my $historyDepth;
	my $fileName = $_[1];

	open my $FH, '>>',$fileName or die "Couldn't open file, : $fileName \n $!";

	$historyDepth = countLines($fileName);
	if (0 != $historyDepth)
	{
		print $FH "\n";
	}

	print $FH $patternToRecord;
	(my $sec, my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
	my $timeTagString = sprintf(" timeTag:D:%02d-%02d-%02d.H:%02d:%02d:%02d", $mday,$mon+1,$year+1900,$hour,$min,$sec);
	print $FH $timeTagString;
	close $FH;
}


# FUNCTION START : but
# Search button callback
# Arguments: NA
sub but {
	my $directoryName = $search_dir;
	my $pattern = $search_string;
	my $fileMask = $entFileMask->get();

	push @globalSearchHistory, $pattern;

	my $start = time;

	if ($searchInProgress)
	{
		$stopRequested = 1;
		return;
	}

	$searchInProgress = 1;

	recordHistory($pattern, $historyFile);
	recordHistory($directoryName, $historyDirFile);


	$entInfo->configure(-state=>'normal');

	$totalSearchedFiles = 0;
	$matchedFiles = 0;
	$totalMatches = 0;


	$lb->delete('0.0', 'end');
	$lb->focus;
	@globalFileName = ();
	@globalLineNo = ();
	$searchButton->configure(-background=>'red',-text => "Stop");
	process_files($directoryName, quotemeta($pattern), $fileMask);
	$searchButton->configure(-background=>'green',-text => "Search");
	$entInfo->configure(-state=>'disabled');
	$searchInProgress = 0;
	$stopRequested = 0;
	recordSearchParam("<LastSearchPattern>", $pattern);
	recordSearchParam("<LastSearchMask>", $fileMask);
	recordSearchParam("<LastSearchLocation>", $directoryName);

	my $duration = sprintf("%.3f",time - $start);
	print "Execution time: $duration s\n";

	$lb -> insert('end', "    Searched $totalSearchedFiles file(s), found $totalMatches occurrenc(es) in $matchedFiles file(s) in $duration seconds\n","header");

	push @globalFileName, $configFile;
	push @globalLineNo, 1;


	# Record  last window size and position
	recordSearchParam("<LastWindowX>", $window->x);
	recordSearchParam("<LastWindowWidth>", $window->width);
	recordSearchParam("<LastWindowY>", $window->y);
	recordSearchParam("<LastWindowHeight>", $window->height);



	# rest the  history selection to the top of the queue
	$globalHistorySelectionIndex = countLines($historyFile) + 1;
	$globalDirHistorySelectionIndex = countLines($historyDirFile) + 1;
}


# FUNCTION START : finito
# This is called when the window is closed
# Arguments: NA
#
sub finito{

	$stopRequested = 1;

	sleep(0.1);

  if (Exists($entry))
  {
		$entry->destroy;
	}

	if (Exists($window2))
	{
		$window2->destroy;
	}



	# Record  last window size and position
	recordSearchParam("<LastWindowX>", $window->x);
	recordSearchParam("<LastWindowWidth>", $window->width);
	recordSearchParam("<LastWindowY>", $window->y);
	recordSearchParam("<LastWindowHeight>", $window->height);

	exit;
}


# FUNCTION START : countLines
# This function returns the number of lines in a file
# Arguments : Arg1 : fileName
sub countLines
{
	my $fileName = $_[0];
	open(FILE, $fileName) or die "Could not open file: $!";

	my $lines = 0;

	while (<FILE>)
	{
    	$lines++;
    }
    close FILE;
    return $lines;
}

# FUNCTION START : clearFile
# Delete first n lines of file
# Arguments: Arg1: number of lines to be deleted
#
sub clearFile
{
	my $linesToDelete = $_[0];
	my @linesToReWrite;
	my $templineNo = 0;
	my $fileName = $_[1];

	open IN, '<', $fileName or die "Couldn't open file, : $fileName\n $!";

	# Get rid of first $linesToDelete lines in this loop
	while (<IN>)
	{
		$templineNo = $templineNo + 1;

		if ($templineNo >= $linesToDelete)
		{
			push (@linesToReWrite, $_);
		}
    }


	close IN;

	open OUT, '>', $fileName or die "Couldn't open file, : $fileName\n $!";

	# Print only the last TotalLines - $linesToDelete lines to the same file
	foreach  (@linesToReWrite)
	{
		print  OUT $_;
	}
	close OUT;


}

# FUNCTION START : BEGIN
# Entry point
# Arguments: NA
#
sub BEGIN {
$selectedItem = -1;
@globalArrayFileName = ();
@globalArrayLinoNo = ();
$globalHistorySelectionIndex;
$globalDirHistorySelectionIndex;


$globalLastHistoryPattern = "dummyText";
$globalLastHistoryDir = "dummyText";

$globalTime = time;

$searchInProgress = 0;
$stopRequested = 0;
$prog;
$commandSep;
$additionalCommand;
$configFile;
$historyFile;
$historyDirFile;

if ($^O eq 'MSWin32')
{
	$configFile = 'C:\b2Search\b2SearchCfg.txt';
	$historyFile = 'C:\b2Search\b2SearchHistory.txt';
	$historyDirFile = 'C:\b2Search\b2SearchDirHistory.txt';
}
else
{
	if ($^O eq 'linux')
	{
		$configFile = '/etc/b2Search/b2SearchCfg.txt';
		$historyFile = '/etc/b2Search/b2SearchHistory.txt';
		$historyDirFile = '/etc/b2Search/b2SearchDirHistory.txt';
	}
}


$globalHistorySelectionIndex = countLines($historyFile) + 1;
$globalDirHistorySelectionIndex = countLines($historyDirFile) + 1;

	$prog = getSearchParam("<Editor>");

	# clear first 2000 history entries if total entry count is more than 4000
	if ($globalHistorySelectionIndex > 4000)
	{
		clearFile(2000, $historyFile);
	}

	# clear first 2000 history entries if total entry count is more than 4000
	if ($globalDirHistorySelectionIndex > 4000)
	{
		clearFile(2000, $historyDirFile);
	}

	# Read line separator command


	$commandSep = getSearchParam("<CommandSep>");

		# Read extra command
	$additionalCommand = getSearchParam("<AdditionalCommand>");



	$prog =~ s/^\s*//;
	$prog =~ s/\s*$//;
	print "$prog \n";
	print "$commandSep \n";
	print "$additionalCommand \n";

	$totalSearchedFiles = 0;
	$matchedFiles = 0;
	$totalMatches = 0;

	print "Operation system $^O \n";

}

# FUNCTION START : process_files
# This routine makes a recursive search starting from the given path.
# All files are searched for the pattern and all sub folders are expanded
# and the files inside the subfolders are searched recursively.
# Arguments:
# Arg1 : the full path to a directory.
# Arg2 : the string to search inside files
# Arg3 : the string for filemask .txt, .c, .h for example
# Returns: nothing.
sub process_files
{
  my $path = $_[0];
	my $pattern =  $_[1];
#	my @searchResult;
	my $fileMask = $_[2];

	# do not process hidden files in Linux
	if ($path =~ /^\./)
	{
		return;
	}

	opendir DH, $path or die "Couldn't open the current directory: $path $! \n";

	my $fileCount = 0;

	# delete . and ..
	my @files = grep { !/^\.{1,2}$/ } readdir (DH);

#	print "\n\n", grep { /(\.txt)$/ } @files, "\n\n";

	#print @files;
	# Close the directory.
	closedir (DH);

	# At this point you will have a list of filenames
    #  without full paths ('filename' rather than
    #  '/home/count0/filename', for example)
    # You will probably have a much easier time if you make
    #  sure all of these files include the full path,
    #  so here we will use map() to tack it on.
    #  (note that this could also be chained with the grep
    #   mentioned above, during the readdir() ).


  if ($^O eq 'MSWin32')
	{
		 @files = map { $path . '\\' . $_ } @files;
	}
	else
	{
		if ($^O eq 'linux')
		{
			 @files = map { $path . '/' . $_ } @files;
		}
	}


  for (@files)
	{
		if ($stopRequested)
		{
			return;
		}

    # If the file is a directory
    if (-d $_)
		{
				# if link to folder do not try to enter it just skip
				if (-l $_)
				{
					next;
				}
            # Here is where we recurse.
            # This makes a new call to process_files()
            # using a new directory we just found.
        #   push @searchResult, process_files ($_, $pattern, $fileMask);
        process_files ($_, $pattern, $fileMask);
        # If it isn't a directory, lets just do some
        # processing on it.
    }
		else
		{
			# if link to file do not try to process it just skip
			if (-l $_)
			{
				next;
			}

			# if special character file do not try to process it just skip
			if (-c $_)
			{
				next;
			}

			# if no file mask is selected
			if ($fileMask eq '')
			{
				if (-B $_)
				{
					if ($varSearchBinary)
					{
						process_A_Binary_file($_, $pattern);
					}
					else
					{
						next;
					}
				}
				else
				{
					process_A_file($_, $pattern);
				}
			}
			else # search with file mask
			{
			# process file mask in case it contains more than one mask type
				@masks = split /;/, $fileMask;

				foreach my $mask (@masks)
				{
					# get . character as it is, (all escape characters as well)
					my $qMask = quotemeta($mask);
					if  (/($qMask)$/)
					{
						if (-B $_)
						{
							process_A_Binary_file($_, $pattern);
						}
						else
						{
							process_A_file($_, $pattern);
						}
					}
				}
			}
    }
  }
#	return @searchResult;
 }

# FUNCTION START : colorPattern2
# This routine colors the word between the given character offsets to red
# Arguments:
# Arg1 : lineCount to be written to the textbox, used to determine to find the length of pre-string
# Arg2 : Start index of the pattern in the line in file
# Arg3 : End index of the pattern in the line in file
# Returns: nothing.
 sub colorPattern2
 {
 		my $lineCount = $_[0];
		my $startIndex = $_[1];
		my $endIndex = $_[2];

		# Get the line number to be processed
		my $lengthArray = @globalLineNo;
		my $current = sprintf("%d.0",$lengthArray);

		# Get the length of pre-string
		my $lengthLineCountMsg = length("    Line  : $lineCount ");
		# The search is done without pre-string so add the pre-string length to the found offsets
		my $startOffset =  $lengthLineCountMsg +  $startIndex;
		my $endOffset =  $lengthLineCountMsg +  $endIndex;
		# Convert the offsets to text index format i.e 12.0 for example for line no 12
		my $tagStart = $lb->index("$current + $startOffset char");
		my $tagEnd = $lb->index("$current + $endOffset char");
		# Add tag
		$lb->tagAdd("pattern", $tagStart, $tagEnd);
 }

# FUNCTION START : addFileName
# This routine is called after a match and adds the file name to the search results
# Arguments:
# Arg1 : File name containing the matched string
# Arg2 : Line number of the match insided the file
# Returns: nothing.
 sub addFileName
 {
 		my $fileName = $_[0];
 		my $lineCount= $_[1];

		push @globalFileName, $fileName;
		push @globalLineNo, $lineCount;
		$lb -> insert('end', "$fileName\n","header\n");
		# Increment total number of files containing a match
		$matchedFiles += 1;
 }

# FUNCTION START : addSearchResult
# This routine is called after a match and adds the line containing the match to the search result
# Also the line is added to the text box and the matched pattern is colored with red
# Arguments:
# Arg1 : File name containing the matched string
# Arg2 : Line number of the match insided the file
# Arg3 : Start index of the pattern in the line in file
# Arg4 : End index of the pattern in the line in file
# Arg5 : Matching line content
# Returns: nothing.
 sub addSearchResult
 {
 	 	my $fileName = $_[0];
 		my $lineCount= $_[1];
 		my $startIndex = $_[2];
 		my $endIndex = $_[3];
 		my $matchedLine = $_[4];
 		my $searchTypeBinary = $_[5];

		push @globalFileName, $fileName;
		push @globalLineNo, $lineCount;


		# clear all newlines inside the string as the newlines destroy the synchronization of the Results text box
		$matchedLine =~ s/\n//g;

	# clear all null(Hex 00) charachters inside the string as they destroy the synchronization of the Results text box
		$matchedLine =~ s/\0/ /g;

		if (1 == $searchTypeBinary)
		{
			my $hexString = sprintf("0x%x",$lineCount);
			$lb -> insert('end', 	"  Offset : $hexString $matchedLine");
		}
		else
		{
			$lb -> insert('end', 	"    Line  : $lineCount $matchedLine");
		}


		# check for endofline, if no end of line detected put manually
		if (!($matchedLine =~ /\n$/))
		{
			$lb -> insert('end',"\n");
		}

		$totalMatches += 1;

		colorPattern2($lineCount, $startIndex, $endIndex);
 }

# FUNCTION START : process_A_file
# This routine searches the given pattern inside the given file using regExps.
# Arguments:
# Arg1 : the full path to file.
# Arg2 : the string to search inside files
# Returns: nothing.
sub process_A_file
{
	my $fileName = $_[0];
	my $pattern = $_[1];
	my $commentStarted = 0;
	my $funcStarted = 0;
	my $firstMatchInThisFile = 1;
	my $matchCountInThisFile = 0;

	#if file can not be opend just return instead of throwing exception in order to keep searching for other files
	open FH, $fileName or return;


	$totalSearchedFiles += 1;

	my $lineCount;
	$lineCount = 0;


#   takes too much time commented out
#	$entInfo->update;

	my $tempTime = time;


	if ((($tempTime - $globalTime)*1000) >= 100)
	{
		$globalTime = $tempTime;
		$entInfo->delete(0,end);
		$entInfo->insert(0, $fileName);
		$entInfo->update;
#		$lb->update();
	}

	# data
	my $newPattern;

	if ($varWholeWord)
	{
		$newPattern = '\b'.$pattern.'\b';
	}
	else
	{
		$newPattern = $pattern;
	}

	my $tempFuncStartLineNo = 0;
	my $tempFuncStartLine;
	my $tempStartIndex;
	my $tempEndIndex;

	while (<FH>)
	{
		$lineCount += 1;
#   takes too much time commented out
#		$lb->update;

		if ($varNoSearchComment)
		{
			# remove single line comments
			s/(\/\*((\d|\D)*)\*\/)//g;

			if ($commentStarted)
			{
				#check for end of comment
				if (/\*\//)
				{
			#		print "End of comment found line $lineCount\n";
					$commentStarted = 0;
					s/^(\d|\D)*\*\///;
			#		print "$_\n";
				}
				else
				{
					# this line is a comment
					next;
				}
			}
			else
			{
				#check for start comment
		#		print "$lineCount $_\n";
				if (/\/\*/)
				{
		#		print "Start comment found, line $lineCount\n";
					s/\/\*(\d|\D)*$/\n/;
		#			print "$_\n";
					$commentStarted = 1;
				}
			}
		}

		if ($varSearchFunction)
		{
			if ($funcStarted)
			{
				if(/;(\d|\D)*$/)
				{
					  $funcStarted = 0;
						next;
				}
				else
				{
					if(/\s*\{/)
					{
						$funcStarted = 0;
			#			print "Multiline func found $lineCount started $tempFuncStartLineNo\n";
						if ($firstMatchInThisFile)
						{
							addFileName($fileName, $tempFuncStartLineNo);
							$firstMatchInThisFile = 0;
						}
						addSearchResult($fileName, $tempFuncStartLineNo, $tempStartIndex, $tempEndIndex, $tempFuncStartLine, 0);
						$matchCountInThisFile += 1;
						next;
					}
					else
					{
						next;
					}
				}
			}
		}


		if ($varCaseSensitive)
		{
			if(/$newPattern/)
			{
				if ($varSearchFunction)
				{
					# Funciton call found myFunc(...);
					if (/$newPattern\s*\((\w|\W)*\)\s*;/)
					{
				#		print "Func CALL found $lineCount\n";
					}
					else
					{
						# single line function found void myFunc(void){
						if (/$newPattern\s*\((\w|\W)*\)\s*\{/)
						{
							if ($firstMatchInThisFile)
							{
								addFileName($fileName, $lineCount);
								$firstMatchInThisFile = 0;
							}
							addSearchResult($fileName, $tempFuncStartLineNo, @-[0], @+[0], $lineCount, 0);
							$matchCountInThisFile += 1;
						}
						else
						{
							if (/(^(\s*\#))|(^(\s*if))|(^(\s*for))|(^(\s*while))/)
							{
								#	print "Define for if or while started\n";
							}
							else
							{
								# function started
								$funcStarted = 1;
								$tempFuncStartLineNo = $lineCount;
								$tempFuncStartLine = $_;
								$tempStartIndex = @-[0];
								$tempEndIndex = @+[0];
							}
						}
					}

				}
				else
				{
					if ($varSearchDefine)
					{
							if(/\s*\#\s*define\s+$newPattern/)
							{
								if ($firstMatchInThisFile)
								{
									addFileName($fileName, $lineCount);
									$firstMatchInThisFile = 0;

								}
								addSearchResult($fileName, $lineCount, @-[0], @+[0], $_, 0);
								$matchCountInThisFile += 1;
							}
					}
					else
					{
						# Search for word push it immediately
						if ($firstMatchInThisFile)
						{
							addFileName($fileName, $lineCount);
							$firstMatchInThisFile = 0;
						}
						addSearchResult($fileName, $lineCount, @-[0], @+[0], $_, 0);
						$matchCountInThisFile += 1;
					}
				}
			}
		}
		else # Search with NO CASE
		{
			if(/$newPattern/i)
			{
				if ($varSearchFunction)
				{
					# Funciton call found myFunc(...);
					if (/$newPattern\s*\((\w|\W)*\)\s*;/i)
					{
				#		print "Func CALL found $lineCount\n";
					}
					else
					{
						# single line function found void myFunc(void){
						if (/$newPattern\s*\((\w|\W)*\)\s*\{/i)
						{
							if ($firstMatchInThisFile)
							{
								addFileName($fileName, $lineCount);
								$firstMatchInThisFile = 0;
							}
							addSearchResult($fileName, $lineCount, @-[0], @+[0], $_, 0);
							$matchCountInThisFile += 1;
						}
						else
						{
							if (/(^(\s*\#))|(^(\s*if))|(^(\s*for))|(^(\s*while))/)
							{
								#	print "Define for if or while started\n";
							}
							else
							{
								# function started
								$funcStarted = 1;
								$tempFuncStartLineNo = $lineCount;
								$tempFuncStartLine = $_;
								$tempStartIndex = @-[0];
								$tempEndIndex = @+[0];
							}
						}
					}
				}
				else
				{
					if ($varSearchDefine)
					{
							if(/\s*\#\s*define\s+$newPattern/i)
							{
								if ($firstMatchInThisFile)
								{
									addFileName($fileName, $lineCount);
									$firstMatchInThisFile = 0;
								}
								addSearchResult($fileName, $lineCount, @-[0], @+[0], $_, 0);
								$matchCountInThisFile += 1;
							}
					}
					else
					{
					  # Search for word push it immediately
					  # Get file name only once, in case of multiple matches for the current file
						if ($firstMatchInThisFile)
						{
							addFileName($fileName, $lineCount);
							$firstMatchInThisFile = 0;
						}
						addSearchResult($fileName, $lineCount, @-[0], @+[0], $_, 0);
						$matchCountInThisFile += 1;
					}
				}
			}
		}
	}
	close FH;
}


# FUNCTION START : process_A_Binary_file
# This routine searches the given pattern inside the given file using regExps.
# Arguments:
# Arg1 : the full path to file.
# Arg2 : the string to search inside files
# Returns: nothing.
sub process_A_Binary_file
{
	my $fileName = $_[0];
	my $pattern = $_[1];
	my $commentStarted = 0;
	my $funcStarted = 0;
	my $firstMatchInThisFile = 1;
	my $matchCountInThisFile = 0;
	my $blockLength = 64;


	#if file can not be opend just return instead of throwing exception in order to keep searching for other files
	open FH, '<:raw', $fileName or return;

	my $o = 0;
	my $buffer;
	my $size = -s $fileName;
	my $searchStringLength = length($pattern);
	my $shiftLength = $searchStringLength - 1;


	# Read into the buffer after any residual copied from the last chunk
	while (my $read = read FH, $buffer, $blockLength)
	{
		$lineCount += 1;
		my $curPos = tell(FH);

		if ($varCaseSensitive)
		{
			while ($buffer =~ m[$pattern]gc)
			{
					# if a match occurs for the first time for this file first print the file name
					if ($firstMatchInThisFile)
					{
						addFileName($fileName, $-[0] + $o);
						$firstMatchInThisFile = 0;
					}
					addSearchResult($fileName, $-[0] + $o, $-[0], $+[0], $buffer, 1);
					$matchCountInThisFile += 1;
			}
		}
		else #search without case sensitivity detection
		{
			while ($buffer =~ m[$pattern]gci)
			{
					if ($firstMatchInThisFile)
					{
						addFileName($fileName, $-[0] + $o);
						$firstMatchInThisFile = 0;
					}
					addSearchResult($fileName, $-[0] + $o, $-[0], $+[0], $buffer, 1);
			}

		}

		$o += $read;

		if ($curPos +  $blockLength < $size )
		{
			# shift the search windows behind in order to catch the matches that are between the boudary of consecutive blocks
			seek(FH,-$shiftLength, 1);
			$o -= $shiftLength;
		}
	}

	close FH;
}