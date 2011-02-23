.387



;***************************************************************************************************
;* Stałe                                                                                           *
;***************************************************************************************************
ERROR_NOARG			equ '1'
ERROR_TOOFEWARG		equ '2'
ERROR_TOOMUCHARG	equ '3'
ERROR_FILEOPEN		equ '4'
ERROR_FILECLOSE		equ '5'
ERROR_BADCOMMAND	equ '6'



;***************************************************************************************************
;* Dane                                                                                            *
;***************************************************************************************************
dane segment
error_msg1		db "Blad krytyczny #",'$'
error_msg2		db '!',10, 13, '$'

graphMode		dw 0
filename		db 256 dup(0)

dane ends



code segment
ASSUME CS:code, DS:dane




;***************************************************************************************************
;* error                                                                                           *
;*   Wyświetla kod błędu wraz ze stosownym komunikatem, a następnie kończy pracę programu.         *
;*   Nie zachowuje rejestrów bo... po co?                                                          *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   AL*  --  kod błędu (w kodzie ASCII)                                                           *
;***************************************************************************************************
error proc near
			xor bx, bx							; jeśli tryb graficzny - przełącz do trybu tekst.
			cmp graphMode, bx
			je e_msg
				call graphStop
e_msg:		mov ah, 09h							; wyświetl komunikat błędu
			mov dx, offset error_msg1
			int 21h
			mov dl, al							; wyświetl kod błędu
			mov ah, 2
			int 21h
			mov dx, offset error_msg2			; wyświetl drugą część komunikatu błędu
			mov ah, 09h
			int 21h
			mov ah, 04ch						; zakończ
			sub al, '0'
			int 21h
error endp



;***************************************************************************************************
;* readArgsEatSpaces  int.                                                                         *
;*   Zjada spacje z linii poleceń. Zakłada, że rejestry ES i SI są odpowiednio ustawione           *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   ES  -- segment argumentów                                                                     *
;*   SI* -- offset znaku                                                                           *
;* Wyjście:                                                                                        *
;*   AL* -- pierwszy znak niebędący spacją                                                         *
;***************************************************************************************************
readArgsEatSpaces proc near
raes_m:		mov al, es:[si]
				cmp al, ' '
				jne raes_e							; break
				inc si
				jmp raes_m
raes_e:		ret
readArgsEatSpaces endp



;***************************************************************************************************
;* readArgsReadWord int.                                                                            *
;*   Przepisuje nazwę pliku wejściowego do zmiennej filename.                                      *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   ES  -- segment argumentów                                                                     *
;*   SI* -- offset znaku                                                                           *
;* Wyjście:                                                                                        *
;*   AL* -- pierwszy znak będący spacją lub znakiem końca linii                                    *
;***************************************************************************************************
readArgsReadWord proc near
			push bx
			mov bx, offset filename
raew_m:		mov al, es:[si]
				cmp al, ' '
				je raew_e							; break
				cmp al, 0dh
				je raew_e							; break
				mov filename[bx], al
				inc si
				inc bx
				jmp raew_m
raew_e:		pop bx
			ret

readArgsReadWord endp


;***************************************************************************************************
;* readArgs                                                                                        *
;*   Wczytuje argument z linii poleceń -- nazwę pliku (do zmiennej filename). Zakłada, że          *
;*   rejestry SS, SP i DS są odpowiednio zainicjowane.                                             *
;***************************************************************************************************
readArgs proc near
			FOR rej, <ax, bx, cx, si, di>
				push rej
			ENDM

			xor cx, cx
			mov cl, es:80h						; sprawdź, czy podano jakikolwiek argument
			jcxz ra_noArgs
			mov si, 82h							; SI -- offset argumentów = 82h

			call readArgsEatSpaces
			cmp al, 0dh							; jeśli same spacje --> błąd
			je ra_tooFA
			mov bx, si
			
			call readArgsReadWord

			call readArgsEatSpaces				; jeśli więcej argumentów --> błąd
			cmp al, 0dh
			jne ra_tooMA

			FOR rej, <di, si, cx, bx, ax>
				pop rej
			ENDM
			ret

ra_noArgs:	mov al, ERROR_NOARG
			call error
ra_tooFA:	mov al, ERROR_TOOFEWARG
			call error
ra_tooMA:	mov al, ERROR_TOOMUCHARG
			call error
readArgs endp



;***************************************************************************************************
;*                                                                                                 *
;***************************************************************************************************
openFile proc near
openFile endp



;***************************************************************************************************
;*                                                                                                 *
;***************************************************************************************************
parseFile proc near
parseFile endp



;***************************************************************************************************
;*                                                                                                 *
;***************************************************************************************************
closeFile proc near
closeFile endp



;***************************************************************************************************
;*                                                                                                 *
;***************************************************************************************************
waitForKeyPress proc near
waitForKeyPress endp



;***************************************************************************************************
;* graphStart                                                                                      *
;*   uruchamia tryb graficzny (320x200)                                                            *
;***************************************************************************************************
graphStart proc near
			push ax
			mov ax, 0013h
			int 10h
			pop ax
			mov graphMode, 1
			ret
graphStart endp



;***************************************************************************************************
;* graphStop                                                                                       *
;*   uruchamia tryb tekstowy (80x25 kolor)                                                         *
;***************************************************************************************************
graphStop proc near
			push ax
			mov ax, 0003h
			int 10h
			pop ax
			mov graphMode, 0
			ret
graphStop endp



;***************************************************************************************************
;* Main                                                                                            *
;***************************************************************************************************
start:		mov ax, seg stosTop					; SS:[SP]
			mov ss, ax
			mov sp, offset stosTop
			mov ax, seg filename				; DS:[] - segment danych
			mov ds, ax

			call readArgs
			call openFile
			call graphStart
			call parseFile
			call closeFile
			call waitForKeyPress
			call graphStop

			mov ax, 04c00h						; exit(0)
			int 21h
code ends



;***************************************************************************************************
;* Stos                                                                                            *
;***************************************************************************************************
stos1 segment STACK
			dw 399 dup(?)
stosTop		dw ?
stos1 ends

end start
