unit module Nes::BinaryParse;

#..... no mutable byte type in perl6, using Int instead .....#

#### utils ####
sub buf-from-path(Str:D $path) is export {
    $path.IO.slurp(:close, :bin)
}

# 76543210
# 0th is the lowest bit
sub nth-bit(Int:D $byte, Int:D $n where 0 <= $n < 8 --> Int) is export {
    $byte +> $n +& 0x1
}

sub byte-range(
   Int:D $byte
 , Int:D $n where 0 <= $n < 8
 , Int:D $len where 0 < $len <= 8
 --> Int)
 is export {
    my Int $result = 0;
    $result = $result +| (nth-bit($byte, $n + $_) +< $_) for ^$len;
    $result
}

sub say-byte(Int:D $byte) is export {
    say $byte.fmt("%08b");
}

#### do this role and implement the parse() method to build your parser ####
role BinaryParsing is export {
    has Buf[uint8] $!bytes;

    submethod BUILD(Str:D:$path) {
        $!bytes = buf-from-path($path);
    }

    method parse {}

    submethod elems { $!bytes.elems }
    submethod assert-elems($n, :$unsafe) {
        unless $unsafe {
            die "expected $n bytes but only {$!bytes.elems} bytes got"
            if $n > $!bytes.elems;
        }
    }

    # utils
    # p = peek
    submethod byte(:$unsafe)   { self.assert-elems(1, :$unsafe); $!bytes.shift  }
    submethod p-byte(:$unsafe) { self.assert-elems(1, :$unsafe); $!bytes[0]     }

    submethod many-bytes($n, :$unsafe) {
        self.assert-elems($n, :$unsafe);
        my $bytes = $!bytes.subbuf-rw(0, $n);
        $!bytes.shift for ^$n;
        #my $bytes = Buf[uint8].new;
        #for ^$n {
        #    $bytes.push($!bytes.shift)
        #}
        $bytes
    }
    submethod p-many-bytes($n, :$unsafe) { self.assert-elems($n, :$unsafe); $!bytes.subbuf(0, $n) }
}
