.286
; Random Art generator
; autor: Konrad Gądek


dane1   segment ;____________________________________________________________
    errNoArg        db "Blad: nie podano argumentow programu.",10,13,'$'
    errBadArg       db "Blad: nieprawidlowe dane wejsciowe.",10,13,'$'
    errTooFewArg    db "Blad: za malo argumentow.",10,10,'$'
    errTooMuchArg   db "Blad: za duzo argumentow.",10,10,'$'
    tab             db  231 dup(0)  ; tablica wyjściowa wraz z CR/LF
                    db '$'
    inp             db  16 dup(0)   ; tablica wejściowa
    skd             db  0           ; sklej jednostronnie dolną krawędź
    skp             db  0           ; sklej jednostronnie prawą krawędź
    skg             db  0           ; sklej jednostronnie górną krawędź
    skl             db  0           ; sklej jednostronnie lewą krawędź
    header          db  "+--[ RSA 1024]----+"
    footer          db  "+-----------------+"
    exch            db  " .o+=*BOX@%&#/^"
dane1   ends


code1   segment ;____________________________________________________________

    wczytajBezSpacji proc near ;.............................................
WBS_wczytaj:    mov al, es:[si]             ; wczytaj znak
                cmp al, ' '                 ; IF al = ' '
                jne WBS_wczytano
                    add si, 1                   ;   SI = SI + 1
                    jmp WBS_wczytaj             ;   powtórz
WBS_wczytano:   ret                         ; zakończ
    wczytajBezSpacji endp
    goUp proc near ;.........................................................
                sub bx, 2Ah                 ; BX = BX - 42 /przesuń się 2 wiersze wyżej/
                jns goUp_fin                ; IF BX < 0 /jeśli wyskoczyliśmy poza tablicę/
                    add bx, 15h                 ;   BX = BX + 21
                    push di                     ;   zapamiętaj DI oraz AX
					push ax
                    mov di, offset skg			;	DS:[DI] = zmienna sklej_górę
                    mov al, ds:[di]
                    cmp al, 0
					pop ax                      ;   przywróć AX i DI
                    pop di
                    jz goUp_fin                 ;   IF sklej_górę
                        add bx, 0A8h                ;   BX = BX + 8*21
goUp_fin:       add bx, 15h                 ; BX = BX + 21 /wróć wiersz wyżej/
                ret
    goUp endp
    goDown proc near ;.......................................................
                sub bx, 0BDh                ; BX = BX - 189
                js goDown_fin               ; IF BX > 0 /jeśli byliśmy w ostaniej linii/
                    sub bx, 15h                 ;   BX = BX - 21
                    push di                     ;   zapamiętaj DI i AX
					push ax
                    mov di, offset skd			;	DS:[DI] = zmienna sklej_dół
                    mov al, ds:[di]
                    cmp al, 0
					pop ax                      ;   przywróć AX i DI
                    pop di
                    jz goDown_fin               ;   IF sklej_dół
                        sub bx, 0A8h                ;   BX = BX - 8*21
goDown_fin:     add bx, 0D2h                ; BX = BX + 189 + 21 /wróć wiersz wyżej/
                ret
    goDown endp
    goRight proc near ;......................................................
                add bx, 1                   ; BX = BX + 1
                push bx						; zapamiętaj BX
                mov ax, bx					; AX = BX
                mov bl, 15h					; BL = 21
                div bl						; AL = AX div BL, AH = AX mod BL
                pop bx						; przywróć BX
                cmp ah, 12h                 ; IF BX == 18 (mod 21)
                jnz goRight_fin
                    sub bx, 1                   ;   BX = BX - 1
                    push di						;	zapamiętaj DI
                    mov di, offset skp			;	DS:[DI] = zmienna sklej_prawo
                    mov al, ds:[di]
                    pop di						;	przywróć DI
                    cmp al, 0                   ;   IF sklej_prawo
                    jz goRight_fin
                        sub bx, 10h                 ;   BX = BX - 16
