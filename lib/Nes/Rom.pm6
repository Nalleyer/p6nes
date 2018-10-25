unit module Nes::Rom;
use BinaryParse;

class Rom is export {
    has buf8       $.prg;
    has buf8       $.chr;
    has byte       $.mapper;
    has Bool       $.vertical-mirror;
}

class RomParsing does BinaryParsing {
    method parse {
        ### 16 bytes header ###
        self.many-bytes(4);         # 0 - 3
        my $prg-count  = self.byte; # 4
        my $chr-count  = self.byte; # 5
        my $flag6      = self.byte; # 6
        my $flag7      = self.byte; # 7
        my $prg-count8 = self.byte; # 8
        my $flag9      = self.byte; # 9
        my $flag10     = self.byte; # 10
        self.many-bytes(5);         # 11 - 15

        #-- parse falg 6 --#
        my $vertical-mirror = nth-bit($flag6, 0);
        my $sram-enabled    = nth-bit($flag6, 1);
        my $trainer-present = nth-bit($flag6, 2);
        my $four-screen     = nth-bit($flag6, 3);
        my $mapper-low4     = byte-range($flag6, 4, 4);

        #-- parse falg 7 --#
        my $vs-uni              = nth-bit($flag7, 0);
        my $play-choice-present = nth-bit($flag7, 1);
        my $nes2                = byte-range($flag7, 2, 2);
        my $mapper-high4        = byte-range($flag7, 4, 4);

        my $mapper = ($mapper-high4 +< 4) +| $mapper-low4;

        ### maybe trainer:             512 bytes ###
        my $trainer = self.many-bytes($trainer-present * (1 +< 9));
        ### PRG:             count * 16384 bytes ###
        my $prg     = self.many-bytes($prg-count * (1 +< 14));
        ### CHR:              count * 8192 bytes ###
        my $chr     = self.many-bytes($chr-count * (1 +< 13));
        ### maybe play-choice inst:   8192 bytes ###
        my $play-choice-inst = self.many-bytes($play-choice-present * (1 +< 13));
        ### maybe play-choice prom: 2 * 16 bytes ###
        my $play-choice-prom = self.many-bytes($play-choice-present * (1 +< 6));

        return Rom.new(
            prg => $prg,
            chr => $chr,
            mapper => $mapper,
            vertical-mirror => so $vertical-mirror,
        );
    }
}

sub parse-rom(Str:D $path --> Rom) is export {
  my $rom-parser = RomParsing.new(:$path);
  $rom-parser.parse
}
