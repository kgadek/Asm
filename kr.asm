;.286
; Karp-Rabin finder
; by Konrad Gądek
BUFA_SIZE		EQU 4096	; po 4KB na bufory
BUFB_SIZE		EQU 4096
BUFC_SIZE		EQU 4096

dane segment ; ########################################################################################################
error_msg1		db "Blad krytyczny #",'$'		; komunikaty błędów
error_msg2		db 10, 13, '$'

args LABEL byte
argA			db 2 dup(0)						; wskaźniki na tablicę parametrów
argB			db 2 dup(0)
argC			db 2 dup(0)
				db 0							; śmieć który może powstać przy odczycie
fileC			dw ?							; uchwyty do plików
fileB			dw ?
fileA			dw ?
buforA			db BUFA_SIZE dup(?)
buforB			db BUFB_SIZE dup(?)
buforC			db BUFC_SIZE-256 dup(?)
fileName		db 256 dup(0)					; bufor na nazwę pliku
dane ends

code segment ; ########################################################################################################
				ASSUME CS:code, DS:dane
	; .....[ kody błędów ].............................................................................................
ERROR_NOARG 		EQU 1
ERROR_TOOFEWARG 	EQU 2
ERROR_TOOMUCHARG	EQU 3
ERROR_FILEOPEN		EQU 4
ERROR_FILECLOSE		EQU 5
	; .................................................................................................................

	; .....[ error( AL = kod błędu ) ].................................................................................
	error proc near
				mov ah, 09h					; Wyświetl komunikat błędu ...
				mov dx, offset error_msg1
				int 21h
				mov dl, al					; ... kod błędu ...
				add dl, '0'
				mov ah, 2
				int 21h
				mov ah, 09h					; ... CR/LF
				mov dx, offset error_msg2
				int 21h
				mov ah, 04ch				; Zakończ program z kodem błędu z rejestru AL
				int 21h
	error endp
	; .................................................................................................................
	; .....[ openFromArg( ... ) ]......................................................................................
	; -->	* SI   -   source offset
	;		* CX   -   strlen
	;		* AL   -   open mode
	;		  BX   -   offset handle
	openFromArg proc near
				push bx
				push ax
				xor bx, bx					; BX = 0
											; do {
openFromArg_re:		mov al, es:[si]				;	fileName[BX++] = ES:[SI++]	
					mov fileName[bx], al
					add bx, 1
					add si, 1
				loop openFromArg_re			; } while( --CX )
				mov fileName[bx], 0			; fileName[BX] = 0
				pop ax
				mov ah, 3dh					; int 21:3Dh (openFile)
				int 21h
				jnc openFromArg_ok			; IF error
					mov al, ERROR_FILEOPEN		;	error(FileOpen)
					call error
openFromArg_ok:	pop bx
				mov fileC[bx], ax			; handle = AX
				ret
	openFromArg endp
	; .................................................................................................................
	; .................................................................................................................
	closeFiles proc near
				mov si, 4
				mov cx, 3
closeFiles_lp:		mov ah, 3eh
					mov bx, fileC[si]
					int 21h
					jc closeFiles_err
					sub si, 2
				loop closeFiles_lp

				ret

closeFiles_err:	mov ax, ERROR_FILECLOSE
				call error
	closeFiles endp
	; .................................................................................................................

err_noArg:		mov al, ERROR_NOARG
				call error

	; .....[ main( ES:80h = ARGC, ES:82h = ARGV ) ]....................................................................
start:			mov ax, seg stos_top		; SS:[SP] - segment stosu	
				mov ss, ax
				mov ax, seg args			; DS:[] - segment danych
				mov ds, ax
				mov sp, offset stos_top
				mov cl, es:80h				; IF argc == 0
				jcxz err_noArg					; error(NoArg)

				mov si, 82h					; [BX] = argv
				mov bx, 0
				mov cl, 1					; CL -- poprzednio_spacja? = 1
											; do {
getArgs:			mov al, es:[si]				; 	BX = wczytaj
					cmp al, 13					;	IF AL = enter
					jne getArgs_nieEnter
						mov dx, si
						mov args[bx], dl		;	ARGS[BX] = SI
						cmp bx, 5					;	IF BX >= 5
						jge getArgs_break				;	break
							mov al, ERROR_TOOFEWARG	;	ELSE
							call error					;	error(TooFewArg)
getArgs_nieEnter:	cmp al, ' '					;	AL = spacja ? 1 : 0
					mov al, 0
					jne getArgs_nieSp
						mov al, 1
getArgs_nieSp:		cmp al, cl					;	IF CL != AL
					je getArgs_cont
						mov dx, si					;	args[BX++] = SI
						mov args[bx], dl
						add bx, 1
						cmp bx, 7
						jl getArgs_cont				;	IF BX >= 7
							mov al, ERROR_TOOMUCHARG
							call error					;	error(TooMuchArg)
getArgs_cont:		mov cl, al					;	CL = AL
					add si, 1					;	SI = SI + 1
					jmp getArgs				; } while(true)
getArgs_break:

				mov al, 0					; read-only
				mov bx, 4					; handle = fileA
				mov dx, offset fileName		; DX = offset fileName
				xor cx, cx					; do {
openFiles:			push bx						;	push BX...
					neg bx						;		BX = 4-BX
					add bx, 4
					mov cl, argA[bx]			;		SI = argN
					mov si, cx					;		CL = argN[1] - argN[0]
					neg cl
					add cl, argA[bx+1]
					pop bx						;	...pop BX
					call openFromArg			; 	openFromArg()
					mov al, 1					; 	read-write
					cmp bx, 0					; 
					jz openFiles_done
					sub bx, 2					; BX = BX - 2
				jmp openFiles				; } while( BX >= 0 )
openFiles_done:	

				mov ah, 3fh
				mov bx, fileA
				mov cx, 64h
				mov dx, offset buforA
				int 21h

				call closeFiles
				mov ax, 04c00h				; exit(0)
				int 21h
code ends

stos1 segment STACK ; #################################################################################################
			dw 399 dup(?)
stos_top	dw ?
stos1 ends

end start									; koniec programu

