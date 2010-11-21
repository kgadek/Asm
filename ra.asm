.286
; Random Art generator
; autor: Konrad Gądek


dane1   segment ;____________________________________________________________
    errNoArg        db "Blad: nie podano argumentow programu.",10,13,'$'
    errBadArg       db "Blad: nieprawidlowe dane wejsciowe.",10,13,'$'
    errTooFewArg    db "Blad: za malo argumentow.",10,10,'$'
    errTooMuchArg   db "Blad: za duzo argumentow.",10,10,'$'
    tab             db  171 dup(0)  ; tablica wyjściowa wraz z CR/LF
                    db '$'
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
    debug_print2    proc near
        push ax
        push dx
        mov ah, 2h
        mov dx, 0ah
        int 21h
        mov dx, 0dh
        int 21h
        mov dx, '#'
        int 21h
        pop dx
        pop ax
        ret
    debug_print2    endp
    debug_print3    proc near
        push ax
        push dx
        mov dx, '*'
        mov ah, 2h
        int 21h
        pop dx
        pop ax
        ret
    debug_print3    endp
	wczytajBezSpacji proc near
WBS_wczytaj:	mov al, es:[si]				; wczytaj znak
				cmp al, ' '					; IF al = ' '
				jne WBS_wczytano
				add si, 1						;	SI = SI + 1
				jmp WBS_wczytaj					;	powtórz
WBS_wczytano:	ret							; zakończ
	wczytajBezSpacji endp
	printDX proc near
				push ax						; zapamiętaj wartości AX, BX, DX
				push bx
				push dx
				mov ax, 80h					; AX = (10000000)b
PDX_loop:		mov bx, ax					; BX = AX
				and ax, dx					; AX = AX & DX
				mov dx, '0'					; DX = '0'/'1'
				jz PDX_notOne
					mov dx, '1'
PDX_notOne:		mov ah, 2h
				int 21h
				mov ax, bx
				shr ax, 1					; AX >>= 1
				jnc PDX_loop				; IF AX != 0: powtórz
				pop dx						; przywróć wartość DX, BX, AX
				pop bx
				pop ax
				ret	
	printDX endp
    
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
				call wczytajBezSpacji		; pomiń spacje na początku
loop_A:         call debug_print2
                mov al, es:[si]             ; AL = input
                xor ah, ah                  ; AH = 0
                call debug_print1
                cmp al, ':'                 ; if AL = ':'
                jne if_ALneq58
                    call debug_print3
                    mov bx, 0                   ;   BX = 0
                    add si, 1                   ;   SI = SI + 1
                    loop loop_A                 ;   wczytaj do następnego segmentu
if_ALneq58:     cmp al, 0                   ; if AL = 0
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
                	jmp lA_operate              ;	JMP
if_ALle97:      cmp al, 'A'                 ; if AL < 'A' || AL > 'F'
                jl err_BadArg                   ;   bad input
                cmp al, 46h
                jg err_BadArg
                sub al, 'A'-10              ; AL = AL - 'A' + 10
lA_operate:     push bx                     ; zapamiętaj BX
                mov bx, 10h                 ; do bx: adres przetwarzanego elementu tablicy
                sub bx, cx
                mov dx, ds:[bx+di]          ; tab[16-CX] = 16*tab[16-CX] + AX
                shl dx, 4
                add dx, ax
                mov ds:[bx+di], dx
                pop bx                      ; przywróć BX
                add si, 1                   ; SI = SI + 1
                add bx, 1                   ; BX = BX + 1
                cmp bx, 2                   ; if BX > 2
                jg err_BadArg                   ;   bad input
                call debug_print1
                jmp loop_A                  ; JMP loop_A
lA_fin:         jmp fin
    
    
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


            ; === zakończ program
fin:            mov ax,04c00h               ; zakończ program kodem 0
                int 21h
code1   ends


stos1   segment STACK ;______________________________________________________
            dw 200 dup(?)
    top1    dw ?
stos1   ends

end start

