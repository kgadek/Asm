


code1	segment

start:	mov	ax,seg top1
	mov	ss,ax
	mov	sp,offset top1  ; inicjowanie stosu

	xor	ax,ax
	int	16h  ;czekaj na klawisz

	mov	al,3   ;tryb tekstowy 80 x 40 znakow
	mov	ah,0 ; polecenie zmiany trybu
	int	10h
	
	mov	ax,0b800h  ; adres segmentu pamieci w trybie tekstowym
	mov	es,ax

	mov	word ptr es:[0],8441h

	mov	word ptr es:[20*80*2 + 2*40
],7244h


	;mov	byte ptr es:[0],'A'
	;mov	byte ptr es:[1],00000100b
                                   ;yrgb

	xor	ax,ax
	int	16h  ;czekaj na klawisz

	mov	ax,04c00h  ; zakoncz program
	int	21h

code1	ends


stos1	segment STACK
	dw	200 dup(?)   ;200 x slowo o dow. wartosci
top1	dw	?
stos1	ends

end start
