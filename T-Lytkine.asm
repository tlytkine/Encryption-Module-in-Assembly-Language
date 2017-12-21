.ORIG x3000

LEA R0, Starting 
PUTS ; Prints "Starting Privacy Module" to screen

BRNzp after
LabelVar2 
	 Starting .STRINGZ "Starting Privacy Module\n"
	Enter .STRINGZ "\nENTER E to ENCRYPT, D to DECRYPT, X to EXIT\n"
	InvalidEntry .STRINGZ "INVALID ENTRY, PLEASE TRY AGAIN\n" 
	x1 .BLKW 1 ; one non-numeric character 
	y1 .BLKW 1 ; hundreds place of 3 digit number between 1 and 127
	y2 .BLKW 1 ; tens place of 3 digit number between 1 and 127
	y3 .BLKW 1 ; one place of 3 digit number between 1 and 127
	after 
	BRNzp after1
	keyAddress .FILL x4100 ; initial address location for key 
	key .BLKW 1 ; space for key 
	X_VALUE .FILL #-88 ; negative ASCCI value of X 
	E_VALUE .FILL #-69 ; negative ASCII value of E
	D_VALUE .FILL #-68 ; negative ASCII value of D 	
	EnterKey .STRINGZ "ENTER KEY (Length 5, non-zero digit less than 6 followed by non-numeric character followed by 3 digit number between 0 and 127) \n WHEN DONE PRESS ENTER\n"
	z1 .BLKW 1 ; non-zero digit less than 8
after1 

ProgramLoop4 LEA R0, Enter ;  start of program loop 
			PUTS ; Step 1a, Prints prompt to enter E, D, or X 
			GETC ; Step 1b, takes user input 

			LD R1, X_VALUE
			ADD R1,R1,R0
			BRz toHalt 


			LD  R1, E_VALUE
			ADD R1,R1,R0 
			BRz KeyStart

			LD R1, D_VALUE
			ADD R1,R1,R0
			BRz KeyStart 

			LEA R0, InvalidEntry 
			PUTS 
			ADD R1,R1,R0
			BRnp ProgramLoop4

BRNzp after2
toHalt 
BRNZp toHalt1
KeyStart
BRNZp KeyStart1
KeyStart1
BRNzp KeyStart2 
after2

KeyStart2 	   AND R2,R2,#0 ; clears R2 
      		   ADD R2,R2,R0 ; stores user input in memory 
			   AND R3, R3, #0 ; clears R3
			   ADD R3, R3, #5 ; adds 5 to R3 (length 5 key)
			   LD R1, keyAddress ; loads R1 with x4100
			   ST R1, key ; stores R1 in key
			   LEA R0, EnterKey
			   PUTS ; prints prompt to enter key 
	           ; key stored at x4100, x4101, x4102, x4103, x4104

	  StoreKey IN ; takes user input character by character (key of length 5)
			   STI R0, key ; stores input (starting at x3500)
			   ADD R1,R1,#1 ; increments address 
			   ST R1, key ; stores new destination address 
			   ADD R3, R3, #-1 ; decrement R3 (5)
			   BRp StoreKey ; < 5 characters go back to taking input


			   STI R1,y3	; digit in ones place of 3 digit number stored (between 0 and 127)
			   ADD R1,R1,#-1 ; decrements address of key to be at y2 
			   STI R1,y2	; digit in tens place of 3 digit number stored (between 0 and 127)
			   ADD R1,R1,#-1 ; decrements address of key to be at y1 
			   STI R1,y1	; digit in hundreds place of 3 digit number stored (between 0 and 127)
			   ADD R1,R1,#-1 ; decrements address of key to be at x1 
			   STI R1,x1 ; one non-numeric character stored 
			   ADD R1,R1,#-1 ; decrements address of key to be at z1
			   STI R1,z1	; non-zero digit less than 8 stored 

BRnzp next4
ProgramLoop3
BRNzp ProgramLoop4
next4

	EncryptOrDecrypt LD R0,E_VALUE ; loads R0 with negative ASCII Value of E 
					 AND R1,R1,#0 ; clears R1 
					 ADD R1,R2,R1 ; adds R2 to R1 (stored input)
					 ADD R0,R0,R1 ; checks to see if E 
					 BRz Encrypt ; jumps to Encrypt if E 
					 LD R0,D_VALUE ; loads R0 with negative ASCII Value of D
					 ADD R0,R0,R2 ; checks to see if D 
					 Brz Decrypt ; jumps to Decrypt if D 


	Encrypt LEA R0, EnterText ;
			PUTS ; prints prompt to enter message 
			LD R1,messageAddress ; loads R1 with x4000, starting location of message address 
			ST R1,message ; stores R1 in message 
			AND R4,R4,#0 ; clears R4 
			ADD R4,R4,#10 ; adds 10 to R4

