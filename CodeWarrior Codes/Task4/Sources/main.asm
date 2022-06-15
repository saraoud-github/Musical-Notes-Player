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
 
DATA        DC.B 0               ;Used in SendSPI
COUNTER1    DC.B 0               ;Keeps track of how many times SW1 is pressed
DELVAL      DC.B 0               ;Used for each note's delay                                  
COUNTERRESET DC.B 0              ;Keeps track of how many times SW2 is pressed

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
 

INIT_BUZZ                         ;Initialize the buzzer
            MOVB #1, DDRT      
            MOVB #$01, PTT
            MOVB #$C7, MCCTL     


                                        
INIT_ATD                               ;Initialize the potentiometer
            MOVB #%10000000, ATD0CTL2
            JSR DELAY
            MOVB #%00001000, ATD0CTL3
            MOVB #%11100000, ATD0CTL4
      




INIT_SPI                             ;Initiliaze SPI
            MOVB #$52,SPI0CR1
            MOVB #$10,SPI0CR2
            MOVB #$00,SPI0BR
            BSET MODRR,#$10
  
                                        

INIT_LCD                             ;Initialize LCD   
     
         
            LDAA #$33                  
            JSR  SENDINST              
            
            LDAA #$32                  
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
            
INIT_LEDS                           ;Initialize LEDs
             
        BSET DDRB, #%11110000       
        BCLR PORTB, #%11110000      
        BSET PORTB, #%11111111


INIT_BUTTONS                        ;Initialize buttons    
              MOVB #$FC, DDRP 
              MOVB #$00, RDRP    
              MOVB #$03, PERP
              MOVB #$00, PPSP
              MOVB #$03, PIEP
              MOVB #$FF, PIFP            
  
                            
                
READPOT
           MOVB #0, COUNTERRESET
           MOVB #$85, ATD0CTL5             ;Read the value from the potentiometer 
           BRCLR ATD0STAT0, #$80, *        ;Keep looping until the conversion is complete
           LDAA ATD0DR0L                   ;Load the value into register A
           

PRINTDO                                    
            CMPA #36                       ;Compare the value of the potentiometer to the lower bound of Re range
            LBHS  PRINTRE                  ;Branch if higher or same to PRINTRE 
            
            JSR MIDDLE                     ;Otherwise print Do in the middle of the screen
            LDAA #'D'
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA  #' '                           
            JSR SENDDATA
  
       
 
            LDAA COUNTER1                  ;Check if SW1 is pressed
          	CMPA #0                        
            LBEQ  READPOT                  ;If it wasn't branch to READPOT to read a new value from the potentiometer 
          	LBRA  PLAYDO                   ;Otherwise play Do
        
PRINTRE
           
            CMPA #72                       ;Compare the value of the potentiometer to the lower bound of Mi range
            LBHS  PRINTMI
            
            JSR MIDDLE 
          
            
            LDAA #'R'
            JSR SENDDATA
            LDAA #'e'
            JSR SENDDATA
            LDAA  #' '                           
            JSR SENDDATA
        
  
            LDAB COUNTER1
          	CMPB #0
          	LBEQ  READPOT
          	LBRA  PLAYRE
         
        
PRINTMI
           
            CMPA #108                      ;Compare the value of the potentiometer to the lower bound of Fa range
            LBHS  PRINTFA
            
            JSR MIDDLE 
           
            
            LDAA #'M'
            JSR SENDDATA
            LDAA #'i'
            JSR SENDDATA
            LDAA  #' '                           
            JSR SENDDATA
        
  
            LDAB COUNTER1
            CMPB #0
            LBEQ  READPOT
           	LBRA  PLAYMI 
        
                                  
PRINTFA
          
            
            
            CMPA #144                      ;Compare the value of the potentiometer to the lower bound of Sol range
            LBHS  PRINTSOL
            
            JSR MIDDLE 
            
            LDAA #'F'
            JSR SENDDATA
            LDAA #'a'
            JSR SENDDATA
            LDAA  #' '                           
            JSR SENDDATA
       
            LDAB COUNTER1
         	  CMPB #0
          	LBEQ  READPOT
            LBRA  PLAYFA
        
        
