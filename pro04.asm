        device zxspectrum48    
PLOTT   equ #a000; 1k table   
        org #8000

begin_file:
       DI             ;создание
       LD HL,#FE00    ;вектора
       LD A,H         ;маскиру-
       LD I,A         ;емых
       INC A          ;преры-
       LD (HL),A      ;ваний
       INC L
       JR NZ,$-2
       LD C,H
       INC H
       LD (HL),A
       LD L,A
       LD (HL),#C9
       IM 2
;основной цикл, иными словами сама суть
        call INSTALL
        ld b, 100
        ld c, 100
        call PLOT
        ret

INSTALL  ; процедура инсталяции 
        LD HL,PLOTT   ; адрес таблици 
        ;в 1024 байта для точки, младший байт адреса должен быть ра-
        ;вен #00! например #F0 или #BC00
        LD DE,#4000   ; адрес экрана 
        LD B,E 
        LD C,#80 ;* 
        LD HX,4 
LOOP3   LD LX,8 
LOOP2   LD A,8 
LOOP1   LD (HL),E 
        INC H 
        LD (HL),D 
        INC H 
        LD (HL),B 
        INC H 
        LD (HL),C 
        RRC C 
        DEC H 
        DEC H 
        DEC H 
        INC HL 
        INC D 
        DEC A 
        JR NZ,LOOP1 
        INC B 
        LD A,B 
        AND 31 
        LD B,A 
        LD A,D 
        SUB 8 
        LD D,A 
        LD A,E 
        ADD A,#20 
        LD E,A 
        DEC LX 
        JR NZ,LOOP2 
        LD A,D 
        ADD A,8 
        LD D,A 
        DEC HX 
        JR NZ,LOOP3 
        RET 


PLOT  ; процедура построения точки 
        LD L,C 
        LD H,PLOTT/256 
        LD A,(HL) 
        INC H 
        LD D,(HL) 
        INC H 
        LD L,C 
        ADD A,(HL) 
        LD E,A 
        INC H 
        LD A,(DE) 
        XOR (HL) 
        ;OR (HL) можно заменить на XOR (HL) для наложения по принципу
        ;XOR,или на AND (HL) для стирания точек, но тогда уже надо за-
        ;менить регистр C на входе процедуры INSTALL с #80 на #7F
        LD (DE),A 
        RET 

end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro04.$C", "pro04.C", begin_file, end_file - begin_file
    savesna "pro04.sna", begin_file
    labelslist "pro04.l"
