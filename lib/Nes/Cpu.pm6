unit module Nes::Cpu;

use Ram;
use Rom;

constant op-name is export = <
    BRK ORA NIL NIL NIL ORA ASL NIL    PHP ORA ASL NIL NIL ORA ASL NIL
    BPL ORA NIL NIL NIL ORA ASL NIL    CLC ORA NIL NIL NIL ORA ASL NIL
    JSR AND NIL NIL BIT AND ROL NIL    PLP AND ROL NIL BIT AND ROL NIL
    BMI AND NIL NIL NIL AND ROL NIL    SEC AND NIL NIL NIL AND ROL NIL
    RTI EOR NIL NIL NIL EOR LSR NIL    PHA EOR LSR NIL JMP EOR LSR NIL
    BVC EOR NIL NIL NIL EOR LSR NIL    CLI EOR NIL NIL NIL EOR LSR NIL
    RTS ADC KIL RRA NOP ADC ROR RRA    PLA ADC ROR ARR JMP ADC ROR RRA
    BVS ADC NIL NIL NIL ADC ROR NIL    SEI ADC NIL NIL NIL ADC ROR NIL
    NIL STA NIL NIL STY STA STX NIL    DEY NIL TXA NIL STY STA STX NIL
    BCC STA NIL NIL STY STA STX NIL    TYA STA TXS NIL NIL STA NIL NIL
    LDY LDA LDX NIL LDY LDA LDX NIL    TAY LDA TAX NIL LDY LDA LDX NIL
    BCS LDA NIL NIL LDY LDA LDX NIL    CLV LDA TSX NIL LDY LDA LDX NIL
    CPY CMP NIL NIL CPY CMP DEC NIL    INY CMP DEX NIL CPY CMP DEC NIL
    BNE CMP NIL NIL NIL CMP DEC NIL    CLD CMP NIL NIL NIL CMP DEC NIL
    CPX SBC NIL NIL CPX SBC INC NIL    INX SBC NOP NIL CPX SBC INC NIL
    BEQ SBC NIL NIL NIL SBC INC NIL    SED SBC NIL NIL NIL SBC INC NIL
>;

# value = 0..10
enum Mode is export <
    immediate
    zero-page
    zero-page-x
    zero-page-y
    absolute
    absolute-x
    absolute-y
    indirect-x
    indirect-y
    accumulator
    implied
>;

constant op-mode is export = <
   10   7  -1  -1  -1   1   1  -1  10  -1   9  -1  -1   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
    4   7  -1  -1   1   1   1  -1  10  -1   9  -1   4   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   10   7  -1  -1  -1   1   1  -1  10  -1   9  -1   4   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   10   7  -1  -1  -1   1   1  -1  10  -1   9  -1  -1   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   -1   7  -1  -1   1   1   1  -1  10  -1  10  -1   4   4   4  -1
   -1  -1  -1  -1   2   2   3  -1  10   6  10  -1  -1   5  -1  -1
   -1   7  -1  -1   1   1   1  -1  10  -1  10  -1   4   4   4  -1
   -1  -1  -1  -1   2   2   3  -1  10   6  10  -1   5   5   6  -1
   -1   7  -1  -1   1   1   1  -1  10  -1  10  -1   4   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   -1   7  -1  -1   1   1   1  -1  10  -1  10  -1   4   4   4  -1
   -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
>;

constant op-cycle is export = <
    7   6   0   0   0   3   5   0   3   2   2   0   0   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    6   6   0   0   3   3   5   0   4   2   2   0   4   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    6   6   0   0   0   3   5   0   3   2   2   0   3   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    6   6   0   0   0   3   5   0   4   2   2   0   5   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    0   6   0   0   3   3   3   0   2   0   2   0   4   4   4   0
    2   6   0   0   4   4   4   0   2   5   2   0   0   5   0   0
    2   6   2   0   3   3   3   0   2   2   2   0   4   4   4   0
    2   5   0   0   4   4   4   0   2   4   2   0   4   4   4   0
    2   6   0   0   3   3   5   0   2   2   2   0   4   4   3   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    2   6   0   0   3   3   5   0   2   2   2   0   4   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
>;