PRINTSOL
        
            
            CMPA #180                      ;Compare the value of the potentiometer to the lower bound of La range
            LBHS  PRINTLA
            
            JSR MIDDLE 
            
            
            LDAA #'S'
            JSR SENDDATA
            LDAA #'o'
            JSR SENDDATA
            LDAA #'l'
            JSR SENDDATA

      
       
            LDAB COUNTER1
          	CMPB #0
            LBEQ  READPOT
          	LBRA  PLAYSOL
         
PRINTLA
       
            
            
            CMPA #216                      ;Compare the value of the potentiometer to the lower bound of Si range
            LBHS  PRINTSI
            
            JSR MIDDLE 
            
            LDAA #'L'
            JSR SENDDATA
            LDAA #'a'
            JSR SENDDATA
             LDAA  #' '                           
             JSR SENDDATA
        
            LDAB COUNTER1
      	    CMPB #0
      	    LBEQ  READPOT
      	    LBRA  PLAYLA
        
      
        
PRINTSI
         
            JSR MIDDLE
            LDAA #'S'
            JSR SENDDATA
            LDAA #'i' 
            JSR SENDDATA
            LDAA  #' '                           
            JSR SENDDATA

        
            LDAB COUNTER1
       	    CMPB #0
        	  LBEQ  READPOT
        	  LBRA  PLAYSI
        	 
      	    
      	    JMP READPOT
 
INTSUB                              ;Whenever one of the buttons is pushed, we enter the following
            
            LDAA PIFP               ;Load the content of the interrupt flag register in A to check bits 0 and 1
            ANDA #$01               ;Check bit 0 corresponding to SW1 
            BNE  COUNT              ;If bit 0 is 1, we branch to COUNT
            LDAA PIFP
            ANDA #$02               ;Check bit 1 corresponding to SW2
            LBNE RESET              ;if bit 1 is 1, we branch to RESET
           
           
COUNT                               ;Update the value of COUNTER1 which keeps track of how many times SW1 was pressed
            LDAA COUNTER1
      	    INCA
      	    STAA COUNTER1
            JMP  ENDSUB             ;Jump to ENDSUB to return from interrupt
            
           
           
PLAYDO                              
          
            MOVW #119, MCCNT        ;Load the counter value corresponding to each note (explained in Task 3)                  
            MOVB #28, DELVAL        ;Load the value corresponding to Do delay (largest delay) into DELVAL
       

            BCLR PORTB,#%00010000          ;Turns on LED1
            LDAB DELVAL
            JSR DELAYLED                   ;Jump to DELAYLED subroutine
            
            JSR CHECKRESET                 ;Checks if SW2 is pressed at every point between the LEDs
        
            BCLR PORTB, #%00100000         ;Turns on LED2
            LDAB DELVAL
            JSR DELAYLED
                              
            JSR CHECKRESET

            BCLR PORTB, #%01000000         ;Turns on LED3
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000         ;Turns on LED4
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
        
                                     ;Check the status of COUNTER1
                                     ;Branch to READPOT if SW1 was pressed 0 or 1 time(s), otherwise branch to PLAYDO to save the note
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
            
            JMP PLAYDO
         
      
    
                
PLAYRE     
           
            MOVW #106, MCCNT
            
            MOVB #24, DELVAL
            
                
            BCLR PORTB,#%00010000       
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%00100000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%01000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
        
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
          
         
           
            JMP PLAYRE
                
PLAYMI
            
            MOVW #95, MCCNT
            
            MOVB #20, DELVAL
           
                
            BCLR PORTB,#%00010000       
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%00100000      
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%01000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
            
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
           
         
            JMP PLAYMI
         
PLAYFA                
            
            MOVW #89, MCCNT
            
            MOVB #16, DELVAL
            
                
            BCLR PORTB,#%00010000       
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%00100000      
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%01000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
            
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
           
         
            JMP PLAYFA
                
