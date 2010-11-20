
code1	segment

start:	mov	ax,seg top1
	mov	ss,ax
	mov	sp,offset top1  ; inicjowanie stosu


	;otworz	
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset nazwa
	mov	al,0  ;tylko do odczytu
	mov	ah,3dh   ;otworz
	int	21h ; ax <- uchwyt
	mov	word ptr cs:[uchwyt],ax

	;odczytaj
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset buf1
	mov	bx,word ptr cs:[uchwyt]	
	mov	cx,90  ;ilosc bajtow do czytania
	mov	ah,3fh
	int	21h


	;zamknij	
	mov	bx,word ptr cs:[uchwyt]
	mov	ah,3eh  ; zamknij
	int	21h	


	;wypisz
	mov	ax,cs
	mov	ds,ax
	mov	dx,offset buf1
	mov	ah,9   ;wypisz na ekranie string ds:dx
	int	21h


	mov	ax,04c00h  ; zakoncz program
	int	21h

nazwa	db	"test.txt", 0
uchwyt	dw	?
buf1	db 	100 dup('$')

code1	ends


stos1	segment STACK
	dw	200 dup(?)   ;200 x slowo o dow. wartosci
top1	dw	?
stos1	ends

end start
