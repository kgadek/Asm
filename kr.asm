.286
; Karp-Rabin finder
; by Konrad Gądek

dane segment ; ########################################################################################################
error_msg1		db "Blad krytyczny #",'$'
error_msg2		db 10, 13, '$'

args			db 7 dup(0)
dane ends

code segment ; ########################################################################################################
				ASSUME CS:code, DS:dane
	; .....[ kody błędów ].............................................................................................
ERROR_NOARG 		EQU 1
ERROR_TOOFEWARG 	EQU 2
ERROR_TOOMUCHARG	EQU 3
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

err_noArg:		mov al, ERROR_NOARG
				call error

	; .....[ main( ES:80h = ARGC, ES:82h = ARGV ) ]....................................................................
start:			mov ax, seg stos_top		; SS:[SP] - segment stosu	
				mov ss, ax
				mov ax, seg dane			; DS:[] - segment danych
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
						mov [offset args+bx], si	;	ARGS[BX] = SI
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
						mov [offset args+bx], si	;	args[BX++] = SI
						add bx, 1
						cmp bx, 7
						jl getArgs_cont				;	IF BX >= 7
							mov al, ERROR_TOOMUCHARG
							call error					;	error(TooMuchArg)
getArgs_cont:		mov cl, al					;	CL = AL
					add si, 1					;	SI = SI + 1
					jmp getArgs				; } while(true)
getArgs_break:

				mov ax, 04c00h				; exit(0)
				int 21h
code ends

stos1 segment STACK ; #################################################################################################
			dw 399 dup(?)
stos_top	dw ?
stos1 ends

end start									; koniec programu

