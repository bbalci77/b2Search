use strict;
use warnings;

 my $FH;
# Read source file
open $FH,'b2SearchGui.plx' or die "Couldn't open file, : b2SearchGui.plx \n $!";

my @data = <$FH>;

close $FH;

#Get Version string from source file and update increment, date and time
my $major;
my $minor;
my $increment;

	foreach (@data)
	{
	#		if(/Version:((\d|\D)+)\"/)
			if(/Version:(\d{2}).(\d{2}).(\d{4})((\d|\D)+)\"/)
			{
				print "Found version $1 $2 $3\n";
				$major = $1;
				$minor = $2;
				$increment = $3 + 1;

				(my $sec, my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();

				my $versionString = sprintf("%02d.%02d.%04d.%02d%02d%02d.%02d%02d%02d",$major,$minor,$increment,$mday,$mon+1, $year-100,$hour,$min,$sec);
				print $versionString,"\n";


				if(s/Version:((\d|\D)+)\"/Version:$versionString\"/)
				{
					print "Updated version\n";
					print $_;
				}
			}
	}


	open  $FH, '>','b2SearchGui.plx' or die "Couldn't open file, : b2SearchGui.plx \n $!";
	print $FH @data;
	close $FH;







