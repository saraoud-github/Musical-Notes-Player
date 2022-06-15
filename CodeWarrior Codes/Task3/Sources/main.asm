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


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

            MOVB #$01, DDRT      ;Set the buzzer as an output
            MOVB #$01, PTT
            MOVB #$C7, MCCTL     ;Set modulus down count register to branch to interrupt
            
LOOP                             ;Explained in Task 3 in report 
            MOVW #119, MCCNT     
            JSR DELAY
            MOVW #106, MCCNT
            JSR DELAY
            MOVW #95, MCCNT
            JSR DELAY
            MOVW #89, MCCNT
            JSR DELAY
            MOVW #80, MCCNT
            JSR DELAY
            MOVW #71, MCCNT
            JSR DELAY
            MOVW #63, MCCNT
            JSR DELAY  
            JMP LOOP            ;Jump to LOOP to repeat playing the notes
            
DELAY:
            LDY #750
LOOP1       LDX #750
LOOP2       DBNE X, LOOP2
            DBNE Y, LOOP1
            RTS
            
YourISRLabelHere:                ;Similar to Lab 5 logic
            LDAB PTT
            EORB #$01
            STAB PTT
            MOVB #$FF, MCFLG
            RTI                                                       
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry             ;Reset Vector
            ORG   $FFCA             ;Location of interrupt subroutine in memory
            DC.W  YourISRLabelHere  ;Reserve the location $FFCA for the above interrupt subroutine 
