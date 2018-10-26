unit module Nes::BinaryUtil;

sub buf-from-path(Str:D $path) is export {
    $path.IO.slurp(:close, :bin)
}

# 76543210 (0th is the lowest bit)
sub nth-bit(byte:D $byte, Int:D $n where 0 <= $n < 8 --> byte) is export {
    $byte +> $n +& 0x1
}

sub byte-range(
   byte:D $byte
 , Int:D $n where 0 <= $n < 8
 , Int:D $len where 0 < $len <= 8
 --> byte)
 is export {
    my byte $result = 0;
    $result = $result +| (nth-bit($byte, $n + $_) +< $_) for ^$len;
    $result
}

sub say-byte(byte:D $byte) is export {
    say $byte.fmt("%02x");
}

sub say-byte-b(byte:D $byte) is export {
    say $byte.fmt("%08b");
}

sub say-word(uint16:D $word) is export {
    say $word.fmt("%04x");
}

sub say-word-b(uint16:D $word) is export {
    say $word.fmt("%016b");
}

sub merge-byte(byte:D $lowb, byte:D $highb --> uint16) is export {
    my uint16 $word = $highb;
    $word = $lowb +| ($word +< 8);
    $word
}
