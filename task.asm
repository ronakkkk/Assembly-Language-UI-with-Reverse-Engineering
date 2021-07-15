
DATA SEGMENT
 
de DB '1603198'

NAMELENGTH = 30; the mAXimum length supported by the name
 LKEY = 30; the mAXimum length of password support
 LPT = 10; the starting line number of printing
 LTIME = 3; number of password attempts
 
 

 NAM DB '1804','$'; name list
 KEY DB '0215',0DH; password list
USERID 	DB '30','$'
USERPASS 	DB 'pass',0DH

IDNAME 	DB '30', 10, 13
IDLENGTH DW $-IDNAME
PASSWORD1 DB 'pass', '$'
PASSWORDLENGTH DW $-PASSWORD1

SSPACE DB ' ', '$'

ENDD  	DW ?,?

BUFFER   	DB NAMELENGTH+1
		DB ?
		 DB NAMELENGTH+1 DUP(?); to store id buffer is used.

BUFFERNUMBER  DB NAMELENGTH+2
		 DB ?
		 DB NAMELENGTH+2 DUP(?); to store name buffer is used.


		 
 ; Below is the string


UID DB 'ID ->$'

UPASS DB 'Password->$'

UWID DB 'INCORRECT ID! PLEASE ENTER CORRECT ID ->$'

UWPASS DB 'INCORRECT PASSWORD! TRY AGAIN ->$'


UFAIL DB 'LOGIN failed',0DH,0ah

FNAME DB "ENTER FIRST NAME ->$"

SNAME DB "ENTER LAST NAME ->$"

DATEOFBIRTH DB "ENTER DOB(DD/MM/YYYY) ->$"

TEXT6 	DB 0DH,0AH
		DB 'Hello,'
		DB '$'
STR2 DB "YOUR STRING IS ->$"
STR3 DB "LENGTH OF STRING ->$"
INSTR1 DB 20 DUP("$")

NEWLINE DB 10,13,"$"
LN DB 5 DUP("$")
N DB "$"
S DB ?

filename DB "DATA.txt",00; File Name to store details 
HANDLER dw ?
 
DATA ENDS

CODE SEGMENT
	ASSUME DS:DATA,CS:CODE,ES:DATA
MAIN:	MOV AX,DATA
		MOV DS,AX
		MOV ES,AX
		MOV AX,3   
		 INT 10H; Set the screen DIsplay mode  
		
		 		;Enter your user name 
			MOV AH,09H
			LEA DX,UID
			INT 21H
			
 UNAME: MOV AH,0AH
		MOV DX,OFFSET BUFFER
		 INT 21H; read the string typed by the user and put it in BUFFER		
		MOV DI,OFFSET NAM

		MOV AH,09H
			LEA DX,NEWLINE
			INT 21H

   STRCOMP:	CALL SCOMP
		Jle  UPASSFUNC
		CMP DI, OFFSET ENDD
		JC  STRCOMP	
		;GET STRING
			MOV AH,09H
			LEA DX,UWID
			INT 21H	
		JMP UNAME
		
		 		
UPASSFUNC:	;GET STRING PASSWORD
			MOV AH,09H
			LEA DX,UPASS
			INT 21H
		MOV CX,LTIME
STRY:	MOV DH,LPT+LTIME+3+1
		MOV BH,0
		SUB DH,CL
		MOV DL,(80-LKEY)/2
		MOV AH,02H

		CALL PASSCHECK
		JZ   TRUE
		CMP CX,1
		JZ  FALSE
		MOV AH,09H
		MOV DX,OFFSET UWPASS
		INT 21H

		;newline
		MOV AH,09H
		LEA DX,NEWLINE
		INT 21H
		LOOP STRY

FALSE:	    ;GET STRING
			MOV AH,09H
			LEA DX,UFAIL
			INT 21H
		JMP EXIT
TRUE: CALL Encryption
	  JMP DET

DET: CALL FirstName       
HELLOP:    MOV AH,09H
		LEA DX,TEXT6
		INT 21H
		MOV BL,BUFFER+1
        MOV BH,0
        MOV SI,OFFSET BUFFER+2
        MOV BYTE PTR[BX+SI],'$'
		MOV AH,09H
		MOV DX,OFFSET BUFFER+2
		INT 21H

EXIT:	MOV AH ,4CH
	    INT 21H
		
		
 ;COMPARE USER INPUT
 SCOMP PROC; correct Z is 1 wrong Z is 0
		MOV CL,BUFFER+1
		MOV CH,0
		LEA SI,BUFFER+2
		CLD
		REPE CMPSB
		JNZ SFALSE
		CMP BYTE PTR [DI],'$'
		Jle  STRUE
SFALSE:	CMP BYTE PTR [DI],0DH
		JZ  SSFALSE
		INC DI
		JMP SFALSE	
STRUE:  INC DI
		 cmp DI, DI
		JMP SEXIT
		
SSFALSE:   INC DI 
		 TEST DI, DI
