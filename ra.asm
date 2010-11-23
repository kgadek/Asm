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
					db '$'
    inp             db  16 dup(0)   ; tablica wejściowa
    skd             db  0           ; sklej jednostronnie dolną krawędź
    skp             db  0           ; sklej jednostronnie prawą krawędź
    skg             db  0           ; sklej jednostronnie górną krawędź
    skl             db  0           ; sklej jednostronnie lewą krawędź
	header			db	"+--[ RSA 1024]----+"
	footer			db	"+-----------------+"
	exch			db	" .o+=*BOX@%&#/^"
dane1   ends


code1   segment ;____________________________________________________________
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
				PRINTF <wczBezSpacji>
WBS_wczytaj:    mov al, es:[si]             ; wczytaj znak
				PRINTF <wczBezSpacjiLoop>
                cmp al, ' '                 ; IF al = ' '
                jne WBS_wczytano
                add si, 1                       ;   SI = SI + 1
                jmp WBS_wczytaj                 ;   powtórz
WBS_wczytano:   ret                         ; zakończ
    wczytajBezSpacji endp
    printDX proc near
				FOR rej, <AX,BX,CX,DX>		; zapamiętaj wartości AX,BX,CX,DX
					push rej
				ENDM
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
				FOR rej, <DX,CX,BX,AX>		; przywróć wartości DX,CX,BX,AX
					pop rej
				ENDM
                ret 
    printDX endp
    PRINTREG MACRO reg
                push ax                     ; zapamiętaj wartości AX, DX
                push dx
                mov dx,reg
                mov ah, 2h                  ; wypisywanie znaków
                int 21h
                pop dx                      ; przywróć wartości DX, AX
                pop ax
    ENDM
	goUp proc near
				PRINTF <GOUP>
				sub bx, 2Ah					; BX = BX - 42 /przesuń się 2 wiersze wyżej/
				jns goUp_fin				; IF BX < 0 /jeśli wyskoczyliśmy poza tablicę/
					add bx, 15h					;	BX = BX + 21
					push di						;	zapamiętaj DI
					mov di, offset skg
					mov al, ds:[di]
					cmp al, 0
					pop di						;	przywróć DI
					jz goUp_fin					;	IF sklej_górę
						add bx, 0A8h				;	BX = BX + 8*21
goUp_fin:		add bx, 15h					; BX = BX + 21 /wróć wiersz wyżej/
				PRINTF <GOUP_DONE>
				ret
	goUp endp
	goDown proc near
				PRINTF <GODOWN>
				sub bx, 0BDh				; BX = BX - 189
				js goDown_fin				; IF BX > 0 /jeśli byliśmy w ostaniej linii/
					sub bx, 15h					;	BX = BX - 21
					push di						;	zapamiętaj DI
					mov di, offset skd
					mov al, ds:[di]
					cmp al, 0
					pop di						;	przywróć DI
					jz goDown_fin				;	IF sklej_dół
						sub bx, 0A8h				;	BX = BX - 8*21
goDown_fin:		add bx, 0D2h				; BX = BX + 189 + 21 /wróć wiersz wyżej/
				PRINTF <GODOWN_DONE>
				ret
	goDown endp
	goRight proc near
				PRINTF <GORIGHT>
				add bx, 1					; BX = BX + 1
				push bx						; IF BX % 21 = 18
				mov ax, bx
				mov bl, 15h
				div bl
				pop bx
				cmp bx, 12h
				jnz goRight_fin
					sub bx, 1					;	BX = BX - 1
					push di						;	IF SKP
					mov di, offset skp
					mov al, ds:[di]
					pop di
					cmp al, 0
					jz goRight_fin
						sub bx, 10h					;	BX = BX - 16
goRight_fin:	PRINTF <GORIGHT_DONE>
				ret
	goRight endp
	goLeft proc near
				PRINTF <GOLEFT>
				sub bx, 1					; BX = BX - 1
				push bx						; IF BX % 21 = 0
				mov ax, bx
				mov bl, 15h
				div bl
				pop bx
				jnz goLeft_fin
					add bx, 1					;	BX = BX + 1
					push di						; IF SKL
					mov di, offset skl
					mov al, ds:[di]
					pop di
					cmp al, 0
					jz goLeft_fin
						add bx, 10h					;	BX = BX + 16
goLeft_fin:		PRINTF <GOLEFT_DONE>
				ret
	goLeft endp
	parseGroup proc near
				PRINTF <Z>
				FOR rej, <AX,BX,CX,DX>		; zapamiętaj wartości AX,BX,CX,DX
					push rej
				ENDM
				mov cl,3					; CL=(0000 0011)b

