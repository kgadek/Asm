	KarpRabin proc near
							; rejestry:
							;	AX Sy
							;	BX i
							;	CX n-m+1
							;	DX Sx
							; założenia:
				FOR rej, <AX, BX, CX, DX>	; zapamiętaj rejestry AX-DX
					push rej
				ENDM
				cmp <<n>>, <<m>>			; IF n <= m
				jg KRok
					push ax, KARP_NleM			;	error(ax=KARP_NleM)
					call error
KRok: 			mov ax, offset wz			; DX = hash(wzorzec[0..m-1]) // hash zwraca dane do AX
				call hash
				mov dx, ax
				mov ax, offset txt			; AX = hash(tekst(0..m-1)
				call hash
				mov cx, <<n>>				; CX = n-m+1
				sub cx, <<m>>
				dec cx
				mov bx, 0					; BX = 0
KRloop:				cmp ax, dx				; do
					jne KRrehash				;	IF Sy == Sx
						call KarpRabinRecheck		;	KarpRabinRecheck(BX = i)
KRrehash:			call rehash					;	AX = rehash(Sy[i..i+m])
					inc bx						;	BX--
					cmp bx, cx
				jne KRloop					; while(BX < CX)
				FOR rej, <DX, CX, BX, AX>	; przywróć rejestry
					push rej
				ENDM
				ret							; return
	KarpRabin endp
