; Random Art generator
; autor: Konrad Gądek


dane1	segment
tekstA	db "Mam plan!$"
tekstB	db 10,13,"Wykonam go sam!",10,13,'$'
dane1	ends


code1	segment
start:
		; === inicjowanie stosu
	mov	ax,seg top1		; segment stosu -> SS
	mov	ss,ax
	mov	sp,offset top1	; offset stosu -> SP

		; === Wyświetlenie napisu
	mov bp, ds
	lea dx,[bp+80h]
	in ax,dx
	mov dl,ah
	mov ah, 2
	int 21h

		; === zakoncz program
	mov	ax,04c00h
	int	21h
code1	ends


stos1	segment STACK
top1	dw ?
stos1	ends

end start

