;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
 
DECIMAL     DC.B 0          ;Number to print
QUOTIENT    DC.W 0          ;Quotient of division
DATA        DC.B 0
Remainder   DC.W 0          ;Remainder of division
NbOfValues  DC.B 0          ;Nb of values that are read from the potentiometer
OFFSET      DC.B 0          ;Access the different values that are stored in VALUE
VALUE       DC.B 0          ;Store the values that are read from the potentiometer

; code section
            ORG   ROMStart


Entry:
_Startup:
           LDS   #RAMEnd+1         ; initialize the stack pointer

           CLI                     ; enable interrupts
                                           ;Similar to Task 1
           JSR INIT_SPI
           JSR INIT_LCD 
           JSR INIT_ATD 
           JSR INIT_BUTTONS                ;Initialize the push buttons SW1 and SW2
                     
BEGIN      MOVB #$85, ATD0CTL5             
           BRCLR ATD0STAT0, #$80, *        ;Keep looping until the conversion is complete
LOOP1      LDAA ATD0DR0L                   ;Load the value into A to be used by PRINT subroutine
           CMPA VALUE                      ;Compare VALUE to contents of register A to check if the value read from the pot. changed 
           BEQ END                         ;If it was read the value 
           
           STAA VALUE                      ;Otherwise, store the value in register A
           JSR  PRINTALL                   ;Jump to PRINTALL subroutine to print all values
           

END        LDAA NbOfValues                 ;
           CMPA #2
           BNE BEGIN
           LDAA PIFP
           ANDA #$02
           BNE  BEGIN
           JMP LOOP1


PRINTALL   LDAA #$80          
           JSR SENDINST       ;Move the cursor to the beginning of the LCD
           
LOOP       LDX #VALUE         ;X points to the start of values in VALUE
           LDAA OFFSET        ;Set A equal to the offset
           LDAB A,X           ;Load into B the value in VALUE at OFFSET
           STAB DECIMAL       ;Move the value in B into DECIMAL data definition
           JSR PRINT          ;Print the value
           LDAA OFFSET        ;Set A equal to the offset
           CMPA NbOfValues    ;Check if all the saved values were printed
           BEQ ENDPRINT       ;If all values are printed exit the loop
           INC OFFSET         ;Otherwise, we still have values to print, so increment the offset
           LDAA #' '          
           JSR SENDDATA       ;Add a space to separate the values on the LCD
           BRA LOOP           ;Keep looping until all values are printed
           
ENDPRINT   MOVB #0, OFFSET    ;Reset OFFSET when all values are printed
           RTS                ;Return to subroutine
               
  
            
INTSUB                              ;Whenever one of the buttons is pushed, we enter the following
            LDAA PIFP               ;Load the content of the interrupt flag register in A to check bits 0 and 1
            ANDA #$01               ;Check bit 0 corresponding to SW1 
            BNE SAVE                ;If bit 0 is 1, we branch to SAVE
            LDAA PIFP               ;Load the content of the interrupt flag register in A to check bits 0 and 1
            ANDA #$02               ;Check bit 1 corresponding to SW2
            BNE RESET               ;If bit 1 is 1, we branch to RESET
                             
            
RESET       MOVB #0, NbOfValues     ;Clear the number of values that are saved
            MOVB #0, OFFSET         ;Clear the offset
            LDAA #$01
            JSR SENDINST            ;Clear the LCD display
            JMP ENDSUB              ;Jump to ENDSUB
            
            
SAVE        LDAA NbOfValues
            CMPA #2
            BEQ LOOP1
            INC NbOfValues          ;Indicating that one more value is being saved
            LDAA NbOfValues         ;Load the number of saved values in register A
            LDX #VALUE              ;X points to the start of the values in VALUE data definition 
            LDAB ATD0DR0L           ;Load the value of the potentiometer in register B
            STAB A,X                ;Save the new value at index NbOfValues in VALUE
            
            
ENDSUB      MOVB #$FF, PIFP         ;Clear the interrupt flags
            RTI                     ;Return from interrupt 

       
INIT_SPI
            BSET MODRR, #$10           ;Explained in Lab 3
            MOVB #$52, SPI0CR1
            MOVB #$10, SPI0CR2
            MOVB #$00, SPI0BR
            LDAB SPI0BR
            LDAB SPI0DR
            RTS
                                        

