    device zxspectrum48
    org #6100 ; адрес на который компилировать    
begin_file:
    ld bc,(#7f8f)       ; ED 4B NNl NNh
    nop
    nop
    DI
    ld (hl),bc       ; 71 23 70 2B
    ld (ix+1),#05        ; DD 36 01 05
    nop
    nop
    ld (ix),a        ; DD 77 00
    ld (ix),b        ; DD 70 00
    ld (ix),bc       ; DD 71 00 DD 70 01
    ld (ix+5),b    ; DD 70 DIS
    nop
    nop
    ld bc,(hl)       ; 4E 23 46 2B
    ld (ix+4),bc   ; DD 71 DIS DD 70 DIS+1
    nop
    nop

    LD SP,#6100
    ld ix,#EEEE
    ld iy,#DDDD
    ld de,#8080
    ld hl,#AABB
    ld (ix),d
    ld (ix+2),e
    ld (iy),h
    ld (iy-2),l

    LD A,#07
    LD B,#02
    SUB B
    CP #06
    JR Z,zzz1 ;#06
    JR C,zzz2 ;#0A
    JR NC,zzz3 ;#0E
    DI
    HALT
zzz1:
    LD A,#00
    OUT (#FE),A
    DI
    HALT
zzz2:
    LD A,#01
    OUT (#FE),A
    DI
    HALT
zzz3:
    LD A,#02
    OUT (#FE),A
    DI
    HALT
    LD A,#04
    LD HL,#5800
    LD DE,#5801
    LD BC,#02FF
    LD (HL),A
    LDIR
    RET
end_file:
    display "code size: ", /d, end_file - begin_file
    savebin "parse.C", begin_file, end_file - begin_file

; ld   hl,(ix)       ; DD 6E 00 DD 66 01