goRight_fin:    ret
    goRight endp
    goLeft proc near ;.......................................................
                sub bx, 1                   ; BX = BX - 1
                push bx                     ; zapamiętaj BX
                mov ax, bx					; AX = BX
                mov bl, 15h					; BL = 21
                div bl						; AL = AX div BL, AH = AX mod BL
                pop bx						; przywróć BX
                cmp ah, 0                   ; IF BX == 0 (mod 21)
                jnz goLeft_fin
                    add bx, 1                   ;   BX = BX + 1
                    push di						;	zapamiętaj DI
                    mov di, offset skl			;	DS:[DI] = zmienna sklej_lewo
                    mov al, ds:[di]
                    pop di						;	przywróć DI
                    cmp al, 0					;	IF sklej_lewo
                    jz goLeft_fin
                        add bx, 10h                 ;   BX = BX + 16
goLeft_fin:     ret
    goLeft endp
    parseGroup proc near ;...................................................
                FOR rej, <AX,CX,DX>         ; zapamiętaj wartości AX,CX,DX
                    push rej
                ENDM
                mov cx,3                    ; CX=(0000 0000 0000 0011)b

parseGroup_loop:mov al, 1                   ; tab[BX] = tab[BX]+1
                add ds:[bx+di], al
                mov al, dl                  ; AL = DL & 3
                and al, 3
                shr dl, 1                   ; DL = DL >> 2
                shr dl, 1
                sub al, 2                   ; AL = AL - 2
                js parseGroup_g             ; IF AL > 0
                    call goDown                 ;   goDown
                    jmp parseGroup_gd       ; else
parseGroup_g:   call goUp                       ;   goUp
parseGroup_gd:  add al, 2                   ; AL = AL + 2
                and al, 1					; AL = AL & 1
                jz parseGroup_l             ; IF AL == 1 (mod 2)
                    call goRight                ;   goRight
                    jmp parseGroup_lp       ; else
parseGroup_l:   call goLeft                     ;   goLeft
parseGroup_lp:  shl cx, 1                   ; CX = CX << 2
                shl cx, 1
                cmp cx, 0FFh                ; IF CX < 255
                jl parseGroup_loop              ;   powtórz

                FOR rej, <DX,CX,AX>         ; przywróć wartości DX,CX,AX
                    pop rej
                ENDM
                ret
    parseGroup endp
    ;.......................................................................
    ;.......................................................................
    ;.......................................................................



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
loop_A:         mov al, es:[si]             ; AL = input
                xor ah, ah                  ; AH = 0
                cmp al, ':'                 ; if AL = ':'
                jne if_ALneq58
                    mov bx, 0                   ;   BX = 0
                    add si, 1                   ;   SI = SI + 1
                    loop loop_A                 ;   wczytaj do następnego segmentu
                    jmp err_TooMuchArg
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
                cmp al, 'F'
                jg err_BadArg
                sub al, 'A'-10              ; AL = AL - 'A' + 10
lA_operate:     push bx                     ; zapamiętaj BX
                mov bx, 10h                 ; w BX adres przetwarzanego elementu tablicy
                sub bx, cx					; BX = BX - CX
                mov dl, ds:[bx+di]          ; tab[16-CX] = 16*tab[16-CX] + AX
                shl dl, 1					; DL = DL << 4
                shl dl, 1
                shl dl, 1
                shl dl, 1
                add dl, al					; DL = DL + AL
                mov ds:[bx+di], dl			; tab[16-CX] = DL
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
                mov cx, 4                   ; CX = 4 /powtórz 4 razy/
loop_B:         call wczytajBezSpacji       ; wczytaj
                cmp al, 13                  ; IF AL = ENTER
                je err_TooFewArg                ;   bad input
                sub al, '0'					; AL = AL - '0'
                mov ds:[di], al             ; zapamiętaj wczytaną wartość
                add di, 1                   ; przesuń zapis o jedną pozycję w przód
                add si, 1                   ; odczytuj następną wartość
                loop loop_B                 ; powtórz

                call wczytajBezSpacji       ; wczytaj to, co pozostało
                cmp al, 13                  ; IF AL != ENTER
                	jne err_TooMuchArg          ;   bad input

                jmp fillTab
    
    
                    ; === Obsługa błędów
