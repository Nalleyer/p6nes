use lib 'lib/Nes';
use Rom;
use BinaryParse;

sub MAIN(Str $rom-path) {
  my $rom = parse-rom($rom-path);
  $rom.chr.elems.say;
  $rom.prg.elems.say;
  $rom.mapper.say;
}
