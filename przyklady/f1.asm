dane1	segment

txt1	db	'T'
	db	'o'
	db	" jest przyklad", 10, 13, '$'
txt2	db	"I jeszcze ja!", 10, 13, '$'
dane1	ends


code1	segment

start:	mov	ax,seg top1
	mov	ss,ax
	mov	sp,offset top1  ; inicjowanie stosu

	mov	ax,seg txt1
	mov	ds,ax
	mov	dx,offset txt1  ; ->  ds:dx = srting
	mov	ah,9   ;wypisz na ekranie string ds:dx
	int	21h

	mov	ax,seg txt1
	mov	ds,ax
	mov	dx,offset txt2  ; ->  ds:dx = srting
	mov	ah,9   ;wypisz na ekranie string ds:dx
	int	21h

	mov	dl,'$'
	mov	ah,2
	int	21h

	mov	ax,04c00h  ; zakoncz program
	int	21h

code1	ends


stos1	segment STACK
	dw	200 dup(?)   ;200 x slowo o dow. wartosci
top1	dw	?
stos1	ends

end start

