        device zxspectrum48    
PLOTT   equ #a000; 1k table   
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
;основной цикл, иными словами сама суть
        call INSTALL

        ld ly, 100  ; 8 
LOOP    LD A,#DF   ;P O I U Y
        IN A,(#FE) ;младший бит адреса порта.
        
        BIT 0,A    ; => "P" определяем состоян. бита,
                   ;соответствующ.клавише "1"
                   ;если бит активен, то флаг
                   ;Z=1, если нет, то Z=0.
        call Z,BLUE
        LD A,#DF   ;P O I U Y
        IN A,(#FE) ;опрос клавы.
        BIT 1,A    ;определяем состояние первого бита => "O" 
        call Z,RED
        
        ld b, ly
        ld c, ly
        call PLOT
        dec ly
        JP LOOP

BLUE    LD A,1     ;BORDER цвет синий
        OUT (254),A
        RET
RED     LD A,2     ;BORBER цвет красный
        OUT (254),A
        RET

INSTALL  ; процедура инсталяции 
        LD HL,PLOTT
        ; адрес таблици в 1024 байта для точки, 
        ; младший байт адреса должен быть равен #00!
        ; например #F0 или #BC00
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
        LD L,B 
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
; OR (HL) можно заменить на XOR (HL) для наложения по принципу XOR,
; или на AND (HL) для стирания точек,
; но тогда уже надо заменить регистр C на входе процедуры INSTALL с #80 на #7F
        LD (DE),A 
        RET 

end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro04.$C", "pro04.C", begin_file, end_file - begin_file
    savesna "pro04.sna", begin_file
    labelslist "pro04.l"
