;.387



;***************************************************************************************************
;* Stałe                                                                                           *
;***************************************************************************************************
BUFFER_SIZE			equ 8192
CMDBUFFER_SIZE		equ 20
PARABUFFER_SIZE		equ 10
ERROR_NOARG			equ '1'
ERROR_TOOFEWARG		equ '2'
ERROR_TOOMUCHARG	equ '3'
ERROR_FILEOPEN		equ '4'
ERROR_FILECLOSE		equ '5'
ERROR_FILEREAD		equ '6'
ERROR_BADCOMMAND	equ '7'
ERROR_BADARGUMENT	equ '8'



;***************************************************************************************************
;* Dane                                                                                            *
;***************************************************************************************************
dane segment
error_msg1		db "Blad krytyczny #",'$'
error_msg2		db '!',10, 13, '$'

graphMode		dw 0
filename		db 256 dup(0)
filehandler		dw ?

fileBufSize		dw 0
fileBuf			db BUFFER_SIZE dup(?)
				db 0

command			db CMDBUFFER_SIZE dup(?)
				db 0
param			db PARABUFFER_SIZE dup(?)
				db 0
paramInt		db 0

posX			db 064h							; X = 100
posY			db 0A0h							; Y = 160
rot				db 90							; a = 90' (do góry)
draw			db 1							; d = true

moveCmdStr		db "move",'$'
penupCmdStr		db "penup",'$'
rotateCmdStr	db "rotate",'$'
pendownCmdStr	db "pendown",'$'

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
;* readArgsReadWord                                                                                 *
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
			xor bx, bx
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
			push ax
			push bx
			push cx
			push si
			push di

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

			pop di
			pop si
			pop cx
			pop bx
			pop ax
			ret

ra_noArgs:	mov al, ERROR_NOARG
			call error
ra_tooFA:	mov al, ERROR_TOOFEWARG
			call error
ra_tooMA:	mov al, ERROR_TOOMUCHARG
			call error
readArgs endp



;***************************************************************************************************
;* openFile                                                                                        *
;*   Zakładamy, że DS jest ustawione na dobry segment. Uchwyt do pliku zapisujemy w zmiennej       *
;*   filehandler.                                                                                  *
;***************************************************************************************************
openFile proc near
			push ax
			push dx
			mov dx, offset filename
			mov ax, 3d00h
			int 21h
			jc of_err
			mov filehandler, ax
			pop dx
			pop ax
			ret

of_err:		mov al, ERROR_FILEOPEN
			call error
openFile endp



;***************************************************************************************************
;*  parseFile_readIntoBuffer                                                                       *
;*   Wczytuje zawartość pliku wskazanego przez uchwyt w zmiennej filehandler do bufora.            *
;***************************************************************************************************
parseFile_readIntoBuffer proc near
			push ax
			push bx
			push cx
			push dx
			mov ah, 3fh
			mov bx, filehandler
			mov cx, BUFFER_SIZE
			mov dx, offset fileBuf
			int 21h
			jc pf_err
			mov fileBufSize, ax
			pop dx
			pop cx
			pop bx
			pop ax
			ret

pf_err:		mov al, ERROR_FILEREAD
			call error
parseFile_readIntoBuffer endp



;***************************************************************************************************
;* eatSpaces                                                                                       *
;*   Zjada spacje z bufora. A właściwie to przesuwa SI aż natrafi na nie-spację.                   *
;*   A tabulatury też je. I entery też                                                             *
;*                                                                                                 *
;* Paramtry:                                                                                       *
;*   SI* -- wskaźnik na dane w buforze                                                             *
;***************************************************************************************************
eatSpaces proc near
			jmp es_loop
es_getNext:		inc si							; micro-trick znaleziony u Knutha :)
es_loop:		cmp fileBufSize, si
				jle es_break
				cmp fileBuf[si], ' '			; spacja?
				je es_getNext
				cmp fileBuf[si], 09h			; tab?
				je es_getNext
				cmp fileBuf[si], 0ah			; enter?
				je es_getNext
es_break:	ret
eatSpaces endp



;***************************************************************************************************
;* parseWord                                                                                       *
;*   Wczytuje polecenie do zmiennej command a także ustawia CX na ilość wczytanych znaków.         *
;*   CX = 0 oznacza koniec pliku                                                                   *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   CX* -- ilość znaków słowa                                                                     *
;*   SI  -- przesunięte na początek napisu                                                         *
;***************************************************************************************************
parseWord proc near
			call eatSpaces
			push si
			xor cx, cx							; CX -- ilość wczytanych znaków = 0
			cmp fileBufSize, si					; koniec pliku --> break
			jle pw_break
pw_loop:		inc cx								; CX ++
				inc si								; SI ++ -- next()
				cmp fileBuf[si], ' '				; jeśli spacja lub enter - kończ
				je pw_break
				cmp fileBuf[si], 0ah
				je pw_break
				jmp pw_loop							; powtórz
pw_break:	pop si
			ret
parseWord endp



;***************************************************************************************************
;* cmdCompare                                                                                      *
;*   Porównuje zawartość zmiennej command z łańcuchem o adresie DS:[DI]. Zwraca informacje         *
;*   poprzez rejestr flag.                                                                         *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   DS  -- segment danych                                                                         *
;*   DI* -- offset łańcucha                                                                        *
;*   CX  -- ilość znaków do porównania                                                             *
;*   SI* -- przesuwamy się wskaźnikiem CX razy w prawo                                             *
;***************************************************************************************************
cmdCompare proc near
			push cx
			push ax
			xor ax, ax							; AX -- temp
