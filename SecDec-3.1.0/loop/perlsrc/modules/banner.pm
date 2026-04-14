#****
#  NAME
#  banner.pm
#
#  USAGE
#  use banner
#
#  USES
#  N/A
#
#  USED BY
#  makeFU.pl
#
#  PURPOSE
#  prints various banners (such as the SecDec version and author list)
#
#  SEE ALSO
#  N/A
#
#****
package banner;

sub printversion {
    print "\n";
print "**************** This is SecDec version 3.1.0 ****************\n";
print "Authors: Sophia Borowka, Gudrun Heinrich, Stephen Jones, \n";
print "         Matthias Kerner, Johannes Schlenk, Tom Zirke\n";
print "**************************************************************\n";
}

1;
