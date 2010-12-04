
code1	segment

start:	mov	ax,seg top1
	mov	ss,ax
	mov	sp,offset top1  ; inicjowanie stosu

	mov	al,13h   ;tryb graficzny 320 x 200
	mov	ah,0 ; polecenie zmiany trybu
	int	10h

	mov	cs:[x],0
	mov	cs:[y],50
	mov	cs:[k],13

	mov	cx,100
l0:	push	cx

	;.........................	
	mov	cx,200
l1:	push	cx
	mov	al,byte ptr cs:[x]
	mov	cs:[k],al
	call	zapal_punkt
	inc	word ptr cs:[x]
	pop	cx
	loop	l1
	;.........................

	inc	word ptr cs:[y]
	mov	cs:[x],0

	pop	cx
	loop	l0




	xor	ax,ax
	int	16h  ; czekaj na klawisz

koniec:
	mov	al,3
	mov	ah,0 ; polecenie zmiany trybu
	int	10h

	mov	ax,04c00h  ; zakoncz program
	int	21h

;........................
x	dw	?
y	dw	?
k	db	?

zapal_punkt:
	mov	ax,0a000h  ; adres segmentu pamieci w trybie graficznym
	mov	es,ax
	mov	ax,cs:[y]
	mov	bx,320
	mul	bx  ; dx:ax = ax * bx  ->   ax= y*320
	add	ax, cs:[x]     ;ax - y*320 +x
	mov	bx,ax
	mov	al,cs:[k]
	mov	es:[bx],al
	ret
;........................



code1	ends


stos1	segment STACK
	dw	200 dup(?)   ;200 x slowo o dow. wartosci
top1	dw	?
stos1	ends

end start
