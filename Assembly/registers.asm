;===================================================================
; Registers File
; Filename: registers.asm
; Created By: Geoffrey Kline
; Copyright: 2022
;===================================================================


    ;***************************
    ; Screen Register Locations
    ;**************************
    BACKGROUND_COLOR                    = $d021     ; Background color location
    BORDER_COLOR                        = $d020     ; Border color location
    SCREENRAM                           = $0400     ; Location of screen ram
    COLOR_RAM_BASE                      = $d400     ; Location of color ram


    ;*****************
    ;* KERNAL ROUTINES
    ;*****************
    CLRHOM                              = $E544     ; Commodore 64 Kernal Location of Clear Screen

    ;********************
    ; User Input Register
    ;********************
    GAMEPORT2                           = $DC00     ; Commodore 64 GamePort 2 location

    ;*****************
    ; Sprite Registers
    ;*****************
    YARS_SPRITE_POINTER                 = $07f8     ; VICII Chip memory location to store the current animation frame
    QOTILE_SPRITE_POINTER               = $07f9     ; VICII Chip memory location to store Qotile
    BULLET_SPRITE_POINTER               = $07fa     ; VICII Chip memory location to store YAR's BULLET
    MISSLE_SPRITE_POINTER               = $07fb     ; VICII Chip memory location to store Missle
    SPRITE_0_X_COOR                     = $d000     ; VICII memory location to update YARs actual x screen position
    SPRITE_0_Y_COOR                     = $d001     ; VICII memory location to update YARs actual y screen position
    SPRITE_0_COLOR                      = $d027     ; VICII memory location to store YAR's color
    SPRITE_1_COLOR                      = $d028     ; VICII memory location to store QOTILE's color
    SPRITE_2_COLOR                      = $d029     ; VICII memory location to store YAR's bullet color
    SPRITE_3_COLOR                      = $d02a     ; VICII memory location to store Qotiles missle color
    SPRITE_MODE                         = $d01c     ; VICII memory location to denote each sprites HI-RES or MULTICOLOR value
    SPRITE_X_MSB_LOCATION               = $d010     ; VICII memory location for sprite horizontal 9th bit
    SPRITE_1_X_COOR                     = $d002     ; VICII memory location to update QOTILE's actual x screen position
    SPRITE_1_Y_COOR                     = $d003     ; VICII memory location to update QOTILE's actual y screen position
    SPRITE_2_X_COOR                     = $d004     ; VICII memory location to update YAR's bullet actual x screen location
    SPRITE_2_Y_COOR                     = $d005     ; VICII memory location to update YAR's bullet actual y screen location
    SPRITE_3_X_COOR                     = $d006     ; VICII memory location to update Qotiles Missle actual x location
    SPRITE_3_Y_COOR                     = $d007     ; VICII memory location to update Qotiles Missle actual y location
    SPRITE_BACKGROUND_COLLISIONS        = $d01f     ; VICII register to record sprite to background collisions
    SPRITE_SPRITE_COLLISIONS            = $d01e     ; VICII register to record sprite to sprite coliisions

    ;********************************
    ; IRQ Registers
    ;********************************
    VIC_CR                              = $D011     ; VIC Control Register
    READ_WRITE_RASTER                   = $D012     ; Read Raster / Write Raster Value for Compare
    VIC_IFLAG_REGISTER                  = $D019     ; VIC Interrupt Flag Register (Bit = 1: IRQ	Occurred)
    IRQ_MASK_REGISTER_1                 = $D01A     ; IRQ Mask Register: 1 = Interrupt Enabled

    ;********************************
    ; SID (Sound) Registers
    ; MOS 6581 Sound Interface Device
    ;********************************
    V3FC_LB                             = $D40E	    ; Voice 3: Frequency Control - Low-Byte
    V3FC_HB                             = $D40F	    ; Voice 3: Frequency Control - High-Byte
    V3CR                                = $D412     ; Voice 3: Control Register
    CIA_CR                              = $DC0D	    ; CIA Interrupt Control Register (Read IRQs/Write Mask)
    CIA_CR2                             = $DD0D     ; CIA Interrupt Control Register (Read NMls/Write Mask)

    TRANSFER_VECTOR_IRQ_HI              = $FFFE     ; IRQ (Hi-Byte)
    TRANSFER_VECTOR_IRQ_LO              = $FFFF     ; IRQ (Lo-Byte)
    