constant op-page-cycle is export = <
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   1   0   0   0   0   0   1   0   1   1   1   1   1
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
    1   1   0   0   0   0   0   0   0   1   0   0   1   1   0   0
>;

constant op-length is export = <
    1   2   0   0   0   2   2   0   1   2   1   0   0   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
    3   2   0   0   2   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
    1   2   0   0   0   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
    1   2   0   0   0   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
    0   2   0   0   2   2   2   0   1   0   1   0   3   3   3   0
    2   2   0   0   2   2   2   0   1   3   1   0   0   3   0   0
    2   2   2   0   2   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   2   2   2   0   1   3   1   0   3   3   3   0
    2   2   0   0   2   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
    2   2   0   0   2   2   2   0   1   2   1   0   3   3   3   0
    2   2   0   0   0   2   2   0   1   3   0   0   0   3   3   0
>;

class Cpu is export {
    # reg
    has uint16 $!pc;
    has byte   $!a;
    has byte   $!x;
    has byte   $!y;
    has byte   $!sp = 0x01ff;

    # flags
    has byte $!c; # carry
    has byte $!z; # zero
    has byte $!i; # interrupt disabled
    has byte $!d; # decimal mode
    has byte $!b; # break executed
    has byte $!v; # overflow
    has byte $!s; # sign

    has Ram  $!ram;
    has Int  $.cycle-count;

    # high level
    submethod reset() {}
    submethod step( --> Int) {}

    # basic op
    submethod sr() {
    }
    
    # op dispatcher
    submethod op(byte:D $opcode, |p) {
        given $opcode {
            when 0x00 { self.brk(|p) }
            when 0x01 | 0x05 | 0x09 | 0x0d | 0x11 | 0x15 | 0x19 | 0x1d
                      { self.ora(|p) }
            when 0x06 | 0x0a | 0x0e | 0x16 | 0x1e
                      { self.asl(|p) }
            when 0x08 { self.php(|p) }
            when 0x10 { self.bpl(|p) }
            when 0x18 { self.clc(|p) }
            when 0x20 { self.jsr(|p) }
            when 0x21 | 0x25 | 0x29 | 0x2d | 0x31 | 0x35 | 0x39 | 0x3d
                      { self.and(|p) }
            when 0x24 | 0x2c
                      { self.bit(|p) }
            when 0x26 | 0x2a | 0x2e | 0x36 | 0x3e
                      { self.rol(|p) }
            when 0x28 { self.plp(|p) }
            when 0x30 { self.bmi(|p) }
            when 0x38 { self.sec(|p) }
            when 0x40 { self.rti(|p) }
            when 0x41 | 0x45 | 0x49 | 0x4d | 0x51 | 0x55 | 0x59 | 0x5d
                      { self.eor(|p) }
            when 0x46 | 0x4a | 0x4e | 0x56 | 0x5e
                      { self.lsr(|p) }
            when 0x48 { self.pha(|p) }
            when 0x4c | 0x6c
                      { self.jmp(|p) }
            when 0x50 { self.bvc(|p) }
            when 0x58 { self.cli(|p) }
            when 0x60 { self.rts(|p) }
            when 0x61 | 0x65 | 0x69 | 0x6d | 0x71 | 0x75 | 0x79 | 0x7d
                      { self.adc(|p) }
            when 0x66 | 0x6a | 0x6e | 0x76 | 0x7e
                      { self.ror(|p) }
            when 0x68 { self.pla(|p) }
            when 0x70 { self.bvs(|p) }
            when 0x78 { self.sei(|p) }
            when 0x80 | 0x85 | 0x8d | 0x91 | 0x95 | 0x99 | 0x9d
                      { self.sta(|p) }
            when 0x84 | 0x8c | 0x94
                      { self.sty(|p) }
            when 0x86 | 0x8e | 0x96
                      { self.stx(|p) }
            when 0x88 { self.dey(|p) }
            when 0x8a { self.txa(|p) }
            when 0x90 { self.bcc(|p) }
            when 0x98 { self.tya(|p) }
            when 0x9a { self.txs(|p) }
            when 0xa0 | 0xa4 | 0xac | 0xb4 | 0xbc
                      { self.ldy(|p) }
            when 0xa1 | 0xa5 | 0xa9 | 0xad | 0xb1 | 0xb5 | 0xb9 | 0xbd
                      { self.lda(|p) }
            when 0xa2 | 0xa6 | 0xae | 0xb6 | 0xbe
                      { self.ldx(|p) }
            when 0xa8 { self.tay(|p) }
            when 0xaa { self.tax(|p) }
            when 0xb0 { self.bcs(|p) }
            when 0xb8 { self.clv(|p) }
            when 0xba { self.tsx(|p) }
            when 0xc0 | 0xc4 | 0xcc
                      { self.cpy(|p) }
            when 0xc1 | 0xc5 | 0xc9 | 0xcd | 0xd1 | 0xd5 | 0xd9 | 0xdd
                      { self.cmp(|p) }
            when 0xc6 | 0xce | 0xd6 | 0xde
                      { self.dec(|p) }
            when 0xc8 { self.iny(|p) }
            when 0xca { self.dex(|p) }
            when 0xd0 { self.bne(|p) }
            when 0xd8 { self.cld(|p) }
            when 0xe0 | 0xe4 | 0xec
                      { self.cpx(|p) }
            when 0xe1 | 0xe5 | 0xe9 | 0xed | 0xf1 | 0xf5 | 0xf9 | 0xfd
                      { self.sbc(|p) }
            when 0xe6 | 0xee | 0xf6 | 0xfe
                      { self.inc(|p) }
            when 0xe8
                      { self.inx(|p) }
            when 0xea { self.nop(|p) }
            when 0xf0 { self.beq(|p) }
            when 0xf8 { self.sed(|p) }
        }
    }

