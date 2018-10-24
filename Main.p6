use lib 'lib/Nes';
use Rom;


sub MAIN() {
  my $rom = parse-rom("rom_singles/01-implied.nes");
  $rom.chr.elems.say;
  $rom.prg.elems.say;
}
