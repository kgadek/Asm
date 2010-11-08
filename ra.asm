; Random Art generator
; autor: Konrad Gądek


dane1	segment
	errBrakArg	db "Blad: nie podano argumentow programu, podano ich niewlasciwa ilosc lub sa one niepoprawne.",10,13,'$'
tab db	171 dup(0)	; tablica wyjściowa wraz z CR/LF
	db '$'
inp db	16 dup(0)	; tablica wejściowa
skd db	0			; sklej jednostronnie dolną krawędź
skp db	0			; sklej jednostronnie prawą krawędź
skg db	0			; sklej jednostronnie górną krawędź
skl db	0			; sklej jednostronnie lewą krawędź
dane1	ends


code1	segment ;____________________________________________________________
start:
		; === inicjowanie
	mov	ax, seg top1			; SS:[SP] - segment stosu
	mov	ss, ax
	mov	sp, offset top1	; offset stosu -> SP
	mov ax, seg inp				; DS:[DI] - zapis do pamięci
	mov ds, ax
	mov di, offset inp
	mov si, 82h					; ES:[SI] - odczyt z pamięci (SI=82h - offset argumentów)

		; === Wczytywanie parametrów - ustawienia
	mov cl, es:80h				; CX=ilość bajtów argumentów
	xor ch, ch
	jcxz brak_arg				; nie ma argumentów - błąd

	xor bx,bx
	mov ah, 2h

		; === Pominięcie ew. spacji na początku
space_clean:
	mov dl,es:[si]
	cmp dl, 20h					; sprawdź, czy jest to spacja
	jne read_input
	add si, 1
	loop space_clean
	jcxz brak_arg				; argumentami były same spacje!

		; === Wczytywanie danych
read_input:

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
	mov dl,es:[si]
	cmp dl, 13
	je fin
	mov dx,'%'
	int 21h
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

