    device zxspectrum48   
disp equ #4000
attr equ #5800      
    org #6100
begin_file:
    di ; запрещаем прерывания
    ld sp,#6100 ; устанавливаем дно стека
    ld a,7
    ld b,2
    sub b; a-b->a
    ; a = 6
    cp 6; a ? this
    jr z,euqal; a = xx, black
    jr c,less; a < xx, blue
    jr nc,more; a > xx, red, можно заменить на просто "jr more"   
    di:halt
euqal:
    ; black border
    ld a,0:out (#fe),a 
    di:halt

less:
    ; blue border
    ld a,1:out (#fe),a 
    di:halt
    
more:
    ; red border
    ld a,2:out (#fe),a 
    di:halt

end_file:
    display "code size: ", /d, end_file - begin_file
    ; savehob "pro08.$C", "pro08.C", begin_file, end_file - begin_file
    ; savesna "pro08.sna", begin_file
    savebin "pro08.C", begin_file, end_file - begin_file
    savetap "pro08.tap", begin_file 
    ; labelslist "pro08.l"
