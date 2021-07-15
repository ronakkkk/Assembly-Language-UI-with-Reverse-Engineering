 DISP MACRO Y, X, VAR, LENGTH, COLOR; BIOS DIsplays strings as required
		 MOV         AH,13H
		 MOV         AL,1
		  MOV BH,0; select 0 page DIsplay
		  MOV BL,COLOR ;color attribute word (color value) →BL
		  MOV CX,LENGTH ;LENGTH string length →CX
		  MOV DH,Y; Y line number →DH
		  MOV DL,X; X column number →DL
		  MOV BP,OFFSET VAR; VAR string effective ADDrESs→BP
		 INT            10H
ENDM 

DATA SEGMENT
 LNAM = 30; the mAXimum length supported by the name
 LKEY = 30; the mAXimum length of password support
 LPT = 10; the starting line number of printing
 LTIME = 3; number of password attempts
 
 
file DB "user.txt",00; File Name to store details 
hanDLer dw ?
 
de DB '123456789'

 NAM DB '1804','$'; name list
 KEY DB '0215',0DH; password list
ID1 	DB '123456789','$'
PASS1 	DB 'root',0DH

IDNAME 	DB '123456789', 10, 13
IDLENGTH DW $-IDNAME
PASSWORD1 DB 'root', '$'
PASSWORDLENGTH DW $-PASSWORD1

SSPACE DB ' ', '$'

ENDD  	DW ?,?

BUF   	DB LNAM+1
		DB ?
		 DB LNAM+1 DUP(?); to store id buffer is used.

NameBUF  DB LNAM+2
		 DB ?
		 DB LNAM+2 DUP(?); to store name buffer is used.


PassBUF  DB LNAM+3
		 DB ?
		 DB LNAM+3 DUP(?); to store name buffer is used.

		 
 ; Below is the string
STRINGN 	DB LNAM DUP(' ')
STRINGP 	DB 'No.'
		DB ?
STRING1 Db 'Advanced Cybersecurity Programming Assignment'
L     =  $-STRING1
STRING2 DB 'ID'
LL    =  $-STRING2
STRING3 DB 'Password,YOU have THREE chance'
LLL   =  $-STRING3

STRING4 DB 'NO information!PLEASE input AGAIN'
L4    =  $-STRING4
STRING5 DB 'INCORRECT!TRY AGAIN'
L5    DB '$'

STRING7 DB ' Welcome!'
L7    =  $-STRING7
STRING8 DB 'LOGIN failed',0DH,0ah
L8    =  $-STRING8

STRING9 	DB 0DH,0AH
		DB 'Hello,'
		DB '$'

; DATA
fname DB "ENTER FIRST NAME ->$"
lname DB "ENTER LAST NAME ->$"
DATEOFBIRTH DB "ENTER DOB(DD/MM/YYYY) ->$"
STR2 DB "YOUR STRING IS ->$"
STR3 DB "LENGTH OF STRING ->$"
INSTR1 DB 20 DUP("$")
NEWLINE DB 10,13,"$"
LN DB 5 DUP("$")
N DB "$"
S DB ?

DATA ENDS

CODE SEGMENT
	ASSUME DS:DATA,CS:CODE,ES:DATA
BEG:	MOV AX,DATA
		MOV DS,AX
		MOV ES,AX
		MOV AX,3   
		 INT 10H; Set the screen DIsplay mode  
		
		 DISP LPT, (80-L)/2, STRING1, L, 1FH; welcome interface
		
		 		;Enter your user name 
		DISP LPT+1,(80-LL)/2,STRING2, LL,2
 FIRST: DISP LPT+2,(80-LNAM)/2,STRINGN,LNAM,2; guide input characters
		MOV BH,0
		MOV DH,LPT+2
		MOV DL,(80-LNAM)/2
		MOV AH,02H
		 INT 10H; set the cursor position			
		MOV AH,0AH
		MOV DX,OFFSET BUF
		 INT 21H; read the string typed by the user and put it in buf		
		MOV DI,OFFSET NAM
   STE:	CALL SCOMP
		JZ  SEC
		CMP DI, OFFSET ENDD
		JC  STE	
		DISP LPT+3,40-L4/2,STRING4,L4,4;		
		JMP FIRST
		
		 		;enter password 
SEC:	DISP LPT+3,(80-LLL)/2,STRING3, LLL,2
		MOV CX,LTIME
SECOND:
		MOV DH,LPT+LTIME+3+1
		MOV BH,0
		SUB DH,CL
		MOV DL,(80-LKEY)/2
		MOV AH,02H
		 INT 10H; set the cursor position
		CALL KEYCHECK
		JZ   YES
		CMP CX,1
		JZ  NO
		MOV AH,09H
		MOV DX,OFFSET STRING5
		INT 21H
		LOOP SECOND

		 ;Login rESult feedback
NO:	    DISP LPT+LTIME+5,(80-L8)/2,STRING8,L8,4
		JMP LAST
YES:	CALL EncryptPass
		CALL FirstName
Fur:    MOV AH,09H
		LEA DX,STRING9
		INT 21H
		MOV BL,BUF+1
        MOV BH,0
        MOV SI,OFFSET BUF+2
        MOV BYTE PTR[BX+SI],'$'
		MOV AH,09H
		MOV DX,OFFSET BUF+2
		INT 21H
        

LAST:	MOV AH ,4CH
	    INT 21H
		
		
 ;------------------------String comparison---------------------- ---
 SCOMP PROC; correct Z is 1 wrong Z is 0
		MOV CL,BUF+1
		MOV CH,0
		LEA SI,BUF+2
		CLD
		REPE CMPSB
		JNZ SNO
		CMP BYTE PTR [DI],'$'
		JZ  SYES
