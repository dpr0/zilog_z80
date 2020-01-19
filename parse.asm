    device zxspectrum48
    org #6100 ; адрес на который компилировать    
begin_file:
    DI
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