    # ops
    submethod brk($addr, $mode) {}
    submethod ora($addr, $mode) {}
    submethod asl($addr, $mode) {}
    submethod php($addr, $mode) {}
    submethod bpl($addr, $mode) {}
    submethod clc($addr, $mode) {}
    submethod jsr($addr, $mode) {}
    submethod and($addr, $mode) {}
    submethod bit($addr, $mode) {}
    submethod rol($addr, $mode) {}
    submethod plp($addr, $mode) {}
    submethod bmi($addr, $mode) {}
    submethod sec($addr, $mode) {}
    submethod rti($addr, $mode) {}
    submethod eor($addr, $mode) {}
    submethod lsr($addr, $mode) {}
    submethod pha($addr, $mode) {}
    submethod jmp($addr, $mode) {}
    submethod bvc($addr, $mode) {}
    submethod cli($addr, $mode) {}
    submethod rts($addr, $mode) {}
    submethod adc($addr, $mode) {}
    submethod ror($addr, $mode) {}
    submethod pla($addr, $mode) {}
    submethod bvs($addr, $mode) {}
    submethod sei($addr, $mode) {}
    submethod sta($addr, $mode) {}
    submethod sty($addr, $mode) {}
    submethod stx($addr, $mode) {}
    submethod dey($addr, $mode) {}
    submethod txa($addr, $mode) {}
    submethod bcc($addr, $mode) {}
    submethod tya($addr, $mode) {}
    submethod txs($addr, $mode) {}
    submethod ldy($addr, $mode) {}
    submethod lda($addr, $mode) {}
    submethod ldx($addr, $mode) {}
    submethod tay($addr, $mode) {}
    submethod tax($addr, $mode) {}
    submethod bcs($addr, $mode) {}
    submethod clv($addr, $mode) {}
    submethod tsx($addr, $mode) {}
    submethod cpy($addr, $mode) {}
    submethod cmp($addr, $mode) {}
    submethod dec($addr, $mode) {}
    submethod iny($addr, $mode) {}
    submethod dex($addr, $mode) {}
    submethod bne($addr, $mode) {}
    submethod cld($addr, $mode) {}
    submethod cpx($addr, $mode) {}
    submethod sbc($addr, $mode) {}
    submethod inc($addr, $mode) {}
    submethod inx($addr, $mode) {}
    submethod nop($addr, $mode) {}
    submethod beq($addr, $mode) {}
    submethod sed($addr, $mode) {}
}
