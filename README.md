# Musical-Notes-Player
This repo contains an implementation of a music player using HCS12 assembly language on an MC9S12DT256 Freescale microcontroller, interfaced with CSMB12 and mounted on the PBMCUSLK board.

- The on-board potentiometer is used to scroll through six different notes (Do, Re, Fa, Sol, La, Si) that are displayed on the on-board LCD.
- Once the user chooses a desired note, they can select switch 1 to begin playing that note through the on-board buzzer. Depending on the note the on-board LEDs will sequentially light up as the buzzer plays with the slowest LED light up being for Do and the fastest for Si. If the user scrolls with the potentiometer the note will change based on their sequence (do, re, me, etc.). 
- However, if the user selects switch 1 a second time, the same note keeps playing and LEDs' light up at the respective speed, regardless of whether the user moves the potentiometer or not. 
- Selecting switch 2 resets the entire process and the buzzer and LEDS will turn off.
