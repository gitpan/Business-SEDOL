#!/usr/bin/perl -w

use strict;
use Test;
use Business::SEDOL;

BEGIN { plan tests => 21 }

# Check some really bad SEDOLS
for (qw/O123457 012.453 010T000 2!71001 30201e5 4-68631 548g182/) {
  my $sdl = Business::SEDOL->new($_);
  ok(!defined($sdl->check_digit()));
  ok($Business::SEDOL::ERROR, qr/^Invalid char/,
     "  Did not get the expected error. Got $Business::SEDOL::ERROR\n");
  ok($sdl->error, qr/^SEDOLs must contain only/,
     "  Did not get the expected error. Got ".$sdl->error);
}

__END__