StoreMessage IN ; takes user input character by character 
			 LD R3,ENTER_VALUE ; loads R3 with negative ASCII value of enter / carriage return
			 ADD R3,R3,R0 ; checks if enter was pressed 
			 BRz CaesarsCipher ; if enter pressed, move on to first step of encryption, caesars cipher
			 STI R0, message ; stores input starting at x4000
			 ADD R1,R1,#1 ; increments address 
			 ST R1, message ; stores new destination address 
			 ADD R4, R4, #-1 ; decrements R4 (with initial value of 10 representing at most 10 characters)
			 BRnp StoreMessage ; if 10 characters not reached continue 
BRNzp next5
toHalt1 
LEA R0, ExitingProgram
PUTS ; prints exiting program to screen (X was entered)
BRNZp toHalt2

ProgramLoop2
BRNzp ProgramLoop3
next5
; Caesars Cipher, ci = (pi + k) modulo 128
; First, Converts key to 3 digit decimal number, stored in location ccNum

CaesarsCipher LD R1,y3 ; loads R1 with y3 value 
			  LD R2,ASCI_OFFSET ; loads R2 with ascii offset
			  ADD R1,R1,R2 ; adds ascii offset to R1 
			  AND R0,R0,#0 ; clears R0
			  ADD R0,R1,R0 ; adds y3 to R0
			  LD R1,y2 ; loads R1 with y2 value 
			  ADD R1,R1,R2 ; adds ascii offset to y2
			  AND R3,R3,#0 ; clears R3 
			  AND R4,R4,#0 ; clears R4 
			  ADD R4,R4,#10 ; sets R4 equal to 10 
			  ADD R3,R3,R2 ; adds y2 to R3 
			  JSR Mult ; multiples y2 by 10 (tens place)
			  ADD R0,R5,R0 ; adds y2 * 10 to R0 
			  LD R1,y3 ; loads R1 with y3 value 
			  ADD R1,R1,R2 ; adds ascii offset to y3 
			  AND R3,R3,#0 ; clears R3 
			  ADD R3,R1,R3 ; adds y3 to R3 
			  LD R4, hundredVal ; sets R4 equal to 100 
			  JSR Mult ; multiplies y3 by 100 (hundreds place)
			  ADD R0,R5,R0 ; adds result to R0, R0 now stores 3 digit number (key used in Caesars Cipher)
			  LD R1, ccAddress ; address to store key (x4150)
			  ST R1, ccNum  ; stores destination address into ccNum 
			  STI R0,ccNum ; stores 3 digit number y3y2y1 into address x3600

			  AND R5,R5,#0 ; clears R5
			  ADD R5,R5,#10 ; adds 10 to R5 
			  AND R2,R2,#0 ; clears R2, used to count how many characters stored 
			  LD R1,message ;
			  ADD R1,R1,#1;
			  ST R1, message ;



	 	ccLoop 	LD R1,message
				LD R0,ENTER_VALUE ; loads R0 with negative enter ASCII Value 
				ADD R0,R1,R0 ; adds character to negative enter value 
				BRz VigenereCipher ; if equal to enter value, go to vigenere cipher, otherwise continue
				LD R0,ASCI_OFFSET ;
				ADD R3,R0,R1 ; converts character to decimal and stores in R3, ci of Caesars Cipher 
				LD R0,ccNum ; loads R0 with key, k of Caesars Cipher 
				ADD R3,R3,R0 ; pi + k of Caesars cipher 
				LD R4,modVal ; sets R4 equal to 128
				JSR Div ; divides pi + k by 128, remainder in R6, aka (pi + k) mod 128
				STI R6,message 
				ADD R2,R2,#1 ; keeps track of how many characters stored 
				ADD R1,R1,#1 ; increments memory address in R1 
				ST R1,message ; stores incremented memory address in message 
				ADD R5,R5,#-1 ; decrements R5 
				BRp ccLoop ; if 10 characters not converted into cipher text, continue to loop unless ASCII value for enter is found as value of character in message 