cc_loop:		mov al, fileBuf[si]
				cmp al, ds:[di]
				jne cc_end
				pushf
				inc di
				inc si
				popf
				loop cc_loop						; powtarzaj CX razy
cc_end:		pop ax
			pop cx
			ret
cmdCompare endp



;***************************************************************************************************
;* commandMove                                                                                     *
;***************************************************************************************************
commandMove proc near
			push ax
			push di
			mov ax, 0a000h
			mov es, ax
			mov di, 320*10+10
			mov al, 10
			mov es:[di], al
			pop di
			pop ax
			;call calcDestPt
			;cmp draw, 0
			;jz cm_noDraw
			;call drawLine
cm_noDraw:	;call move
			ret
commandMove endp



;***************************************************************************************************
;* commandPenup                                                                                    *
;***************************************************************************************************
commandPenup proc near
			mov draw, 0
			ret
commandPenup endp



;***************************************************************************************************
;* commandRotate                                                                                   *
;***************************************************************************************************
commandRotate proc near
			ret
commandRotate endp



;***************************************************************************************************
;* commandPendown                                                                                  *
;***************************************************************************************************
commandPendown proc near
			mov draw, 1
			ret
commandPendown endp



;***************************************************************************************************
;* parseParam                                                                                      *
;*   Zwraca wartość parametru w rejestrze BX                                                       *
;*                                                                                                 *
;* Parametry:                                                                                      *
;*   paramInt -- wartość wczytana z parametru                                                      *
;*   SI* -- wskaźnik na bufor z poleceniami                                                        *
;***************************************************************************************************
parseParam proc near
			call eatSpaces
			push ax
			push bx
			push cx

			xor ax, ax
			xor bx, bx
			mov cx, 0ah							; CX -- podstawa = 10

pp_loop:		mov bl, fileBuf[si]
				cmp bl, ' '							; sprawdź czy wejście :- biały znak ?
				je pp_done
				cmp bl, 09h
				je pp_done
				cmp bl, 0ah
				je pp_done

				cmp bl, '0'							; sprawdź czy wejście :- [0,9] ?
				jl pp_err
				cmp bl, '9'
				jg pp_err
				sub bl, '0'

				mul cl								; AL = 10*AL + BL
				add al, bl

				inc si
				cmp fileBufSize, si
				jle pp_done

				jmp pp_loop

pp_done:	mov paramInt, al
			pop cx
			pop bx
			pop ax
			ret

pp_err:		mov al, ERROR_BADARGUMENT
			call error
parseParam endp



;***************************************************************************************************
;* parseFile                                                                                       *
;*   Parsowanie pliku wejściowego (linia po linii).                                                *
;*                                                                                                 *
;* Pseudo-globalnie:                                                                               *
;*   SI  -- wskaźnik miejsca w buforze                                                             *
;*   DI  -- wskazywany string do porównania                                                        *
;***************************************************************************************************
parseFile proc near
			push si
			push cx

			call parseFile_readIntoBuffer
			xor cx, cx							; CX -- ilość wczytanych danych = 0
			xor si, si							; SI -- wskaźnik danych = 0

pf_loop:		call parseWord						; wczytaj argument
				cmp cx, 0
				jz pf_endLoop						; jeśli nic nie ma to zakończ

				cmp cx, 4							; czy move?
				jl pf_badCmd
				jne pf_nMove
					mov di, offset moveCmdStr
					jmp pf_nn
pf_nMove:		cmp cx, 5							; czy penup?
				jne pf_nPenup
					mov di, offset penupCmdStr
					jmp pf_nn
pf_nPenup:		cmp cx, 6							; czy rotate?
				jne pf_nRotate
					mov di, offset rotateCmdStr
					jmp pf_nn
pf_nRotate:		cmp cx, 7							; czy pendown?
				jne pf_badCmd
					mov di, offset pendownCmdStr

pf_nn:			call cmdCompare						; także przesuwa wskaźnik SI za koniec słowa
				jne pf_badCmd

pf_noParam:		cmp cx, 4							; move?
				jne pf_enMove
					call parseParam
					call commandMove
					jmp pf_loop
pf_enMove:		cmp cx, 5							; penup?
				jne pf_enPenup
					call commandPenup
					jmp pf_loop
				jne pf_enPenup
pf_enPenup:		cmp cx, 6							; rotate?
				jne pf_enRotate
					call parseParam
					call commandRotate
					jmp pf_loop
pf_enRotate:	call commandPendown					; pendown? (!)
				jmp pf_loop

pf_endLoop:	pop cx
			pop si
			ret

pf_badCmd:	mov al, ERROR_BADCOMMAND
			call error
parseFile endp



;***************************************************************************************************
;* closeFile                                                                                       *
;***************************************************************************************************
closeFile proc near
			push ax
			push bx
			xor ax, ax
			mov ah, 3eh
			mov bx, filehandler
			int 21h
			jc cf_err
			pop bx
			pop ax
			ret

cf_err:		mov al, ERROR_FILECLOSE
			call error
closeFile endp



;***************************************************************************************************
;* waitForKeyPress                                                                                 *
;***************************************************************************************************
waitForKeyPress proc near
			push ax
			mov ah, 0
			int 16h
			pop ax
			ret
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
;***************************************************************************************************
;***  Main                                                                                       ***
;***************************************************************************************************
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
