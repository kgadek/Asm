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
	
	mov dx, ax
	mov ah, 2h
	int 21h

	pop dx
	pop ax
	ret
debug_print1	endp


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
	mov al, es:[si]				; AX = input
	call debug_print1			; __dbg
	cmp ax, 3ah					; if AX = ':'
	jne lAi1
		mov bx, 0					; 	BX = 0
		add si, 1					; 	SI = SI + 1
		loop loop_A
lAi1:
	call debug_print1
	cmp ax, '0' 				; if AX < '0' || AX > 'f'
	jb err_BadArg				;	bad input
	cmp ax, 'f'
	ja err_BadArg
	call debug_print1
	cmp ax, 39h					; if AX <= '9'
	jb lAi2
		sub ax, 30h				; 	AX = AX - '0'
		jmp lA_operate			;	JMP
lAi2:
	call debug_print1
	cmp ax, 61h					; if AX >= 'a'
	jb lAi3
		sub ax, 57h				;	AX = AX - 'a' + 10
		jmp lA_operate			;	JMP
lAi3:
	cmp ax, 41h					; if AX < 'A' || AX > 'F'
	jb err_BadArg				;	bad input
	cmp ax, 46h
	ja err_BadArg
	sub ax, 37h					; AX = AX - 'A' + 10
lA_operate:
	mov dx, ds:[si]
	shl dx, 4
	add dx, ax
	mov ds:[si], dx
	add bx, 1
	cmp bx, 2
	ja err_BadArg
	cmp bx, 1
	je loop_A
	loop loop_A
	


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

