package Business::SEDOL;

=pod

=head1 NAME

Business::SEDOL - Verify Stock Exchange Daily Official List Numbers

=head1 SYNOPSIS

  use Business::SEDOL;
  $sdl = Business::SEDOL->new('0325015');
  print "Looks good.\n" if $sdl->is_valid;

  $sdl = Business::SEDOL->new('0123457');
  $chk = $sdl->check_digit;
  $sdl->sedol($sdl->sedol.$chk);
  print $sdl->is_valid ? "Looks good." : "Invalid: ", $sdl->error, "\n";

=head1 DESCRIPTION

This module verifies SEDOLs, which are British securities identification
codes. This module cannot tell if a SEDOL references a real security, but it
can tell you if the given SEDOL is properly formatted.

=cut

use strict;
use vars qw($VERSION $ERROR);

$VERSION = '1.01';

=head1 METHODS

=over 4

=item new([SEDOL_NUMBER])

The new constructor optionally takes the SEDOL number.

=cut
sub new {
  my ($class, $sedol) = @_;
  bless \$sedol, $class;
}

=item sedol([SEDOL_NUMBER])

If no argument is given to this method, it will return the current SEDOL
number. If an argument is provided, it will set the SEDOL number and then
return the SEDOL number.

=cut
sub sedol {
  my $self = shift;
  $$self = shift if @_;
  return $$self;
}

=item series()

Returns the series number of the SEDOL.

=cut
sub series {
  my $self = shift;
  return substr($self->sedol, 0, 1);
}

=item is_valid()

Returns true if the checksum of the SEDOL is correct otherwise it returns
false and $Business::SEDOL::ERROR will contain a description of the problem.

=cut
sub is_valid {
  my $self = shift;
  my $val = $self->sedol;

  $ERROR = undef;

  if (length($val) != 7) {
    $ERROR = "SEDOLs must be 7 characters long.";
    return '';
  }

  if ($val =~ /\D/) {
    $ERROR = "SEDOLs must contain only numerals.";
    return '';
  }

  my $c = $self->check_digit;
  if (substr($self->sedol, -1, 1) eq $c) {
    return 1;
  } else {
    $ERROR = "Check digit not correct. Expected $c.";
    return '';
  }
}

=item error()

If the SEDOL object is not valid (! is_valid()) it returns the reason it is 
not valid. Otherwise returns undef.

=cut
sub error {
  shift->is_valid;
  return $ERROR;
}

=item check_digit()

This method returns the checksum of the object. This method ignores the check
digit of the object's SEDOL number. This method recalculates the check_digit
each time. If the check digit cannot be calculated, undef is returned and
$Business::SEDOL::ERROR contains the reason.

=cut
sub check_digit {
  my $self = shift;
  if ($self->sedol =~ /(\D)/) {
    $ERROR = "Invalid character, '$1', in check_digit calculation.";
    return;
  }
  my @weights = (1, 3, 1, 7, 3, 9, 1);
  my @val = split //, $self->sedol;
  my $sum = 0;
  for (0..5) {
    $sum += $val[$_] * $weights[$_];
  }
  return (10 - $sum % 10) % 10;
}

1;
__END__
=back

=head1 AUTHOR

This module was written by
Tim Ayers (http://search.cpan.org/search?author=TAYERS).

=head1 COPYRIGHT

Copyright (c) 2001 Tim Ayers. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
