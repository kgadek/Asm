
code1	segment

start:	mov	ax,seg top1
	mov	ss,ax
	mov	sp,offset top1  ; inicjowanie stosu

	xor	ax,ax
	int	16h  ;czekaj na klawisz

	mov	al,3   ;tryb tekstowy 80 x 24 znakow
	mov	ah,0 ; polecenie zmiany trybu
	int	10h
	
	mov	ax,0b800h  ; adres segmentu pamieci w trybie tekstowym
	mov	es,ax


	mov	bx,5*80*2 + 2*40

l1:	mov	byte ptr es:[bx],'*'
	mov	byte ptr es:[bx+1],0fh

	push	bx
	xor	ax,ax
	int	16h  ;czekaj na klawisz
	pop	bx

	in	al,60h

	cmp	al,1  ; czy klawisz to Esc?
	jz	koniec

	cmp	al,75 ; lewo
	jnz	next1
	sub	bx,2
next1:

	cmp	al,77 ; prawo
	jnz	next2
	add	bx,2
next2:


	cmp	al,72 ; up
	jnz	next3
	sub	bx,80*2
next3:

	cmp	al,80 ; down
	jnz	next4
	add	bx,80*2
next4:


	jmp	l1


koniec:
	mov	ax,04c00h  ; zakoncz program
	int	21h

code1	ends


stos1	segment STACK
	dw	200 dup(?)   ;200 x slowo o dow. wartosci
top1	dw	?
stos1	ends

end start