SEXIT:	MOV ENDD,DI
RET
SCOMP ENDP
 ;password check
PASSCHECK  PROC
		MOV DI,ENDD
		MOV ENDD+2,DI
		 MOV DH, 0
PASSMAIN:	MOV AH,08H
		 INT 21H
		CMP AL,0DH
		JZ KTYPE
		CMP BYTE PTR [DI],0DH
		JNZ PASSNEXT
		INC DH
PASSNEXT:	CMP BYTE PTR [DI],AL
		JZ  PASSSTEP
		INC DH
PASSSTEP:  INC DI    
		MOV AH,02H
		MOV DL,' '
		INT 21H
		JMP PASSMAIN
 
KTYPE:	CMP BYTE PTR [DI],0DH
		JZ  CHECKEXIT
		INC DH 
CHECKEXIT:	CMP DH,0
		RET
PASSCHECK	ENDP

;--------------------Encrypt password----------------------
Encryption PROC   
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
       add dl, 05h
       mov [di], dl
       inc di
       loop L1
    Even_encrypt:
       mov dl, [di]
       add dl, 08h
       mov [di], dl
       inc di
       loop L1

	
Encryption ENDP

FirstName PROC 
			MOV AX,DATA
        	MOV DS,AX

        	LEA SI,INSTR1

	;GET STRING
			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H

			MOV AH,09H
			LEA DX,fname
			INT 21H

			MOV AH,0AH
			MOV DX,SI
			INT 21H
			
			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H


		CALL FILECREATE
FirstName ENDP
SURNAME:  	MOV AX,DATA
        	MOV DS,AX

        	LEA SI,INSTR1

			MOV AH,09H
			LEA DX,sname
			INT 21H

			MOV AH,0AH
			MOV DX,OFFSET BUFFERNUMBER
			INT 21H	
			MOV DI,OFFSET NAM
			
			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H

			MOV  ah, 3eh
			MOV  bx, HANDLER
			int  21h      
		
			JMP DATEBIRTH



DATEBIRTH:  		MOV AX,DATA
        	MOV DS,AX
        	LEA SI,INSTR1


			MOV AH,09H
			LEA DX,DATEOFBIRTH
			INT 21H

			MOV AH,0AH
			MOV DX,SI
			INT 21H

			MOV AH,09H
			LEA DX,NEWLINE
			INT 21H
			
			MOV  AX, 3d02h
			MOV  dx, offset filename
			int  21h  

			MOV  HANDLER, AX

			MOV ah,3fh
			MOV bx,HANDLER
			MOV CX,1000
			lea dx,filename
			int 21h


	;WRITE FILE.
			MOV  ah, 40h
			MOV  bx, HANDLER
			MOV  CX, 5  ;STRING LENGTH.
			LEA  DX, BUFFERNUMBER+2 ; INSERTING LAST NAME
			int  21h

			; DATEOFBIRTH
			MOV  ah, 40h
			MOV  bx, HANDLER
			MOV DL, INSTR1+1
			ADD DX, 1
			MOV  CX,DX  ;STRING LENGTH.
			LEA  DX, INSTR1+2; INSERTING DATEOFBIRTH
			int  21h

			;ID
			MOV  ah, 40h
			MOV  bx, HANDLER

			MOV  CX, IDLENGTH  ;STRING LENGTH.
			ADD  CX, -1
			MOV DX, OFFSET IDNAME
			int  21h

			; PASSWORD
			MOV  ah, 40h
			MOV  bx, HANDLER
			 MOV CX, PASSWORDLENGTH
    		 ADD CX, -1
			; MOV  CX, PASSWORDLENGTH  ;STRING LENGTH.
			MOV DX, OFFSET PASSWORD1
			int  21h

		
	;CLOSE FILE (OR DATA WILL BE LOST).
			MOV  ah, 3eh
			MOV  bx, HANDLER
			int  21h   

			JMP HELLOP 
FILECREATE PROC
	MOV  AX,DATA; INITIALIZE DATA SEGMENT.
    MOV  ds,AX
	;CREATE FILE.
	MOV  ah, 3ch
	MOV  CX, 0
	MOV  dx, offset filename
	int  21h  

	;PRESERVE FILE HANDLER RETURNED.
	MOV  HANDLER, AX

	
	;WRITE STRING.

	;FIRST NAME
	MOV dl, INSTR1+1
	MOV  ah, 40h
	MOV  bx, HANDLER

	MOV  CX, dx  ;STRING LENGTH.
	MOV DX, OFFSET INSTR1+2
	int  21h

	MOV  ah, 40h
	MOV  bx, HANDLER

	MOV  CX, 1  ;STRING LENGTH.
	MOV DX, OFFSET SSPACE
	int  21h
	
	

	;CLOSE FILE (OR DATA WILL BE LOST).
	MOV  ah, 3eh
	MOV  bx, HANDLER
	int  21h      
	JMP SURNAME


FILECREATE ENDP
CODE ENDS
END MAIN