PLAYSOL         
           
            
            MOVW #80, MCCNT
            
            MOVB #12, DELVAL
           
                
            BCLR PORTB,#%00010000       
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%00100000      
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%01000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
        
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
          
         
            JMP PLAYSOL
         
         
         
PLAYSI  
           
         
            MOVW #63, MCCNT
            
            
            MOVB #4, DELVAL             ;Load the value corresponding to Si delay (smallest delay) into DELVAL
          
                
            BCLR PORTB,#%00010000       
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%00100000      
            LDAB DELVAL
            JSR DELAYLED
                               
            JSR CHECKRESET

            BCLR PORTB, #%01000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET                   

            BCLR PORTB, #%10000000      
            LDAB DELVAL
            JSR DELAYLED
            
            JSR CHECKRESET
            
        
            LDAB COUNTER1
            CMPB #0
            LBEQ READPOT
            CMPB #1
            LBEQ READPOT
          

             JMP PLAYSI           
           

         
                
PLAYLA          
           
            
             MOVW #71, MCCNT
            
             MOVB #8, DELVAL
           
                
             BCLR PORTB,#%00010000       
             LDAB DELVAL
             JSR DELAYLED
                                
             JSR CHECKRESET

             BCLR PORTB, #%00100000      
             LDAB DELVAL
             JSR DELAYLED
                                
             JSR CHECKRESET

             BCLR PORTB, #%01000000      
             LDAB DELVAL
             JSR DELAYLED
             
             JSR CHECKRESET                   

             BCLR PORTB, #%10000000     
             LDAB DELVAL
             JSR DELAYLED
             
             JSR CHECKRESET
        
             LDAB COUNTER1
             CMPB #0
             LBEQ READPOT
             CMPB #1
             LBEQ READPOT
          
         
             JMP PLAYLA
                
 

RESET      
             INC COUNTERRESET       ;Increment SW2 counter 
             BSET PORTB, #%11110000  
             MOVB #0, COUNTER1       ;SW1 counter 
             MOVW #0, MCCNT
             LDAA #$01
             JSR SENDINST            ;Clear the LCD display
             
                      
           
ENDSUB       MOVB #$FF, PIFP         ;Clear the interrupt flags
             RTI                     ;Return from interrupt                          
        
 
 
 
CHECKRESET
            LDAB COUNTERRESET
            CMPB #1                  ;If SW2 is pressed once, stop playing the note and branch to READPOT to read a new value
            LBEQ  READPOT
            RTS
             

MIDDLE
             LDAA #$80
             JSR SENDINST        
             LDAA  #' '                           
             JSR SENDDATA  
             LDAA  #' '                           
             JSR SENDDATA   
             LDAA  #' '                           
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

                                        ;LED Delay
DELAYLED:   
            
            LDY   #50000                 
            DBNE  B,HERE                
            
            BSET PORTB, #%11110000      ;Clears LED junk values
            RTS
           
           
HERE:      DBNE  Y,HERE
           JMP DELAYLED 
                

                                        ;Delay for LCD, explained in previous labs

DELAY           LDX   #$15                          
Loop1           LDY   #$250                         
Loop2           DBNE Y,Loop2                        
                DBNE X,Loop1                        
                RTS                
		             
SendSPI:     
            PSHA
            STAA SPI0DR                
            BRCLR SPI0SR,#%00100000,*  
            MOVB SPI0DR, DATA
            MOVB SPI0SR, DATA
            PULA
            RTS 
            
YourISRLabelHere:                
            LDAB PTT
            EORB #1
            STAB PTT
            MOVB #$80, MCFLG
            RTI                       

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry             ;Reset Vector
            ORG   $FF8E             ;Interrupt vector for push buttons
            DC.W  INTSUB
            ORG   $FFCA             ;Interrupt vector for buzzer 
            DC.W  YourISRLabelHere  