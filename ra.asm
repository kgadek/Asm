.286
; Random Art generator
; autor: Konrad Gądek


dane1   segment ;____________________________________________________________
    errNoArg        db "Blad: nie podano argumentow programu.",10,13,'$'
    errBadArg       db "Blad: nieprawidlowe dane wejsciowe.",10,13,'$'
    errTooFewArg    db "Blad: za malo argumentow.",10,10,'$'
    errTooMuchArg   db "Blad: za duzo argumentow.",10,10,'$'
    tab             db  231 dup(' ')  ; tablica wyjściowa wraz z CR/LF
    inp             db  16 dup(0)   ; tablica wejściowa
    skd             db  0           ; sklej jednostronnie dolną krawędź
    skp             db  0           ; sklej jednostronnie prawą krawędź
    skg             db  0           ; sklej jednostronnie górną krawędź
    skl             db  0           ; sklej jednostronnie lewą krawędź
dane1   ends


code1   segment ;____________________________________________________________
    debug_print1    proc near
        push ax
        push dx
        
        xor dx, dx
        mov dl, al
        mov ah, 2h
        int 21h
    
        pop dx
        pop ax
        ret
    debug_print1    endp
    wczytajBezSpacji proc near
WBS_wczytaj:    mov al, es:[si]             ; wczytaj znak
                cmp al, ' '                 ; IF al = ' '
                jne WBS_wczytano
                add si, 1                       ;   SI = SI + 1
                jmp WBS_wczytaj                 ;   powtórz
WBS_wczytano:   ret                         ; zakończ
    wczytajBezSpacji endp
    printDX proc near
                push ax                     ; zapamiętaj wartości AX, BX, DX, CX
                push bx
                push dx
                push cx
                mov cx, dx
                mov ax, 1                   ; AX = 1
PDX_loop:       mov dx, cx
                mov bx, ax                  ; BX = AX
                and ax, dx                  ; AX = AX & DX
                mov dx, '0'                 ; DX = '0'/'1'
                jz PDX_notOne
                mov dx, '1'
PDX_notOne:     mov ah, 2h
                int 21h
                mov ax, bx
                shl ax, 1                   ; AX >>= 1
                jnc PDX_loop                ; IF AX != 0: powtórz
                pop cx                      ; przywróć wartość DX, BX, AX
                pop dx
                pop bx
                pop ax
                ret 
    printDX endp
    PRINTF MACRO str
                push ax                     ; zapamiętaj wartości AX, DX
                push dx
                mov ah, 2h                  ; wypisywanie znaków
                FORC arg,str                ; wypisz każdy znak z łańcucha
                    mov dx,'&arg'
                    int 21h
                ENDM
                mov dx,10                   ; Wyświetl enter
                int 21h
                mov dx,13
                int 21h
                pop dx                      ; przywróć wartości DX, AX
                pop ax
    ENDM
    PRINTREG MACRO reg
                push ax                     ; zapamiętaj wartości AX, DX
                push dx
                mov dx,reg
                mov ah, 2h                  ; wypisywanie znaków
                int 21h
                pop dx                      ; przywróć wartości DX, AX
                pop ax
    ENDM
    
                    ; === rozgrzewka
start:          mov ax, seg top1            ; SS:[SP] - segment stosu
                mov ss, ax
                mov sp, offset top1
                mov ax, seg inp             ; DS:[DI] - zapis do pamięci
                mov ds, ax
                mov di, offset inp
                mov si, 82h                 ; ES:[SI] - odczyt arg. z pamięci
            
                    ; === Wczytywanie parametrów - ustawienia
                xor ch, ch                  ; CH = 0
                mov cl, es:80h              ; CX = ilość bajtów argumentów
                jcxz err_noArg_posr         ; nie ma argumentów - błąd
        
                    ; === Wczytywanie parametrów - hash
                mov cx, 10h                 ; wczytujemy 16 elementów
                call wczytajBezSpacji       ; pomiń spacje na początku
loop_A:         PRINTF <_>
                mov al, es:[si]             ; AL = input
                xor ah, ah                  ; AH = 0
                call debug_print1
                cmp al, ':'                 ; if AL = ':'
                jne if_ALneq58
                    mov bx, 0                   ;   BX = 0
                    add si, 1                   ;   SI = SI + 1
                    loop loop_A                 ;   wczytaj do następnego segmentu
if_ALneq58:     cmp al, 13                   ; if AL = ENTER
                jne if_ALneq0
                    jmp err_TooFewArg           ;   bad input
err_noArg_posr: jmp err_noArg
if_ALneq0:      cmp al, ' '                 ; if AL = ' '
                jne if_ALneq32
                    cmp cx, 1                   ;   if CX != 1
                    jne err_BadArg              ;       bad input
                        jmp lA_fin
