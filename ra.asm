.286
; Random Art generator
; autor: Konrad Gądek


dane1	segment ;____________________________________________________________

	errNoArg	db "Blad: nie podano argumentow programu.",10,13,'$'
	errBadArg	db "Blad: nieprawidlowe dane wejsciowe.",10,13,'$'
	errTooFewArg	db "Blad: za malo argumentow.",10,10,'$'
	errTooMuchArg	db "Blad: za duzo argumentow.",10,10,'$'
tab db	171 dup(0)	; tablica wyjściowa wraz z CR/LF
	db '$'
inp db	16 dup(0)	; tablica wejściowa
skd db	0			; sklej jednostronnie dolną krawędź
skp db	0			; sklej jednostronnie prawą krawędź
skg db	0			; sklej jednostronnie górną krawędź
skl db	0			; sklej jednostronnie lewą krawędź
dane1	ends


code1	segment ;____________________________________________________________

debug_print1	proc near
	push ax
	push dx
	
	xor dx, dx
	mov dl, al
	mov ah, 2h
	int 21h

	pop dx
	pop ax
	ret
debug_print1	endp
debug_print2	proc near
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
debug_print2	endp
debug_print3	proc near
	push ax
	push dx
	mov dx, '*'
	mov ah, 2h
	int 21h
	pop dx
	pop ax
	ret
debug_print3	endp


start:
		; === rozgrzewka
	mov	ax, seg top1			; SS:[SP] - segment stosu
	mov	ss, ax
	mov	sp, offset top1			; offset stosu -> SP
	mov ax, seg inp				; DS:[DI] - zapis do pamięci
	mov ds, ax
	mov di, offset inp
	mov si, 82h					; ES:[SI] - odczyt z pamięci (SI=82h - offset argumentów)

		; === Wczytywanie parametrów - ustawienia
	xor ch, ch
	mov cl, es:80h				; CX=ilość bajtów argumentów
	jcxz err_noArg				; nie ma argumentów - błąd

	mov cx, 10h					; startujemy wczytywanie do tablicy
loop_A:
	call debug_print2
	mov al, es:[si]				; AL = input
	xor ah, ah
	call debug_print1
	cmp al, ':' 				; if AX = ':'
	jne lAi1
lAi1b:
		call debug_print3
		mov bx, 0					; 	BX = 0
		add si, 1					; 	SI = SI + 1
		jmp loop_A
lAi1:
	cmp al, '0' 				; if AX < '0' || AX > 'f'
	jb err_BadArg				;	bad input
	cmp al, 'f'
	jg err_BadArg
	cmp al, '9'					; if AX <= '9'
	jle lAi2
		sub al, '0'				; 	AX = AX - '0'
		jmp lA_operate			;	JMP
lAi2:
	cmp al, 'a'					; if AX >= 'a'
	jge lAi3
		sub al, 57h				;	AX = AX - 'a' + 10
		jmp lA_operate			;	JMP
lAi3:
	cmp al, 'A'					; if AX < 'A' || AX > 'F'
	jb err_BadArg				;	bad input
	cmp al, 46h
	ja err_BadArg
	sub al, 37h					; AX = AX - 'A' + 10
lA_operate:
	mov dx, ds:[si]				; tab[SI] = 16*tab[SI] + AX
	shl dx, 4
	add dx, ax
	mov ds:[si], dx
	add si, 1					; SI = SI + 1
	add bx, 1					; BX = BX + 1
	cmp bx, 2					; if BX > 2
	jg err_BadArg				;	bad input
	call debug_print1			; if BX < 2
	jl loop_A					;	JMP
	loop loop_A					; if BX == 2
								;	LOOP

	jmp fin


		; === Błąd: brak argumentów
err_NoArg:						;
	mov dx, offset errNoArg		;	DX = offset komunikatu błędu
	jmp err_cont
err_BadArg:						;
	mov dx, offset errBadArg	;	DX = offset komunikatu błędu
	jmp err_cont
err_TooFewArg:					;
	mov dx, offset errTooFewArg	;	DX = offset komunikatu błędu
	jmp err_cont
err_TooMuchArg:					;
	mov dx, offset errTooMuchArg;	DX = offset komunikatu błędu
err_cont:
	mov ax, seg errNoArg		; 	DS = segment komunikatu błędu
	mov ds, ax
	mov ah, 9					;	wypisz komunikat o błędzie
	int 21h

		; === zakończ program
fin:
	mov	ax,04c00h
	int	21h
code1	ends


stos1	segment STACK ;______________________________________________________
top1	dw ?
stos1	ends
end start

