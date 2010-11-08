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
	sub cx,1					; 	CX--
	mov bx,82h					; 	BX = 82h (offset argumentów)

		; === Pominięcie ew. spacji na początku
space_clean:
	mov dl,es:[bx]
	cmp dl, 0020h				; sprawdź, czy jest to spacja
	jne print
	add bx, 1
	loop space_clean
	jcxz brak_arg				; argumentami były same spacje!
	
		; === Wyświetlenie napisu
print:
	mov ah,2h					; 	wyświetlanie argumentów
petla:							; 	WHILE(CX!=0) {
	mov dl,es:[bx]				;		DL przyjmuje kolejne znaki parametrów z wiersza poleceń
	int 21h						;		wyświetl
	add bx,1					;		zwiększ offset BX
	loop petla					; 	}
	jcxz fin					; }


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

