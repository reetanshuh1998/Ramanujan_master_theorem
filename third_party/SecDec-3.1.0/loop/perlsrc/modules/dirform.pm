  #****
  #  NAME
  #    dirform.pm
  #
  #  USAGE
  #  is called by other perl scripts
  #
  #  PURPOSE
  #  contains subroutines which are used to format strings into valid
  #  directory syntax
  #   
  #****
  #
use strict;
use warnings;

package dirform;

# bring directory strings into (depreciated) canonical form
sub norm {
    my $dir=$_[0];
    $dir=~s/\/\//\//g; # search for "//" and replace with "/"
    $dir=~s/\/$//; # strip trailing "/"
    return $dir
}

# prepare directory strings for use in regex experssions
sub regex {
    my $dir=$_[0];
    $dir=norm($dir);
    $dir=join('\\/', split(/\//, $dir)); # replace "/" with "\/"
    return $dir
}

# if not present add trailing "/"
sub add_trailing_slash {
    my $dir=$_[0];
    $dir = substr($dir, -1 , 1) eq "/" ? $dir : $dir . "/";
    return $dir;
}

# if present strip leading "/"
sub strip_leading_slash {
    my $dir=$_[0];
    $dir = substr($dir, 0, 1) eq "/" ? substr($dir,1) : $dir;
    return $dir;
}

# if present strip trailing "/"
sub strip_trailing_slash {
    my $dir=$_[0];
    $dir = substr($dir, -1 , 1) eq "/" ? substr($dir,0,-1) : $dir;
    return $dir;
}

# strip all spaces from a string
sub strip_spaces {
    my $str=$_[0];
    $str=~s/\s+//g;
    return $str;
}

# strip leading and trailing spaces from a string
sub trim {
    my $str=$_[0];
    $str =~ s/^\s+|\s+$//g;
    return $str;
}

1;