; Vigenere Cipher, ci = pi XOR k 
VigenereCipher  LD R4,ccNum ; loads R4 with key (128)
				AND R5,R5,#0 ; keeps track of number of characters stored 
	        	ADD R2,R2,#0 ; number of characters stored from before here 
	   			BRz LeftBitShift ; if 0 characters left, continue to next step in encryption

	   	vcLoop	AND R3,R3,#0 ; pi stored here 
			    LD R1,message ; loads R1 with message pi
			    ADD R1,R1,#-1 ; decrements message address 
			    ST R1, message ; stores decremented address in message
			    LD R1, message ; loads R1 with message 
			    ADD R3,R1,R3 ; adds character to R3 
			    JSR Xor ; XOR's R3 and R4, stores in R0
			    STI R0, message ;  stores result of pi XOR k in message 
			    ADD R5,R5,#1 ; increments counter of characters stored 
			    ADD R2,R2,#-1 ; decrements number of characters stored from Caesars Cipher 
			    BRp vcLoop ; uses counter from Caesars Cipher to figure out how to end 

; Left Bit Shift Operation (Left by K times to encrypt)
LeftBitShift LD R0,z1 ; loads R0 with z1 value 
			 LD R1,ASCI_OFFSET ; loads R1 with ASCII Offset 
			 ADD R0,R1,R0 ; adds ASCII offset to z1 value to convert to decimal
			 AND R1,R1,#0 ; clears R1 
			 LD R2,message ; loads R2 with message 
			 ADD R1,R2,R1 ; adds value of message to R1 
LeftShiftLoop ADD R1,R1,R1 ; performs bit shift 
			  ADD R0,R0,#-1 ; K times 
			  BRp LeftShiftLoop ; performs bit shift operation proper number of times
			  STI R1,message ; stores final result of bit shift in message 
			  ADD R2,R2,#1 ; increments message address 
			  ST R2,message ; stores incremented address in message 
			  ADD R5,R5,#-1 ; decrements counter from Vigenere Cipher 
			  BRp LeftBitShift ; uses counter from Vigenere Cipher to figure out how to end 

ProgramLoop1
BRNzp ProgramLoop2

; Decrypted String 
; Inverted Bit Shift performed on result (right bit shift)
; Then, inverted Vigenere Cipher performed on result
; Then, inverted Caesars Cipher performed on result 

       Decrypt AND R6,R6,#0 ; clears R6 

	 RightBitShift LD R0, z1 ; loads R0 with k value 	

	    rsLoop LD R1, message ; 
	    	   ADD R1,R1,#-1 ; decrements memory address 
	    	   ST R1, message ; 
	    	   LD R1, message ; 
	    	   LD R3, message ; 
	    	   AND R4,R4,#0 ;
	    	   ADD R4,R4,#2 ; 
	    	   JSR Div ; Divides message by 2, quotient stored in R5 
	    	   AND R2,R2,#0; clears R2 
	    	   ADD R2,R5,R2; R2 = R5, aka message divided by 2 
	    	   NOT R5,R5 ; 
	    	   ADD R5,R5,#1 ; R5 is now negative 
	    	   ADD R1,R1,R5 ;  pi - (pi / 2) (right bit shift by one)
	    	   STI R1,message ; stores result in message 
	    	   ADD R6,R6,#1 ; counts number of stored characters 
	    	   ADD R0,R0,#-1 ; decrements k value 
	    	   BRp rsLoop ;

BRNzp next 
varLabel 

	ccNum .BLKW 3 ; y1y2y3 for Caesars Cipher 
	message .BLKW 10 ; space for string of 10 character 
	inputkey .STRINGZ "Input Key:\n"
	inputchar .STRINGZ "Input Char:\n"
	modVal .FILL #128 ; 
	hundredVal .FILL #100 ; 
	ASCI_OFFSET .FILL #-48 ; ascii offset for numbers 
	ccAddress .FILL x4150 ; address to store y1y2y3
	messageAddress .FILL x4000 ; initial address location for message 
	ENTER_VALUE .FILL #-10 ; negative ASCII value of enter  on keyboard 
	ExitingProgram .STRINGZ "Exiting program\n"
	EnterText .STRINGZ "Enter plain text of at most length 10. When done press <enter>\n"

toHalt2
BRNzp toHalt3

ProgramLoop
BRNzp ProgramLoop1
next 