SNO:	CMP BYTE PTR [DI],0DH
		JZ  SSNO
		INC DI
		JMP SNO	
SYES:  INC DI
		 cmp DI, DI; z flag set to 1
		JMP SLAST
		
SSNO:   INC DI 
		 TEST DI, DI; z flag is set to 0 	
SLAST:	MOV ENDD,DI
RET
SCOMP ENDP
 ;--------------------Check if the password is correct----------------------
KEYCHECK  PROC
		MOV DI,ENDD
		MOV ENDD+2,DI
		 MOV DH, 0; use dh as a flag
KBEG:	MOV AH,08H
		 INT 21H; enter a character
		CMP AL,0DH
		JZ KAL0D
		CMP BYTE PTR [DI],0DH
		JNZ KNEX
		INC DH
KNEX:	CMP BYTE PTR [DI],AL
		JZ  KSTEP
		INC DH
KSTEP:  INC DI    
		MOV AH,02H
		MOV DL,' '; In this space we can change the format of password to show on console screen
		INT 21H
		JMP KBEG
 
KAL0D:	CMP BYTE PTR [DI],0DH
		JZ  KLAST
		INC DH 
KLAST:	CMP DH,0
		RET
KEYCHECK	ENDP

;--------------------Encrypt password----------------------
EncryptPass PROC   
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
    MOV CX, PASSWORDLENGTH
    ADD CX, -2
    lea DI, PASSWORD1
    MOV BL, 02
    MOV DL, 00h
   L1:
       mov ah, 00
       mov ax, di
       div bl
       cmp ah, 00
       je Even_encrypt       
    Odd_encrypt:
       mov dl, [di]
       add dl, 01h
       mov [di], dl
       inc di
       loop L1
    Even_encrypt:
       mov dl, [di]
       add dl, 02h
       mov [di], dl
       inc di
       loop L1

	
EncryptPass ENDP
;--------------------Enter Details into File----------------------
FirstName PROC 
			MOV AX,DATA
        	MOV DS,AX

        	LEA SI,INSTR1

	;GET STRING
			MOV AH,09H
			LEA DX,fname
			INT 21H

			MOV AH,0AH
			MOV DX,SI
			INT 21H
			
			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H


		CALL DETAILS
FirstName ENDP
LastName:  	MOV AX,DATA
        	MOV DS,AX

        	LEA SI,INSTR1

	;GET STRING
			MOV AH,09H
			LEA DX,lname
			INT 21H

			MOV AH,0AH
			MOV DX,OFFSET NameBUF
			INT 21H; read the string typed by the user and put it in buf		
			MOV DI,OFFSET NAM
			
			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H

		

	;CLOSE FILE (OR DATA LOST).
			MOV  ah, 3eh
			MOV  bx, hanDLer
			int  21h      
		
			JMP DOB



DOB:  		MOV AX,DATA
        	MOV DS,AX

        	LEA SI,INSTR1

	;GET STRING
			MOV AH,09H
			LEA DX,DATEOFBIRTH
			INT 21H

			MOV AH,0AH
			MOV DX,SI
			INT 21H

			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H
			

	;OPEN FILE.
			MOV  AX, 3d02h
			MOV  dx, offset file
			int  21h  

	
	;PRESERVE FILE HANDLER RETURNED.
			MOV  hanDLer, AX

	; READ FILE
			MOV ah,3fh
			MOV bx,hanDLer
			MOV CX,1000
			lea dx,file
			int 21h


	;WRITE STRING.
			MOV  ah, 40h
			MOV  bx, hanDLer
			MOV  CX, 5  ;STRING LENGTH.
			LEA  DX, NameBUF+2 ; INSERTING LAST NAME
			int  21h

			; DOB
			MOV  ah, 40h
			MOV  bx, hanDLer
			MOV DL, INSTR1+1
			ADD DX, 1
			MOV  CX,DX  ;STRING LENGTH.
			LEA  DX, INSTR1+2; INSERTING DOB
			int  21h

			;ID
			MOV  ah, 40h
			MOV  bx, hanDLer

			MOV  CX, IDLENGTH  ;STRING LENGTH.
			ADD  CX, -1
			MOV DX, OFFSET IDNAME
			int  21h

			; PASSWORD
			MOV  ah, 40h
			MOV  bx, hanDLer
			 MOV CX, PASSWORDLENGTH
    		 ADD CX, -1
			; MOV  CX, PASSWORDLENGTH  ;STRING LENGTH.
			MOV DX, OFFSET PASSWORD1
			int  21h

		
	;CLOSE FILE (OR DATA WILL BE LOST).
			MOV  ah, 3eh
			MOV  bx, hanDLer
			int  21h      
		
			JMP Fur
DETAILS PROC
	MOV  AX,DATA; INITIALIZE DATA SEGMENT.
    MOV  ds,AX
	;CREATE FILE.
	MOV  ah, 3ch
	MOV  CX, 0
	MOV  dx, offset file
	int  21h  

	;PRESERVE FILE HANDLER RETURNED.
	MOV  hanDLer, AX

	
	;WRITE STRING.

	;FIRST NAME
	MOV dl, INSTR1+1
	MOV  ah, 40h
	MOV  bx, hanDLer

	MOV  CX, dx  ;STRING LENGTH.
	MOV DX, OFFSET INSTR1+2
	int  21h

	MOV  ah, 40h
	MOV  bx, hanDLer

	MOV  CX, 1  ;STRING LENGTH.
	MOV DX, OFFSET SSPACE
	int  21h
	
	

	;CLOSE FILE (OR DATA WILL BE LOST).
	MOV  ah, 3eh
	MOV  bx, hanDLer
	int  21h      
	JMP LastName


DETAILS ENDP
CODE ENDS
END BEG 