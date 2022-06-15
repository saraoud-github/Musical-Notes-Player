# Musical-Notes-Player
This repo contains an implementation of a music player using HCS12 assembly language on an [MC9S12DT256 Freescale microcontroller](https://html.alldatasheet.com/html-pdf/126901/FREESCALE/MC9S12DT256/490/1/MC9S12DT256.html), interfaced with [CSMB12](https://www.axman.com/content/csmb12-module) and mounted on the [PBMCUSLK board](https://www.nxp.com/pages/mcu-project-board:PBMCUSLK).

- The on-board potentiometer is used to scroll through seven different notes (Do, Re, Mi, Fa, Sol, La, Si) that are displayed on the on-board LCD.
- Once the user chooses a desired note, they can select switch 1 to begin playing that note through the on-board buzzer. Depending on the note the on-board LEDs will sequentially light up as the buzzer plays with the slowest LED light up being for Do and the fastest for Si. If the user scrolls with the potentiometer the note will change based on their sequence (do, re, mi, etc.). 
- However, if the user selects switch 1 a second time, the same note keeps playing and LEDs' light up at the respective speed, regardless of whether the user moves the potentiometer or not. 
- Selecting switch 2 resets the entire process and the buzzer and LEDS will turn off.
