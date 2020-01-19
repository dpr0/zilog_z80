    device zxspectrum48
disp             equ #4000
attr             equ #5800  
fast_point_table equ #a000; 1k table
dirrection       equ #efff
cursor           equ #effd
snow_speed       equ #effc
point_array      equ #a400; 512b
    
    org #6100 ; адрес на который компилировать
    
begin_file:
    ld sp,#6100 ; устанавливаем дно стека
    ei ; разрешаем прерывания
    xor a
    out (#fe),a ; черный бордюр 
    
    ld a,%00000100 ; заполняем атрибуты
    ld hl,attr
    ld de,attr + 1
    ld bc,768 - 1
    ld (hl),a
    ldir
    
    xor a ; очищаем экран
    ld hl,disp
    ld de,disp + 1
    ld bc,6144 - 1
    ld (hl),a
    ldir
    
    ld de,disp ; генерируем таблицу для рисования пикселей
    ld hl,fast_point_table
    call fast_point_table_init
 
    ld de,dirrection
    ld a,1
    ld (de),a

    ld de,snow_speed
    ld a,1
    ld (de),a

    ld ix,cursor
    ld de,#8080
    ld (ix),d
    ld (ix+1),e

    ld ix,point_array ; gen stars
    ld b,160

gen_loop:
    ; gen random y
regen_y:
    call random_elite
    cp 192 ; сравниваем A с 192: если A-192 >= 0 => флаг C не установлен - no snow effect
    jr nc,regen_y
    ld (ix),a: inc ix
    ; gen random x
    call random_elite
    ld (ix),a: inc ix
    djnz gen_loop

loop:
    halt
    ld ix,cursor
    ld d,(ix) ; стираем точку
    ld e,(ix+1)
    push de
    call clear_point
    call change_speed
    pop de
    ld ix,dirrection

    LD A,#DF     ;P O I U Y
    IN A,(#FE)   ;младший бит адреса порта.
    BIT 0,A      ;определяем состояние нулевого бита => key "P"
    call Z,RIGHT ;если бит активен, то флаг Z=1, если нет, то Z=0.

    LD A,#DF
    IN A,(#FE)
    BIT 1,A      ;key "O" 
    call Z,LEFT

    call run1
    push de
    call draw_point
    pop de
    ld ix,cursor
    ld (ix),d
    ld (ix+1),e

    ld ix,point_array
    ld b,160
draw_loop:
    ld d,(ix) ; стираем точку
    ld e,(ix+1)
    push de
    call clear_point
    pop de
    
    ld a,b ; ставим точку
    and 7
    inc a
    add e
    ld e,a
    ld (ix+1),e

    push ix: push bc ; изменяем скорость
    ld a,(snow_speed)
    ld b,a
speed inc d
    djnz speed
    pop bc: pop ix
    ; inc d ; скорость = 1

    ld (ix),d ; snow effect
    call draw_point  
    inc ix: inc ix: inc ix
 
    ; border fun
    ; ld a,e:and 3:out (#fe),a; bb
    ; xor a:out (#fe),a; bb
    djnz draw_loop
    jp loop

change_speed
        LD A,#F7
        IN A,(#FE)
        RRCA         ;key "1" 
        jr c,speed1
        RRCA         ;key "2" 
        jr c,speed2
        RRCA         ;key "3" 
        jr c,speed3
        RRCA         ;key "4" 
        jr c,speed4
        RRCA         ;key "5" 
        jr c,speed5
        ret

speed1  ld de,snow_speed
        ld a,1
        ld (de),a
        ret
speed2  ld de,snow_speed
        ld a,2
        ld (de),a
        ret
speed3  ld de,snow_speed
        ld a,3
        ld (de),a
        ret
speed4  ld de,snow_speed
        ld a,4
        ld (de),a
        ret
speed5  ld de,snow_speed
        ld a,5
        ld (de),a
        ret

RIGHT   ld a,(ix)
        inc a
        cp 16
        jr c, next1
        xor a
next1   ld (ix),a
        ret
        
LEFT    ld a,(ix)
        dec a
        jr nz, next2
        ld a,15
next2   ld (ix),a
        ret
        
run1    ld a,(ix)
        cp 0
        call z, dir0
        ret z
        cp 1
        call z, dir1
        ret z
        cp 2
        call z, dir2
        ret z
        cp 3
        call z, dir3
        ret z
        cp 4
        call z, dir4
        ret z
        cp 5
        call z, dir5
        ret z
        cp 6
        call z, dir6
        ret z
        cp 7
        call z, dir7
        ret z
        cp 8
        call z, dir8
        ret z
        cp 9
        call z, dir9
        ret z
        cp 10
        call z, dir10
        ret z
        cp 11
        call z, dir11
        ret z
        cp 12
        call z, dir12
        ret z
        cp 13
        call z, dir13
        ret z
        cp 14
        call z, dir14
        ret z
        cp 15
        call z, dir15
        ret
random_elite:
    ld a,(random_store)
    ld d,a
    ld a,(random_store+1)
    ld (random_store),a
    add a,d
    ld d,a
    ld a,(random_store+2)
    ld (random_store+1),a
    add a,d
    rlca
    ld (random_store+2),a
    ret

random_store:
    db 0,42,109    
    
    ; Input:
    ; d - y
    ; e - x
    ; Used:
    ; h,l
draw_point:
    ld h,high fast_point_table;7
    ; y
    ld l,d;4
    ld d,(hl);7
    inc h;4
    ; x
    ld a,(hl);7 sss
    inc h;4
    ld l,e;4
    or (hl);7 смещение в байтах
    ld e,a;4
    ;
    inc h;4
    ld a,(de);7
    or (hl);7
    ld (de),a;7
 
    ret;10
    ; 49 + 28 = 77
    ; 49 + 24 = 73  

    ; Input:
    ; d - y
    ; e - x
    ; Used:
    ; h,l
clear_point:
    ld h,high fast_point_table;7
    ; y
    ld l,d;4
    ld d,(hl);7
    inc h;4
    ; x
    ld a,(hl);7 sss
    inc h;4
    ld l,e;4
    or (hl);7 смещение в байтах
    ld e,a;4
    ;
    inc h;4
    ex de,hl
    ld a,(de);7
    cpl
    and (hl);7
    ld (hl),a;7
 
    ret;10
    ; 49 + 28 = 77
    ; 49 + 24 = 73     
    
    ; hl - fast_point_table
    ; de - screen addr (#4000,#c000)
fast_point_table_init:  
    ; генерация таблицы старшего байта адреса по Y
    ; заполняет 192(256) байтов 3 группами по 8*8
    ; %ddd00000,%ddd00001,%ddd00010,%ddd00011,%ddd00100,%ddd00101,%ddd00110,%ddd00111
    ; ...
    ; %ddd01000,%ddd01001,%ddd01010,%ddd01011,%ddd01100,%ddd01101,%ddd01110,%ddd01111
    ; ...
    ; %ddd10000,%ddd10001,%ddd10010,%ddd10011,%ddd10100,%ddd10101,%ddd10110,%ddd10111
    ld c,#00
loop4:
    ld b,64
loop44:
    ld a,l; смещение внутри знакоместа
    and #07
    or d; начало адреса
    or c; номер трети
    ld (hl),a
    inc hl
    djnz loop44
    ld a,c
    add #08
    ld c,a
    cp #18
    jr nz,loop4  
    ; пропускаем 64 байта
    ;ld l,0
    ;inc h
    ; ловушка, перенаправляющая вывод в пзу, при попытке нарисовать за экраном
    ld b,64
    ld a,0
hook4:
    ld (hl),a
    inc hl
    djnz hook4
    ; генерация таблицы смещения знакоместа в трети по Y
    ; заполняет 192(256) байтов 3 группами по 8*8
    ; #00,#00,#00,#00,#00,#00,#00,#00, 
    ; #20,#20,#20,#20,#20,#20,#20,#20,
    ; #40,#40,#40,#40,#40,#40,#40,#40,
    ; ...
    ; #E0,#E0,#E0,#E0,#E0,#E0,#E0,#E0,
    ; #00,#00,#00,#00,#00,#00,#00,#00, 
    ; ...
    ; логика повторений в том что по inc(младший байт) можно будет извлечь атриббутах в ряду по y
    ld a,0; текущее значение
    ex af,af
    ld a,8*3; сколько групп по 8 байтов
loop3:
    ex af,af
    ld b,8
loop33:
    ld (hl),a
    inc hl
    djnz loop33
    add #20
    ex af,af
    dec a
    and a
    jr nz,loop3
    ; пропускаем 64 байта
    ;ld l,0
    ;inc h
    ; ловушка, перенаправляющая вывод в пзу, при попытке нарисовать за экраном
    ld b,64
    ld a,0
hook3:
    ld (hl),a
    inc hl
    djnz hook3
    ; генерация таблицы смещения байта в строке
    ; заполняет 256 байтов 32 нарастающими группами по 8 байт 
    ; 0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1, 2,2,2,2,2,2,2,2...
    ; логика повторений в том что по inc(младший байт) можно будет извлечь смещение
    ld a,0
loop2:
    ld b,8
loop22:
    ld (hl),a
    inc hl
    djnz loop22
    inc a
    cp 32
    jr nz,loop2    
    ; генерация таблицы смещения пиксела в байте
    ; заполняет 256 байтов повторяющимся паттерном 1,2,4,8,16,32,64,127,1,2..
pixel_bit:
    ld a,128
    ; snow effect
    ;ld a,208;128;208
    ld b,0
loop1:
    ld (hl),a
    rrc a
    inc hl
    djnz loop1
    ret

dir0    dec d
        dec d
        ret
dir1    dec d
        dec d
        inc e
        ret
dir2    dec d
        dec d
        inc e
        inc e
        ret
dir3    dec d
        inc e
        inc e
        ret
dir4    inc e
        inc e
        ret
dir5    inc e
        inc e
        inc d
        ret
dir6    inc e
        inc e
        inc d
        inc d
        ret
dir7    inc e
        inc d
        inc d
        ret
dir8    inc d
        inc d
        ret
dir9    inc d
        inc d
        dec e        
        ret
dir10   inc d
        inc d
        dec e
        dec e
        ret
dir11   inc d
        dec e
        dec e
        ret
dir12   dec e
        dec e
        ret
dir13   dec e
        dec e
        dec d
        ret
dir14   dec e
        dec e
        dec d
        dec d
        ret
dir15   dec e
        dec d
        dec d
        ret
      
end_file:
    display "code size: ", /d, end_file - begin_file
    ; savehob "pro06.$C", "pro06.C", begin_file, end_file - begin_file
    savesna "pro06.sna", begin_file
    savebin "pro06.C", begin_file, end_file - begin_file
    labelslist "pro06.l"
