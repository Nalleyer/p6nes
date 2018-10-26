unit module Nes::BinaryParse;

use BinaryUtil;

#### do this role and implement the parse() method to build your parser ####
role BinaryParsing is export {
    has buf8 $!bytes;

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
        my $bytes = buf8.new;
        for ^$n {
            $bytes.push($!bytes.shift)
        }
        $bytes
    }
    submethod p-many-bytes($n, :$unsafe) { self.assert-elems($n, :$unsafe); $!bytes.subbuf(0, $n) }
}
