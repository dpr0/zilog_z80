    device zxspectrum48    
    org #6000
sint equ #B000
    
begin_file:

    LD HL,#0304   ; 21 04 03 
    LD A,#0D      ; 3E 0D
    LD BC,#FFFD   ; 01 FD FF
ayl: OUT (C),A     ; ED 79
    LD B,#BF      ; 06 BF
    OUTD          ; ED AB
    DEC A         ; 3D
    JR NZ, ayl     ; 20 F4
    OUT (#FE),A   ; D3 FE
    EXX           ; D9
    LD BC,sint    ; 01 00 B0
    EXX           ; D9
    LD H,A        ; 67
    LD L,A        ; 6F
    LD D,H        ; 54
    LD E,L        ; 5D
gens: LD A,H        ; 7C
    CP #04        ; FE 04 ----30
    EX DE,HL      ; EB
    LD BC,#0008   ; 01 08 00
    JR C, bra1      ; 38 05
    AND A         ; A7
    SBC HL,BC     ; ED 42
    JR bra2         ; 18 01
bra1: ADD HL,BC     ; 09
bra2: EX DE,HL      ; EB
    ADD HL,DE     ; 19
    LD A,H        ; 7C
    EXX           ; D9
    LD (BC),A     ; 02
    INC C         ; 0C
    EXX           ; D9
    JR NZ, gens     ; 20 E8
    LD HL,ous1    ; 21 00 61
    LD D,#58      ; 16 58
    LD C,#18      ; 0E 18
f1: PUSH DE       ; D5
    PUSH BC       ; C5 ----60
    EX DE,HL      ; EB
    LD HL,r_b     ; 21 F3 60
    LD BC,r_e - r_b   ; 01 09 00
    LDIR          ; ED B0
    LD HL,rv + 1   ; 21 F9 60
    INC (HL)      ; 34
    EX DE,HL      ; EB
    POP BC        ; C1
    POP DE        ; D1
    LD B,#10      ; 06 10
f2: LD (HL),#E1   ; 36 E1
    INC HL        ; 23
    LD (HL),#22   ; 36 22
    INC HL        ; 23
    LD (HL),E     ; 73
    INC HL        ; 23
    LD (HL),D     ; 72
    INC HL        ; 23
    INC DE        ; 13
    INC DE        ; 13 ----90
    DJNZ f2       ; 10 F2
    LD B,#20      ; 06 20
f3: LD (HL),#D5   ; 36 D5
    INC HL        ; 23
    DJNZ f3       ; 10 FB
    DEC C         ; 0D
    JR NZ, f1     ; 20 D4
    LD (HL),#31   ; 36 31
    INC HL        ; 23
    LD (outs+2),HL ; 22 FE 60
    INC HL        ; 23
    INC HL        ; 23
    LD (HL),#C9   ; 36 C9
nn: EI            ; FB
    HALT          ; 76
    DI            ; F3
    EXX           ; D9
v1:  LD HL,sint    ; 21 00 B0
    INC L         ; 2C ----120
    LD (v1 + 1),HL ; 22 76 60
    EXX           ; D9
    LD DE,#0707   ; 11 07 07
    CALL outs    ; CD FC 60
v2:  LD HL,sint    ; 21 00 B0
    INC L         ; 2C
    LD (v2 + 1),HL ; 22 84 60
    LD C,#18      ; 0E 18
    EXX           ; D9
    LD HL,serp   ; 21 C3 60
    LD B,#80      ; 06 80
    EXX           ; D9
m1:  EXX           ; D9
    PUSH HL       ; E5
    EXX           ; D9
    LD A,(HL)     ; 7E ---150
    INC L         ; 2C
    PUSH HL       ; E5
    ADD #C0       ; C6 C0
    LD H,A        ; 67
    LD A,#20      ; 3E 20
    SUB C         ; 91
    LD L,A        ; 6F
    LD B,#10      ; 06 10
m2: LD (HL),#52   ; 36 52
    EXX           ; D9
    LD A,(HL)     ; 7E
    AND B         ; A0
    EXX           ; D9
    JR Z, next      ; 28 02
    LD (HL),#76   ; 36 76
next: EXX           ; D9
    INC HL        ; 23
    INC HL        ; 23
    INC HL        ; 23
    EXX           ; D9
    INC H         ; 24
    DJNZ m2       ; 10 EE
    POP HL        ; E1 ---180
    EXX           ; D9
    POP HL        ; E1
    RRC B         ; CB 08
    JR NC, no_hl_i     ; 30 01
    INC HL        ; 23
no_hl_i: EXX           ; D9
    DEC C         ; 0D
    JR NZ, m1     ; 20 D3
    JP nn         ; C3 71 60
serp:
    db #00, #00, #00, #10, #10, #00, #38, #0C
    db #00, #10, #76, #00, #28, #F3, #00, #01
    db #E1, #80, #03, #F1, #80, #01, #F9, #80
    db #00, #9D, #80, #00, #0F, #80, #01, #87
    db #00, #03, #C3, #80, #03, #FF, #C0, #06
    db #3D, #C0, #06, #00, #C0, #00, #00
r_b: EXX           ; D9
    LD A,(HL)     ; 7E
    INC L         ; 2C
    INC L         ; 2C
    EXX           ; D9
rv: LD H,#C0      ; 26 C0
    LD L,A        ; 6F
    LD SP, HL     ; F9
r_e:
outs:
    LD (#0000),SP ; ED 73 00 00   (error LD 00,(#SP00) )
ous1:
       db "russkie idut"
end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro08.$C", "pro08.C", begin_file, end_file - begin_file
    savesna "pro08.sna", begin_file
    savebin "pro08.C", begin_file, end_file - begin_file
    savetap "pro08.tap", begin_file 
    labelslist "pro08.l"