INIT_LCD                                ;Explained in Lab 3
            LDAA #$33                  ;Loading the first two instructions (4 bits each) into A to initialize PRINT
            JSR  SENDINST              ;Sending instruction to LCD
            
            LDAA #$32                  ;Same for rest of instructions
            JSR  SENDINST
            
            LDAA #$28
            JSR  SENDINST
                                             
            
            LDAA #$01
            JSR  SENDINST
          
            LDAA #$06
            JSR  SENDINST
            
            LDAA #$0C
            JSR  SENDINST
            RTS
            
            
            
                                        ;Explained in Task 1
INIT_ATD   
           MOVB #%10000000, ATD0CTL2
           JSR DELAY
           MOVB #%00001000, ATD0CTL3
           MOVB #%11100000, ATD0CTL4
           RTS 
           
                                        
INIT_BUTTONS                            ;Explained in Lab 6
              MOVB #$FC, DDRP 
              MOVB #$00, RDRP    
              MOVB #$03, PERP
              MOVB #$00, PPSP
              MOVB #$03, PIEP
              MOVB #$FF, PIFP  
              RTS
                      




PRINT:                                ;PRINT subroutine used to print 3 digits to the screen
            LDX #DECIMAL
            
            
            CLRA              ;Clear register A from any junk value
            LDX #100          ;Get the 1st digit of a 3-digit number, we divide by 100
            IDIV              ;Divide the number in register B by 100
            STX QUOTIENT      ;Load the quotient stored in X into QUOTIENT data variable
            STD Remainder     ;Load the remainder stored in D into REMAINDER data variable
          
            LDD QUOTIENT      ;Load the quotient back into B using D
            TBA               ;Load the quotient in B into A
            ADDA #48          ;Add 48 to get the ASCII character
            JSR SENDDATA      ;Print the resulting ASCII character on the LCD 
            
            LDD Remainder     ;Load the remainder back into D
                              ;Same logic is applied in the following lines
            LDX #10           ;Get the 2nd digit, we divide by 10
            IDIV 
            STX QUOTIENT
            STD Remainder
            
            LDD QUOTIENT
            TBA
       
            ADDA #48
            JSR SENDDATA
            LDD Remainder    
            TBA
            
            ADDA #48
            JSR SENDDATA
            
            RTS
            
            
                 
            
SENDINST    
            PSHA                       ;Push the contents of A onto the stack pointer 
            PSHB                       ;Push the contents of B onto the stack pointer
            TAB                        ;Transfering the contents of A to B to keep the instruction
            RORA                       ;Rotating A to the right 4 times to let the 4 MSBs become the 4 LSBs
            RORA
            RORA
            RORA                   
            ANDA #%00001111            ;Keeping only the last 4 bits
            ORAA #%10000000            ;Setting the first bit to 1 starts the writing of the instruction (E), the second bit is set to 0 to state that we are sending an instruction
            BSR  SendSPI               ;Send to SPI
            ANDA #%00001111            ;Now we set the enable (bit 7) to 0 to stop the writing of the instruction
            BSR  SendSPI
            
            BSR DELAY                  ;We need to induce the delay needed for the initialization of the LCD
            
            TBA                        ;Transfer contents of B (previous value of instruction) to A.
            ANDA #%00001111            ;Process is repeated to send the lower order bits
            ORAA #%10000000
            BSR  SendSPI
            ANDA #%00001111
            BSR  SendSPI
            BSR  DELAY
            PULB                       ;Pull the contents of A from the stack pointer
            PULA                       ;Pull the contents of B from the stack pointer
            RTS
            
            
SENDDATA    PSHA
            PSHB
            TAB
            RORA 
            RORA
            RORA
            RORA   
            ANDA #%00001111
            ORAA #%11000000            ; Same as for instruction except for the fact that bit 6 is set to 1 which signals that we're sending data.
            BSR  SendSPI
            ANDA #%00001111
            ORAA #%01000000
            BSR  SendSPI
            
            BSR DELAY
            
            TBA
            ANDA #%00001111
            ORAA #%11000000
            BSR  SendSPI
            ANDA #%00001111
            ORAA #%01000000
            BSR  SendSPI
            BSR DELAY
            PULB
            PULA
            RTS 
                

DELAY       
            PSHX
            LDX #$2555
            DBNE X,*
            PULX
            RTS                       
		             
SendSPI:     
            PSHA
            STAA SPI0DR                ; Storing the contents of A into the SPI data register
            BRCLR SPI0SR,#%00100000,*  ; Keep branching to this line until the 5th bit is cleared. When this bit is 0, no data is left to be sent.
            MOVB SPI0DR, DATA
            MOVB SPI0SR, DATA
            PULA
            RTS         

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            ORG   $FF8E
            DC.W  INTSUB
