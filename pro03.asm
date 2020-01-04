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
; далее совсем иначе
      LD D,0 ; border color
      LD E,5 ; border line color
      LD A,64 ; lines count
      LD C,#FE

MAX   OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      OUT (C),D  ; 12 тактов
      OUT (C),E  ; 12 тактов
      ; Итого уже  192 такта
      OUT (C),D  ; 12 тактов
      NOP        ; 4 такта
      DEC A      ; 4 такта
      JR NZ,MAX  ; 12 тактов
  ; в сумме набежало 220 тактов т.е.
  ; столько сколько по времени тратит
  ; мой компьютер на построение одной
  ; строки
      LD A,#7F
      IN A,(#FE)
      RRA
      JP C,LOOP
      IM 1
      RET

end_file:
    display "code size: ", /d, end_file - begin_file
    savehob "pro03.$C", "pro03.C", begin_file, end_file - begin_file
    savesna "pro03.sna", begin_file
    labelslist "pro03.l"
