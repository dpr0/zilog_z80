    device zxspectrum48    
    org #8000
    
begin_file:
;создание вектора маскируемых прерываний
       DI             
       LD HL,#FE00
       LD A,H
       LD I,A
       INC A
       LD (HL),A
       INC L
       JR NZ,$-2
       LD C,H
       INC H
       LD (HL),A
       LD L,A
       LD (HL),#C9
       IM 2

LOOP   EI
       LD B,7
       HALT
       OUT (C),B
OOPS   DS 13440/4,0
       OUT (C),0
       XOR A
       IN A,(C)
       CPL
       AND #1F
       JP Z,LOOP
       LD A,#3F
       LD I,A
       IM 1
       EI
       RET

end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro01.$C", "pro01.C", begin_file, end_file - begin_file
    savesna "pro01.sna", begin_file
    savebin "pro01.C", begin_file, end_file - begin_file
    savetap "pro01.tap", begin_file 
    labelslist "pro01.l"
