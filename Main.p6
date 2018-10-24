use lib 'lib/Nes';
use Rom;

sub MAIN(Str $rom-path) {
  my $rom = parse-rom($rom-path);
  $rom.chr.elems.say;
  $rom.prg.elems.say;
}
