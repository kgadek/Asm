; Random Art generator
; autor: Konrad Gądek


dane1	segment
	errBrakArg	db "Blad: nie podano argumentow programu lub sa one niepoprawne.",10,13,'$'
dane1	ends


code1	segment
start:
		; === inicjowanie stosu
	mov	ax,seg top1		; segment stosu -> SS
	mov	ss,ax
	mov	sp,offset top1	; offset stosu -> SP

		; === Wyświetlenie napisu
	mov cl,es:80h		; CX=ilość bajtów argumentów
	xor ch,ch
	jcxz brak_arg		; jeśli CX==0 to skocz do brak_arg
	sub cx,1
	mov bx,82h
	mov ah,2h			; wyświetlanie argumentów
petla:					; WHILE(CX!=0) {
	mov dl,es:[bx]
	int 21h
	add bx,1
	loop petla			; }
	jcxz fin
		; === Błąd: brak argumentu
brak_arg:
	mov ax, seg errBrakArg
	mov ds, ax
	mov dx, offset errBrakArg
	mov ah, 9
	int 21h

fin:	; === zakończ program
	mov	ax,04c00h
	int	21h
code1	ends


stos1	segment STACK
top1	dw ?
stos1	ends

end start

