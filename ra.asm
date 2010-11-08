; Random Art generator
; autor: Konrad Gądek


dane1	segment
	errBrakArg	db "Blad: nie podano argumentow programu lub sa one niepoprawne.",10,13,'$'
dane1	ends


code1	segment ;____________________________________________________________
start:
		; === inicjowanie stosu
	mov	ax,seg top1		; segment stosu -> SS
	mov	ss,ax
	mov	sp,offset top1	; offset stosu -> SP

		; === Wczytywanie parametrów - ustawienia
	mov cl,es:80h				; CX=ilość bajtów argumentów
	xor ch,ch
	jcxz brak_arg				; jeśli nie ma argumentów - błąd
	sub cx,1					; CX--
	mov si,82h					; SI = 82h (offset argumentów)
	mov ah,2h					; wyświetlanie argumentów
	xor bx, bx					; czyszczenie licznika spacji

		; === Pominięcie ew. spacji na początku
space_clean:
	mov dl,es:[si]
	cmp dl, 20h					; sprawdź, czy jest to spacja
	jne print
	add si, 1
	loop space_clean
	jcxz brak_arg				; argumentami były same spacje!
	
		; === Wyświetlenie napisu
print:							; 	WHILE(CX!=0)
	mov dl,es:[si]				;		DL przyjmuje kolejne znaki parametrów z wiersza poleceń
	cmp bx, 0					;		jeśli BX=0 to wyświetl
	je print_show
	cmp dl, 20h
	je print_cont
	xor bx, bx
print_show:
	cmp dl, 20h					; 		jeśli wyświetlam spacje to BX=1
	jne print_show_print
	mov bx, 1
print_show_print:
	int 21h
print_cont:
	add si, 1
	loop print
	jcxz fin					; zakończ program


		; === Błąd: brak argumentów
brak_arg:						;
	mov ax, seg errBrakArg		; 	DS = segment komunikatu błędu
	mov ds, ax
	mov dx, offset errBrakArg	;	DX = offset komunikatu błędu
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

