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


            ORG RAMStart
 ; Insert here your data definition.
QUOTIENT    DC.W 0          ;quotient of division
DATA        DC.B 0
Remainder   DC.W 0          ;remainder of division


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            
           
mainLoop:
  
          
            JSR INIT_SPI                   ;Initialize SPI
            JSR INIT_LCD                   ;Initialize LCD
            JSR INIT_ATD                   ;Initialize ATD

BEGIN      MOVB #$85, ATD0CTL5             
           BRCLR ATD0STAT0, #$80, *        ;Keep looping until the conversion is complete
           LDAB ATD0DR0L                   ;Load the value into B to be used by PRINT subroutine
           JSR PRINT                       ;Print the value on the screen
           BRA BEGIN                       ;Branch to BEGIN to keep checking if value of the potentiometer changed



INIT_SPI
            BSET MODRR, #$10           ;Explained in Lab 3
            MOVB #$52, SPI0CR1
            MOVB #$10, SPI0CR2
            MOVB #$00, SPI0BR
            LDAB SPI0BR
            LDAB SPI0DR
            RTS
                                        

INIT_LCD                               ;Explained in Lab 3
            LDAA #$33                  ;Loading the first two instructions (4 bits each) into A to initialize PRINT
            JSR  SENDINST              ;Sending instruction to LCD
            
            LDAA #$32                  ;Same for rest of instructions
            JSR  SENDINST
            
            LDAA #$28
            JSR  SENDINST
                                             
            LDAA #$08
            JSR  SENDINST
            
            LDAA #$01
            JSR  SENDINST
          
            LDAA #$06
            JSR  SENDINST
           
            
            LDAA #$0C
            JSR  SENDINST
            
            
            RTS
            
            
            
            
INIT_ATD   MOVB #$80, ATD0CTL2       ;Initiliaze control register 2
           JSR DELAY
           MOVB #$08, ATD0CTL3       ;Initiliaze control register 3
           MOVB #$E0, ATD0CTL4       ;Initiliaze control register 4
           RTS            




PRINT:                                ;PRINT subroutine used to print 3 digits to the screen
            LDAA #$80
            JSR SENDINST
            
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
            