if_ALneq32:     cmp al, '0'                 ; if AL < '0' || AL > 'f'
                jl err_BadArg                   ;   bad input
                cmp al, 'f'
                jg err_BadArg
                cmp al, '9'                 ; if AL <= '9'
                jg if_ALgt57
                    sub al, '0'                 ;   AL = AL - '0'
                    jmp lA_operate              ;   JMP
if_ALgt57:      cmp al, 'a'                 ; if AL >= 'a'
                jl if_ALle97
                    sub al, 'a'-10              ;   AL = AL - 'a' + 10
                    jmp lA_operate              ;   JMP
if_ALle97:      cmp al, 'A'                 ; if AL < 'A' || AL > 'F'
                jl err_BadArg                   ;   bad input
                cmp al, 46h
                jg err_BadArg
                sub al, 'A'-10              ; AL = AL - 'A' + 10
lA_operate:     push bx                     ; zapamiętaj BX
                mov bx, 0fh                 ; do bx: adres przetwarzanego elementu tablicy
                sub bx, cx
                PRINTF <A>
                mov dl, ds:[bx+di]          ; tab[16-CX] = 16*tab[16-CX] + AX
                call printDX
                shl dl, 4
                add dl, al
                PRINTF <B>
                call printDX
                mov ds:[bx+di], dl
                pop bx                      ; przywróć BX
                add si, 1                   ; SI = SI + 1
                add bx, 1                   ; BX = BX + 1
                cmp bx, 2                   ; if BX > 2
                jg err_BadArg                   ;   bad input
                jmp loop_A                  ; JMP loop_A
lA_fin:         
                
                    ; === Wczytywanie parametrów - sklejenia
                mov di, offset skd          ; DS:[DI] - miejsce zapisu parametrów
                xor ax, ax                  ; AX = 0
                mov cx, 4                   ; CX = 4
loop_B:         call wczytajBezSpacji       ; wczytaj
                PRINTF <A>
                cmp al, 13                  ; IF AL = ENTER
                je err_TooFewArg                ;   bad input
                sub al, '0'
                mov dx, ax                  ; wyświetl
                call printDX
                mov ds:[di], al             ; zapamiętaj wczytaną wartość
                add di, 1                   ; przesuń zapis o jedną pozycję w przód
                add si, 1                   ; odczytuj następną wartość
                loop loop_B                 ; powtórz

                call wczytajBezSpacji       ; wczytaj co pozostało
                cmp al, 13                  ; IF AL != ENTER
                jne err_TooMuchArg              ;   bad input


                jmp fillTab
    
    
            ; === Obsługa błędów
err_NoArg:      mov dx, offset errNoArg     ;   DX = offset komunikatu błędu
                jmp err_common
err_BadArg:     mov dx, offset errBadArg
                jmp err_common
err_TooFewArg:  mov dx, offset errTooFewArg
                jmp err_common
err_TooMuchArg: mov dx, offset errTooMuchArg

err_common:     mov ax, seg errNoArg        ;   DS = segment komunikatu błędu
                mov ds, ax
                mov ah, 9                   ;   wypisz komunikat o błędzie
                int 21h


            ; === Wypełnij tablicę
fillTab:        mov di, offset tab          ; DS:[DI] = adres tablicy tab
                mov cx, 0bh                 ; Wypełnij część wspólną wszystkich wierszy
fillK:          mov al, '|'                 ; wpisz znak | ...
                mov ds:[di], al             ; ... w pierwszą
                mov ds:[di+18], al          ; ... oraz ostatnią kolumnę
                mov al, 10                  ; dopisz CR
                mov ds:[di+19], al
                mov al, 13                  ; dopisz LF
                mov ds:[di+20], al
                add di, 15h                 ; przejdź do następnego wiersza
                loop fillK
				mov di, offset tab

 	  			mov di, offset tab          ; DS:[DI] = adres tablicy tab
                mov bx, 2                   ; Wypełnij górny i dolny wiersz
fillGD:             mov al, '+'             ; wypełnij wiersz: +-----------------+
					mov ds:[di], al				;	wpisz +
					mov cx, 12h
                    mov al, '-'					;	wpisz -
fillW:              add di,1
					mov ds:[di], al
                    loop fillW
					mov al, '+'					;	wpisz +
					mov ds:[di], al
                    add di, 0C0h            ; przeskocz do dolnego wiersza
                    sub bx, 1
                    cmp bx, 0               ; IF BX != 0
                jnz fillGD                      ;   powtórz dla dolnego wiersza


                PRINTF <#>
printTab:       mov cx, 0E7h                ; wypisz każdą komórkę tabeli
                mov di, offset tab
                mov ah, 2h
				xor dx, dx
printLoop:      mov dl, ds:[di]             ; wypisz znak znajdujący się w tabeli               
                int 21h
                add di, 1                   ; przejdź na następny element i powtórz
                loop printLoop


            ; === zakończ program
fin:            mov ax,04c00h               ; zakończ program kodem 0
                int 21h
code1   ends


stos1   segment STACK ;______________________________________________________
            dw 200 dup(?)
    top1    dw ?
stos1   ends

end start