err_NoArg:      mov dx, offset errNoArg     ; DX = offset komunikatu błędu
                jmp err_common
err_BadArg:     mov dx, offset errBadArg
                jmp err_common
err_TooFewArg:  mov dx, offset errTooFewArg
                jmp err_common
err_TooMuchArg: mov dx, offset errTooMuchArg
err_common:     mov ah, 9                   ; wypisz komunikat o błędzie
                int 21h
                mov ax,04c01h               ; zakończ program kodem 1
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

                    ; === Wypełnij pierwszy i ostatni wiersz
                mov di, offset tab			; DS:[DI] = adres tablicy tab
                mov cx, 13h                 ; uzupełnianie LEN(str) razy
                cld                         ; w kierunku rosnących adresów
                mov ax, seg header          ; ES:[SI] = adres przeznaczenia
                mov es, ax
                mov si, offset header
                mov di, offset tab          ; DS:[DI] = adres źródła
                rep movsb                   ; przepisz

                mov cx, 13h                 ; uzupełnianie LEN(str) razy
                mov si, offset footer       ; ES:[SI] = adres przeznaczenia
                mov di, offset tab+210      ; DS:[DI+210] = adres źródła (ostatni wiersz)
                rep movsb                   ; przepisz

                    ; === Wypełnij tablicę zgodnie z algorytmem
parse:          mov di, offset tab          ; DS:[DI] = tablica wynikowa
                mov si, offset inp          ; ES:[SI] = tablica z danymi
                mov cx, 10h                 ; do przetworzenia jest 16 bloków
                mov bx, 114                 ; ustaw wskaźnik tablicy BX na środek
                xor dx, dx                  ; czyść bufor danych DX
parse_loop:     mov dl, es:[si]             ; wczytaj blok
                add si, 1                   ; przygotuj się do wczytania następnego
                call parseGroup             ; wywołaj parseGroup(DX=dane_we)
                loop parse_loop
				push bx						; zapamiętaj ostatnią pozycję

                    ; === Zamień ilość wejść na odpowiedni znak ASCII
                mov cx, 9                   ; CX = 9 /Przetwórz 9 wierszy tablicy/
                mov ax, seg exch            ; DS:[BP+SI] = adres tablicy przemiany
                mov ds, ax
                mov si, offset exch
                mov di, offset tab          ; DS:[BX+DI] = adres komórek tablicy
exchange_loop:  add di, 15h					; DI = DI + 21 /następny wiersz/
                mov bx, 11h                 ; dla każdej kolumny CX=17..1
exch_inn_loop:  mov dl, ds:[bx+di]			; DL = tab[21*w + CX]
                cmp dl, 0Eh                 ; IF DL > 14
                jle exch_nosub
                	mov dl, 0Eh            		;   DL = 14
exch_nosub:     mov bp, dx                  ; BP = DX
                mov dl, ds:[bp+si]          ; DS:[BX+DI] = DS:[BP+SI] /wpisz odpowiedni znak/
                mov ds:[bx+di], dl
                sub bx, 1                   ; kolejna kolumna
                jnz exch_inn_loop
                loop exchange_loop

	          	mov di, offset tab          ; DS:[DI] = tablica wynikowa
				pop bx						; wczytaj ostatnią pozycję...
				mov al, 'E'					; ...i wpisz na to miejsce 'E'
				mov ds:[bx+di], al
				mov al, 'S'					; na pierwszą pozycję wpisz 'S'
				mov ds:[di+114],al 

printTab:       mov dx, offset tab          ; DS:[DX] = adres tablicy wyjściowej
                mov ah, 9                   ; wypisz za pomocą funkcji DOS-a 9h
                int 21h

                    ; === zakończ program
fin:            mov ax,04c00h               ; zakończ program kodem 0
                int 21h
    ;.......................................................................
    ;.......................................................................
    ;.......................................................................
code1   ends


stos1   segment STACK ;______________________________________________________
            dw 400 dup(?)
    top1    dw ?
stos1   ends

end start