parseGroup_loop:mov al, 1					; tab[BX] = tab[BX]+1
				PRINTF <Y>
				add ds:[bx+di], al
				mov al, cl					; AL = CL & DL
				and al, dl
				sub al, 2h					; AL = AL - 2
				pushf
				js parseGroup_g				; IF AL > 0
				call goDown						;	goDown
				jmp parseGroup_g			; else
parseGroup_g:	call goUp						;	goUp
parseGroup_gd:	popf
				jp parseGroup_l				; IF AL!=0 (mod 2)
				call goRight					;	goRight
				jmp parseGroup_lp			; else
parseGroup_l:	call goLeft						;	goLeft
parseGroup_lp:	shl cl, 2					; CL = CL<<2
				cmp cl, 0
				PRINTF <X>
				jnz parseGroup_loop			; powtórz

				FOR rej, <DX,CX,BX,AX>		; przywróć wartości DX,CX,BX,AX
					pop rej
				ENDM
				ret							; koniec
	parseGroup endp
    
                    ; === rozgrzewka
start:          
				mov ax, seg top1            ; SS:[SP] - segment stosu
                mov ss, ax
                mov sp, offset top1
				PRINTF <START>
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
					PRINTF <uno>
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
lA_fin:         PRINTF <KONIEC_IN>
                
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
err_NoArg:      mov dx, offset errNoArg     ; DX = offset komunikatu błędu
                jmp err_common
err_BadArg:     mov dx, offset errBadArg
                jmp err_common
err_TooFewArg:  mov dx, offset errTooFewArg
                jmp err_common
err_TooMuchArg: mov dx, offset errTooMuchArg

err_common:     mov ah, 9                   ; wypisz komunikat o błędzie
                int 21h
				mov ax,04c01h              	; zakończ program kodem 1
                int 21h


            ; === Wypełnij tablicę
fillTab:        PRINTF <FILL_TAB>
				mov di, offset tab          ; DS:[DI] = adres tablicy tab
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

					; === Wypełnij pierwszy wiersz
				mov cx, 13h					; uzupełnianie LENGTH(str) razy
				cld							; w kierunku rosnących adresów
				mov ax, seg header			; ES:[SI] = adres przeznaczenia
				mov es, ax
				mov si, offset header
				mov di, offset tab			; DS:[DI] = adres źródła
				rep movsb					; przepisz

					; === Wypełnij ostatni wiersz
				mov cx, 13h					; uzupełnianie LENGTH(str) razy
				mov si, offset footer		; ES:[SI] = adres przeznaczenia
				mov di, offset tab+210		; DS:[DI+210] = adres źródła (ostatni wiersz)
				rep movsb					; przepisz

				PRINTF <PREPARSE>

					; === Wypełnij tablicę zgodnie z algorytmem
parse:			mov di, offset tab			; DS:[DI] = tablica wynikowa
				mov si, offset inp			; ES:[SI] = tablica z danymi
				mov cx, 10h					; do przetworzenia jest 16 bloków
				mov bx, 114					; ustaw wskaźnik tablicy BX na środek
				xor dx, dx					; czyść bufor danych DX
parse_loop:		mov dl, es:[si]				; wczytaj blok
				PRINTF <INPARSELOOP>
				add si, 1					; przygotuj się do wczytania następnego
				call parseGroup				; wywołaj parseGroup(DX=dane_we)
				loop parse_loop


					; === Zamień ilość wejść na odpowiedni znak ASCII
				mov cx, 9					; CX = 9 /Przetwórz 9 wierszy tablicy/
				mov ax, seg exch			; DS:[BP+SI] = adres tablicy przemiany
				mov ds, ax
				mov si, offset exch
				mov di, offset tab			; DS:[BX+DI] = adres komórek tablicy
exchange_loop:	add di, 15h
				mov bx, 11h					; dla każdej kolumny 1..17 (w odwrotnej kolejności)
exch_inn_loop:	mov dl, ds:[bx+di]
				cmp dl, 0Eh					; IF DL > 14
				jle exch_nosub
				mov dl, 0Eh						;	DL = 14
exch_nosub:		mov bp, dx
				mov dl, ds:[bp+si]
				mov ds:[bx+di], dl
				sub bx, 1					; kolejna kolumna
				jnz exch_inn_loop
				loop exchange_loop

                PRINTF <#>
printTab:		mov dx, offset tab			; DS:[DX] = adres tablicy wyjściowej
				mov ah, 9					; wypisz za pomocą funkcji DOS-a 9h
				int 21h


            ; === zakończ program
fin:            PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				PRINTF </>
				mov ax,04c00h               ; zakończ program kodem 0
                int 21h
code1   ends


stos1   segment STACK ;______________________________________________________
            dw 400 dup(?)
    top1    dw ?
stos1   ends

end start