; inverse of XOR is XOR, therefore, the message from the previous step XOR K, will equal the original output 
     inverseVC  AND R2,R2,#0 ; clears R2 
	         	ADD R2,R6,#0 ; number of characters stored from before here 
	         	AND R1,R1,#0 ; keeps track of number of characters stored 
	   			BRz inverseCC ; if 0 characters left, continue to next step in encryption
	   	ivcLoop LD R4,ccNum ; loads R4 with key (btwn 0 and 128)
	   			AND R3,R3,#0 ; pi stored here 
			    LD R0,message ; loads R0 with message pi
			    ADD R0,R0,#1 ; increments message address 
			    ST R0, message ; stores incremented address in message
			    LD R3, message ; loads R3 with message 
			    JSR Xor ; XOR's R3 and R4, stores in R0
			    STI R0, message ;  stores result of pi XOR k in message 
			    ADD R1,R1,#1 ; increments counter of characters stored 
			    ADD R2,R2,#-1 ; decrements number of characters stored from bit shift  
			    BRp ivcLoop ; uses counter from right bit shift to figure out when to stop

     inverseCC LD R0,ccNum ; loads R0 with ccNum value 
			   NOT R0,R0 ; 
			   ADD R0,R0,#1 ; Key is now negative 
			   AND R1,R1,#0 ; clears R1 

	    iccLoop LD R2,message ; loads R2 with message 
			   ADD R2,R2,#-1 ; decrements message address
			   ST R2,message ; stores decremented address 
			   LD R3, message ; loads R3 with message 
			   ADD R3,R3,R0 ; R1 = Ci - k
			   LD R4,modVal ; loads R4 with 128
			   JSR Div ; divides R3 by R4 aka ci - k mod 128, remainder stored in R6
			   ADD R6,R6,#0 ; sets nzp values 
			   BRn printLoop ; if N-K is negative, print decrypted message 
			   STI R6,message ; stores result in message 
			   ADD R1,R1,#1 ; counts number of values stored 
			   ADD R6,R6,#0 ; sets nzp values 
			   BRp iccLoop ; if N-K is positive, keep looping

printLoop LD R0, messageAddress ; 
    			  ST R0, message 
    	    pLoop LD R0, message ; 
    	    	  PUTS 
    	    	  ADD R0, R0, #1 ;
    	    	  ST R0, message ; 
    	    	  ADD R1,R1,#-1 ; decrements number of values being stored 
    	    	  BRz ProgramLoop ; 
    	    	  ADD R1,R1,#0 ; 
    	    	  Brp pLoop ;
	 
toHalt3
HALT





; Subroutine for Division 
; R3 / R4 = R5 remainder R6 (X / Y = Z remainder R)
; quotient R5 and remainder R6 must be zeroed out before being performed, R0 valid register (zeroed out)
; inverse of 2nd input 
Div  AND R5,R5,#0 ; zeroes out quotient
	 AND R6,R6,#0 ; zeroes out remainder
	 AND R0,R0,#0 ; R0 is temp register 
Check ADD R3, R3, #0 ; sets condition code for x
	  	Brn doneD ; if x is 0 return
	  	ADD R4, R4, #0 ; sets condition code for y 
	  	Brnz doneD ; if y is less than or equal to 0 return
	  	ADD R0, R0, R3 ; sets R0 equal to R3 (x) (temp)
DivLoop ADD R4, R4, #0 ; sets condition code for Y 
		BRn Pos
		NOT R4, R4 ; inverts Y 
		ADD R4, R4, #1 ; Y is now negative 
		ADD R0, R0, R4 ; temp - y  
		ADD R5, R5, #1 ; quotient = quotient + 1 
		ADD R6, R0, #0 ; remainder is equal to temp now 
		ADD R0, R4, R0 ; checks if temp is >= Y 
		BRzp DivLoop 
		ADD R0, R0, #0 ; second check 
		BRn doneD ; if temp is not longer greater than or equal to y then return 
Pos ADD R4, R4, #-1 ; 
	NOT R4, R4 ; return R4 (y) to positive value
	ADD R4, R4, #0 ;
	Brp DivLoop ;
	doneD RET : returns to caller 

; Subroutine for Multiplication
; R3 * R4 = R5, R5 stores product, X * Y = Z 
Mult    AND R5, R5, #0 ; initialize R5 to 0
		ADD R3, R3, #0 ; checks if first value is 0
		BRz doneM 
		ADD R4, R4, #0 ; checks if second value is 0
		BRz doneM 
loopmult ADD R5, R5, R4 ; adds R4 to itself R3 times
; stores result in R5 (adds y to itself x times)
		 ADD R3, R3, #-1 ; decrements R3 
		 Brp loopmult
		 doneM RET ; returns to caller 	

; Subroutine for XOR 
; uses AND and NOT (result of XOR operation stored in R0)
Xor AND R5,R3,R4 
	NOT R5, R5 
	AND R3,R3,R5 
	NOT R3,R3
	AND R4,R4,R5
	NOT R4,R4
	AND R0,R3,R4
	NOT R0,R0
	RET 


.END