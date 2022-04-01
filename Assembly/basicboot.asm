;===================================================================
; Basic Boot Loader
; Filename: basicBoot.asm
; Original Code: http://csl.name/post/c64-coding
; Modified By: Geoffrey Kline
; Changes:
;           Feb 10,2022 - Created
; Purpose:
;       Write a BASIC start routine at the start of BASIC program 
; memory.  Once the code is loaded into memory the user can 
; issue a BASIC "run" command in order to execute the compiled
; machine language code
;            Allows user to enter:
;               LOAD "YARSREVICAL.PRG",8,1
;               RUN
;===================================================================

!MACRO start_at .address {
    *=$0801         ; Start at the begiining of BASIC program memory
    !byte $0c, $08, $e6, $07, $9e, $20
    ; $0c $08 = $080c = 2-byte pointer to the next line of the BASIC program
    ; $e6 $07 = $07e6 = 2-byte line number ($07e6 = 2022)
    ; $9e = BASIC token for SYS command
    ; $20 = PETSCII character code for a <space>
    !if .address >= 10000 { !byte 48 + ((.address / 10000) % 10) }
    !if .address >=  1000 { !byte 48 + ((.address /  1000) % 10) }
    !if .address >=   100 { !byte 48 + ((.address /   100) % 10) }
    !if .address >=    10 { !byte 48 + ((.address /    10) % 10) }
    !byte $30 + (.address % 10), $00, $00, $00
    ; $30 + (.address % 10) = PETSCII encoded numbers for decimal starting location
    ; $00 = End of Basic Line
    ; $00 $00 = $0000 = Pointer to the next line of BASIC code ($0000=End Of Program)
    *=.address
}
