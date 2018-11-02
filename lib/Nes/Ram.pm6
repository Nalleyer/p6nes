unit module Nes::Ram;
use BinaryUtil;

class Ram is export {
    # 16bit address ==> 65536 ram size #
    has buf8 $!ram;

    method get(uint16:D $addr) {
        0x00
    }

    # get 2 byte
    method getw(uint16:D $addr) {
        merge-byte(self.get($addr), self.get($addr + 1))
    }

    method set(uint16:D $addr, byte:D $byte) {
        $!ram[$addr] = $byte
    }

    #method setw(uint16:D $addr, uint16:D $word) {
    #}
}
