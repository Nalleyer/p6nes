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
  10   7  -1  -1  -1   1   1  -1  10   0   9  -1  -1   4   4  -1
  -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5  -1  -1
   4   7  -1  -1   1   1   1  -1  10   0   9  -1   4   4   4  -1
  -1   8  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   4   7  -1  -1  -1   1   1  -1  10   0   9  -1   4  10   4  -1
   5  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1  -1   5  -1
  10   7  -1  -1  -1   1   1  -1  10   0   9  -1  -1  -1   4  -1
  -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1  -1   5  -1
   4   7  -1  -1   1   1   1  -1  10  -1  10  -1   4  -1   4  -1
   5  -1  -1  -1   2   2   3  -1  10   6  10  -1  -1  -1  -1  -1
   0   7   0  -1   1   1   1  -1  10   0  10  -1   4   4   4  -1
  -1  -1  -1  -1   2   2   3  -1  10   6  10  -1   5   5   6  -1
   0   7  -1  -1   1   1   1  -1  10   0  10  -1   4   4   4  -1
  -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
   0   7  -1  -1   1   1   1  -1  10   0  10  -1   4   4   4  -1
  -1  -1  -1  -1  -1   2   2  -1  10   6  -1  -1  -1   5   5  -1
>;

constant op-cycle is export = <
    7   6   0   0   0   3   5   0   3   2   2   0   0   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    6   6   0   0   3   3   5   0   4   2   2   0   4   4   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   4   7   0
    4   6   0   0   0   3   5   0   3   2   2   0   3   6   6   0
    4   5   0   0   0   4   6   0   2   4   0   0   0   0   7   0
    6   6   0   0   0   3   5   0   4   2   2   0   5   0   6   0
    2   5   0   0   0   4   6   0   2   4   0   0   0   0   7   0
    4   6   0   0   3   3   3   0   2   0   2   0   4   0   4   0
    5   6   0   0   4   4   4   0   2   5   2   0   0   0   0   0
    2   6   2   0   3   3   3   0   2   2   2   0   4   4   4   0
    2   5   0   0   4   4   4   0   2   4   2   0   4   4   4   0
    2   6   0   0   3   3   5   0   2   2   2   0   4   4   6   0
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

class Cpu is export {
    # reg
    has uint16 $!a;
    has byte   $!x;
    has byte   $!y;
    has uint16 $!pc;
    has byte   $!sp;

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

    submethod step( --> Int) {}

    # ops
    submethod brk($addr, $mode) {}
    submethod ora($addr, $mode) {}
}
