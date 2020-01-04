      device zxspectrum48    
      org 25000

begin_file:
      DI
      LD HL,#B200   ;Установим
      LD DE,#B201   ;2ой режим
      LD BC,256     ;прерываний
      LD (HL),#B3
      LD A,H
      LD I,A
      LDIR
      LD A,#C9     ;Обработчик состоит
      LD (#B3B3),A ;из одной команды RET
      IM 2
LOOP  EI
      HALT
      DI
      LD B,255    ;Экран начал
L1    LD A,1      ;строиться
      OUT (#FE),A ; синхронно с
      NOP         ;ним работает
      NOP         ;программа.
      NOP         ;Здесь первая
      DJNZ L1     ;линия.
      DEC B
L2    LD A,2
      OUT (#FE),A ;А здесь рисуем
      NOP         ; вторую.
      NOP
      NOP
      DJNZ L2
      DEC B
L3    LD A,3
      OUT (#FE),A ;Далее третья.
      NOP
      NOP
      NOP
      DJNZ L3
      DEC B
L4    LD A,4
      OUT (#FE),A ;Ещё одна.
      NOP
      NOP
      NOP
      DJNZ L4
      DEC B
L5    LD A,5
      OUT (#FE),A ;И ещё.
      NOP
      NOP
      NOP
      DJNZ L5
      DEC B
L6    LD A,6
      OUT (#FE),A
      NOP
      NOP
      NOP
      DJNZ L6
      DEC B
L7    LD A,7
      OUT (#FE),A ;Последняя.
      NOP
      NOP
      NOP
      DJNZ L7
      LD A,#7F    ;Интересуемся
      IN A,(#FE)  ;не нажата ли
      RRA         ;ANY KEY .
      JP C,LOOP   ;Если нет - всё
      IM 1        ;заново ,
      RET         ;иначе назад в
                  ; TASM.
    
end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro02.$C", "pro02.C", begin_file, end_file - begin_file
    savesna "pro02.sna", begin_file
    labelslist "pro02.l"
