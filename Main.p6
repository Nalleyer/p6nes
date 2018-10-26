use lib 'lib/Nes';
use Rom;
use Cpu;
use BinaryParse;
use BinaryUtil;

sub MAIN(Str $rom-path) {
  my $rom = parse-rom($rom-path);
  $rom.chr.elems.say;
  $rom.prg.elems.say;
  $rom.mapper.say;

  $rom.prg[0..63]>>.fmt("%0x").say;
}
