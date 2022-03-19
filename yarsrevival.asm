;===========================================================================================================
;                                         Yars' Revival
;                                  (c)2022 by Geoffrey Kline
;
; A resonable clone of game "Yar's Revenge". Originally coded by Howard Scott Warshaw in 1982 for Atari.
;===========================================================================================================
; Coding Notes:
;   * Commodore 64 was manufactured between 1982 and 1992
;   * Uses a 6510 MOS processor (enhanced 6502 chip - basically same instruction set)
;   * It is an 8-bit computer that utilizes 16-bit address widths, to be able to address 64K RAM 
;       * Memory is stored in little endian format (low byte first then high byte)
;   * The machine boots directly into basic, so a basic loader was added which creates
;     a simple BASIC program the user can execute upon loading the code.  This BASIC program
;     issues the basic command SYS xxxx, to instruct the system to start executing at memory address xxxx
;===========================================================================================================

;===================================================================
; Write BASIC start routine
; Allows user to enter:
;       LOAD "YARSREVICAL.PRG",8,1
;       RUN
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

;===================================================================
; Load the program into memory start at $0800
; This is a ~32k free RAM area for a BASIC program
; NOTE: First several bytes used to store the 
;       default BASIC startup program
;===================================================================
+start_at $1000

;===================================================================
; Define constants for the game
;===================================================================
    ;**************************
    ; Screen Memory Locations
    ;**************************
    BACKGROUND_COLOR                    = $d021     ; Background color location
    BORDER_COLOR                        = $d020     ; Border color location
    SCREENRAM                           = $0400     ; Location of screen ram
    COLOR_RAM_BASE                      = 54272     ; Location of color ram

    ;**************************
    ; Memory Constants
    ;**************************
    ZP                                  = $FB       ; ZeroPage Memory Area

    ;**************************
    ; SHIELD DRAW CONSTANTS
    ;**************************
    SHIELD_SCREEN_POSITION_LOW_BYTE     = $304D     ; Memory location of low byte for drawing shield to screen
    SHIELD_SCREEN_POSITION_HIGH_BYTE    = $304E     ; Memory location of high byte for drawing shield to screen 
    MAX_SCREEN_LINES                    = 24        ; Maximum number of Text lines to draw (zero based)
    NUM_SHIELD_LINES                    = 10        ; Number of lines in actual shield (zero based)
    SCREEN_BASE_OFFSET                  = $30A2     ; Memory location where screen location bytes are stored for shield
    COLOR_SHIELD_BASE                   = $3055     ; Memory location where shield color is stored
    SHIELD_BASE                         = $3000     ; Memory where PETSCII shield graphics are stored
    CURRENT_SCREEN_LINE                 = $304F     ; Stores current line number being processed
    TEMP_OFFSET                         = $3050     ; Location to temporarily store offset calculation results
    SHIELD_DISPLAY_LINE_START           = $3051     ; Screen line where shield should start to render
    DRAW_SHIELD                         = $3052     ; Boolean to trigger drawing of shield instead of blank line
    DRAW_SHIELD_LINE                    = $3053     ; Track what line of the shield is being drawn
    ZP_COLOR_BASE                       = $2F       ; Zero Page location to put base of color map for drawing
    ZP_SHIELD_BASE                      = $31       ; Zero Page location to put base of shield map for drawing
    TEMP_STORAGE                        = $3054     ; Temporary memory storage

    ;***************************
    ; Neutral Zone
    ;***************************
    NEUTRAL_ZONE_OFFSET                 = $30D6     ; Where the neutral zone is defined in memory
    NEUTRAL_SCREEN_START                = $0414     ; Start the neutral zone at screen location 1044              
    NEUTRAL_SCR_POS_LOW_BYTE            = $304D     ; Memory location of low byte for drawing shield to screen
    NEUTRAL_SCR_POS_HIGH_BYTE           = $304E     ; Memory location of high byte for drawing shield to screen

    ;**************************
    ; INTERUPT VALUES
    ;**************************
    MAX_SHIELD_LINE                     = $0e       ; What is the max screen line the shield can be rendered on
    MIN_SHIELD_LINE                     = $00       ; What is the top-most line the shield can be rendered on
    SHIELD_DIRECTION                    = $30D5     ; Specifies which direction the shield on the screen is moving

    ;**************************
    ; OTHER VALUES
    ;**************************
    RANDOM_NUMBER                       = $D41B     ; Memory location to read a psuedo random number from
    SCREEN_INTERUPT_COUNTER             = $3110     ; The number of screen interupts that have occurred since the last screen update
    SCREEN_ANIMATION_TRIGGER            = $3111     ; The number of screen interupts to occur before updating the PETSCII art on the screen
    SPRITE_INTERUPT_COUNTER             = $3112     ; The number of screen interupts that have occurred since the last Sprite update
    SPRITE_ANIMATION_TRIGGER            = $3113     ; The number of screen interupts to occur before updating the sprites
    SCREEN_UPDATE_OCCURRED              = $3114     ; Tracks whether the CPU has updated the PETSCII art to be drawn
    CLRHOM                              = $E544     ; Commodore 64 Kernal Location of Clear Screen
    GAMEPORT2                           = $DC00     ; Commodore 64 GamePort 2 location
    USER_INPUT_COUNTER                  = $311A     ; The number of screen interupts that have occurred since the last user update
    USER_INPUT_TRIGGER                  = $311B     ; The number of screen interupts to occur before updating the user input
    YARS_MOVEMENT_SPEED                 = $03       ; Controls many pixels YAR moves with each user input
    BULLET_MOVEMENT_SPEED               = $06       ; Controls how many pixels Yar's bullet moves
    SHIELD_BUMP                         = $3120     ; Shield Bump in Progress (0=No 1=Yes)
    BUMP_DISTANCE_LEFT                  = $3121     ; Distance remaining on the shield bump
    BUMP_DISTANCE_SETTING               = $03       ; Distance for bump to move left
    BULLET_LIVE                         = $3124     ; Indicate's the status of YAR's bullet
    BULLET_COLOR_OFFSET_MAX             = $3125     ; Max memory offset for color animation
    BULLET_COLOR_COUNTER                = $3126     ; Current color count offset
    BULLET_COLOR_POINTER                = $3127     ; Start of color map
    MULTIPLY_TABLE                      = $312F     ; Multiply by 7

    ;**************************
    ; SPRITE VALUES
    ;**************************
    YARS_ANIMATION_BASE                 = $3108     ; Base memory location containing offsets for YAR's animation
    YARS_CURRENT_FRAME                  = $310E     ; Current YAR animation frame
    YARS_MAX_FRAME_OFFSET               = $310F     ; Number of animation frames used for YAR
    YARS_SPRITE_POINTER                 = $07f8     ; VICII Chip memory location to store the current animation frame
    QOTILE_SPRITE_POINTER               = $07f9     ; VICII Chip memory location to store Qotile
    BULLET_SPRITE_POINTER               = $07fa     ; VICII Chip memory location to store YAR's BULLET
    YARS_X_COORDINATE                   = $3115     ; Memory location to store YAR'S X-coordinate on screen
    YARS_Y_COORDINATE                   = $3116     ; Memory location to store YAR'S Y-coordinate on screen
    SPRITE_0_X_COOR                     = $d000     ; VICII memory location to update YARs actual x screen position
    SPRITE_0_Y_COOR                     = $d001     ; VICII memory location to update YARs actual y screen position
    SPRITE_0_COLOR                      = $d027     ; VICII memory location to store YAR's color
    SPRITE_1_COLOR                      = $d028     ; VICII memory location to store QOTILE's color
    SPRITE_2_COLOR                      = $d029     ; VICII memory location to store YAR's bullet color
    SPRITE_MODE                         = $d01c     ; VICII memory location to denote each sprites HI-RES or MULTICOLOR value
    SPRITE_X_MSB_LOCATION               = $D010     ; VICII memory location for sprite horizontal 9th bit
    SPRITE_MAX_X_COORDINATE             = $30D4     ; Since we move sprites in 2 pixel steps, we limit the x-coordinate
    JOYSTICK_X                          = $3117     ; Players X Input value
    JOYSTICK_Y                          = $3118     ; Players Y Input Value
    JOYSTICK_FIRE                       = $3119     ; Players Fire Input Value
    YAR_SHIELD_HIT_X_COORDINATE         = $311C     ; Yar Shield Hit screen text position - Y
    YAR_SHIELD_HIT_Y_COORDINATE         = $311D     ; Yar Shield Hit screen text position - X
    QOTILE_X_COORDINATE                 = $311E     ; Memory location to Qotile's X-coordinate on screen
    QOTILE_Y_COORDINATE                 = $311F     ; Memory location to Qotile's Y-coordinate on screen
    BULLET_X_COORDINATE                 = $3122     ; Memory location to store YAR's bullet actual x screen position
    BULLET_Y_COORDINATE                 = $3123     ; Memory location to store YAR's bullet actual y screen position
    SPRITE_1_X_COOR                     = $d002     ; VICII memory location to update QOTILE's actual x screen position
    SPRITE_1_Y_COOR                     = $d003     ; VICII memory location to update QOTILE's actual y screen position
    SPRITE_2_X_COOR                     = $d004     ; VICII memory location to update YAR's bullet actual x screen location
    SPRITE_2_Y_COOR                     = $d005     ; VICII memory location to update YAR's bullet actual y screen location
    SPRITE_BACKGROUND_COLLISIONS        = $d01f     ; VICII register to record sprite to background collisions

    ;**************************
    ; System Color CONSTANTS
    ;**************************
    BLACK               = $00
    WHITE               = $01
    RED                 = $02
    CYAN                = $03
    PURPLE              = $04
    GREEN               = $05
    BLUE                = $06
    YELLOW              = $07
    ORANGE              = $08
    BROWN               = $09
    PINK                = $0a
    DARKGRAY            = $0b
    GRAY                = $0c 
    LIGHTGREEN          = $0d
    LIGHTBLUE           = $0e
    LIGHTGRAY           = $0f
 
;===================================================================
; Main Game Code
;===================================================================
 
    ;**************************
    ; Initialize Game
    ;**************************
InitializeGame:
    ;Initialize Random Numbers
    jsr Setup_Random_Number         ; Intialize process to generate psuedo random numbers
    ;Set Screen Color
    lda #BLACK
    sta BACKGROUND_COLOR
    lda #BLUE
    sta BORDER_COLOR
    jsr CLRHOM                      ; Kernal routine to clear the screen
    lda #$0f 
    sta BUMP_DISTANCE_LEFT
    ;Setup the screen
    jsr Draw_The_Shield             ; Draw the shield
    jsr Draw_Neutral_Zone           ; Draw the Neutral Zone
    jsr Initialize_Sprites          ; Put Sprites on the screen
    ldy #0                          
    sty SCREEN_UPDATE_OCCURRED      ; Setup gameplay timer (based on screen interupt)
    jsr interupts                   ; Initialize the screen interupt
    jmp GamePlay                    ; Jump to main gameplay loop

    ;**************************
    ; Game Play Routine
    ;**************************
GamePlay:
    lda SCREEN_UPDATE_OCCURRED      ; Check if the PETSCII screen has been updated
    cmp #1                          ; If the screen was updated during an interupt
    bne process_updates             ; process the next animation frame                                    
    jmp GamePlay                    ; else loop
process_updates:
    jsr check_screen_update         ; Special coding to get RTS to work correctly (INVESTIGATE::IS THIS REALLY NEEDED)
    jmp GamePlay
check_screen_update:
    jsr process_movement            ; Calculate Shield Move and Neutral zone animation
    ldy #1                          ; Mark the PETSCII Screen as being updated in memory
    sty SCREEN_UPDATE_OCCURRED
    jmp GamePlay


    ;**************************
    ; Mathmatical Formulas
    ; *************************

    ;************************************************
    ; Calculate screen line yar's bullet is occupying
    ;************************************************
    ; Implement screen_line_y = INT((yar_y_position-50)/8)+2
find_YAR_Y_screenline:
    lda YARS_Y_COORDINATE             ; Load the y-coord value of YAR's shield hit
    sec                                         ; Set carry flag for subtraction
    sbc #50                                     ; Subtract #50
    lsr                                         ; Divide by 2, 3 times by shifting 
    lsr                                         ; bits to get value/2^3
    lsr 
    clc                                         ; Clear Carry Flag before Add with Cary
    adc #2                                      ; Add 2 to the equation to offset for sprite looks
    sta YAR_SHIELD_HIT_Y_COORDINATE             ; Store the Y coordinate location
    rts 

    ; Implement screen_line_x = INT((yar_y_position-50)/8)+2
find_YAR_X_screenline:
    lda YARS_X_COORDINATE             ; Load the x-coord value of YAR's shield hit
    sec                                         ; Set carry flag for subtraction
    sbc #24                                     ; Subtract #24
    lsr                                         ; Divide by 2, 3 times by shifting 
    lsr                                         ; bits to get value/2^3
    lsr 
    clc                                         ; Clear Carry Flag before Add with Cary
    adc #2                                      ; Add 2 to the equation to offset for sprite looks
    sta YAR_SHIELD_HIT_X_COORDINATE             ; Store the X coordinate location
    rts 

Calculate_YAR_SHIELD_HIT_Position:
    jsr find_YAR_Y_screenline
    jsr find_YAR_X_screenline
    rts 


    ;**************************
    ; Intialize the Sprites
    ;   Sprite 0 - Yar
    ;**************************
Initialize_Sprites:
    ;Set YARs Sprite Pointers    (Sprites are $40 bytes, offset $C5 means sprite at $40*$C5=$3140)
    lda YARS_ANIMATION_BASE                     ; Load Yar's sprite memory offset (NOTE: this is $C5 in the above calculation)
    sta YARS_SPRITE_POINTER                     ; Store the sprite memory offset for Yar
    lda #$cd                                    ; Load Qotiles sprite memory offset
    sta QOTILE_SPRITE_POINTER                   ; Store the sprite memory offset for Qotile
    lda #$cb                                    ; Load YAR's BULLET sprite memory offset
    sta BULLET_SPRITE_POINTER                   ; Store the sprite memory offset for YAR's BULLET
    ;Turn on Sprites
    lda #$07                                    ; Set which sprites to enable on the screen 1=sprite zero, etc
    sta $d015                                   ; Tell the VICII chip which sprites to enable
    ;Set Yar's position on the screen
    jsr process_sprite_horizontal_movemement    ; Process YARs X-Coor
    lda YARS_Y_COORDINATE                       ; Load YARs y-coord into .A
    sta SPRITE_0_Y_COOR                         ; Set y-coor for Yar
    ;Set Yar's Bullet position
    jsr process_bullet_horizontal_movement
    lda BULLET_Y_COORDINATE
    sta SPRITE_2_Y_COOR
    ;Set Yar's and Qotile's color
    lda WHITE                                   ; Load the white color into .A
    sta SPRITE_0_COLOR                          ; Set YARs color
    sta SPRITE_1_COLOR                          ; Set Qotile's color
    sta SPRITE_2_COLOR                          ; Set YAR's BULLET color
    ;Set Yar to HiRes
    lda #0                                      ; load Hires value to .A
    sta SPRITE_MODE                             ; Store .A into sprite mode
    ;Set Qotile's initial position
    lda QOTILE_Y_COORDINATE                     ; Load Qotiles Y coordinste into .A
    sta SPRITE_1_Y_COOR                         ; Store y-coordinate for Qotile
    ;Set Qotiles X coordinate using 9th bit
    lda QOTILE_X_COORDINATE                     ; Load YAR'S x-coordinate
    asl                                         ; double the coordinate
    sta SPRITE_1_X_COOR
    ;Set Qotiles's 9th bit for x position
    lda SPRITE_X_MSB_LOCATION
    ora #%00000010                              ; Use bit-wise OR to set the bit for sprite 1
    jmp complete_horizontal_movement
    sta SPRITE_X_MSB_LOCATION    
    rts


    ;*************************************
    ; Process movement of Qotile's Shield
    ;*************************************
process_movement:
    ;Shield movement
    ldx SHIELD_DIRECTION                        ; Load the direction the shield should be moving
    cpx #1                                      ; Check if up or down
    bne moveup                                  ; If moving up jump to that section of code else continue
movedown:
    ldy SHIELD_DISPLAY_LINE_START               ; Load the screen line number that the shield begins to be displayed
    cpy #MAX_SHIELD_LINE                        ; Compare the current shield start line number to the max shield start line number
    bne movedown1                               ; if not equal jump to code to move the shield down on the screen
    ldx #0                                      ; else lets change the direction of the shield
    stx SHIELD_DIRECTION                        
    rts 
movedown1:
    iny                                         ; increase the shield start postion on the screen
    sty SHIELD_DISPLAY_LINE_START               ; Store the new start position in memory
    rts  
moveup:
    ldy SHIELD_DISPLAY_LINE_START               ; Load the screen line number that the shield begins to be displayed
    cpy #MIN_SHIELD_LINE                        ; Compare the current shield start line number to the min shield start line number
    bne moveup1                                 ; if not equal jump to code to move the shield up on the screen
    ldx #1                                      ; else lets change the direction of the shield
    stx SHIELD_DIRECTION
    rts
moveup1:
    dey                                         ; decrease the shield start postion on the screen
    sty SHIELD_DISPLAY_LINE_START               ; Store the new start position in memory
    rts

    ;***********************************************
    ; Calculate where Qotile should be on the y axis
    ;***********************************************
Calculate_Qotile_Position:
    ldx SHIELD_DIRECTION                        ; Load the direction the shield should be moving
    cpx #1                                      ; Check if up or down
    bne qotile_moveup
    lda QOTILE_Y_COORDINATE                     ; Load Qotile's current Y location
    clc                                         ; Clear the carry flag
    adc #$08                                    ; Add 8 pixels to the y coordinate for Qotile
    sta QOTILE_Y_COORDINATE                     ; Store Qotile's updated y coordinate
    jmp move_qotile
qotile_moveup:
    lda QOTILE_Y_COORDINATE                     ; Load .A with Qotiles current Y coordinate
    sec                                         ; Set carry flag for subtraction
    sbc #$08                                    ; Reduce Qotile's y-coor by 8 pixels
    sta QOTILE_Y_COORDINATE
move_qotile:
    lda QOTILE_Y_COORDINATE                     ; Qotile only moves in the y axis, so 
    sta SPRITE_1_Y_COOR                         ; no need to update X coordinate    
    rts


RemoveShieldComponent:
    lda YAR_SHIELD_HIT_X_COORDINATE
    sec
    sbc #$0f
    sta TEMP_STORAGE 
    lda YAR_SHIELD_HIT_Y_COORDINATE
    sec
    sbc SHIELD_DISPLAY_LINE_START
    tay 
    lda MULTIPLY_TABLE,y 
    clc 
    adc TEMP_STORAGE
    tay 
    lda #$20
    sta SHIELD_BASE,y
    rts

    ;************************************************************
    ; Detect Yar impact with background
    ; If impact detected then shoot Yar behind the neutral line
    ; Can I add a bit of fancy movement to show the hit
    ; Maybe play some kind of weird shield sound effect
    ;************************************************************
DetectYarBackgroundHit:
    ; Yar can only impact Qotile's shield if Yar's 9th Sprite bit is set
    ; and can only hit the neutral zone if the 9th bit is not set
    ; NOTE: There is no 9th bit instead a new byte needs to be checked SPRITE_X_MSB_LOCATION
    lda SPRITE_X_MSB_LOCATION                   ; Load the 9th bit sprite register
    and #%00000001                              ; use bitwise AND to zero all but Yar's bit
    beq checkNeutralZoneHit                     ; the zero flag is not set 
check_shield_hit:
    lda SPRITE_BACKGROUND_COLLISIONS            ; Load the VICII register that stores sprite/background collisions
    and #%00000001                              ; Use bitwise AND to see if Yar is involved in a collision
    beq finishBackgroundHit                     ; if zero flags not set then no collision
    ; Simple test to turn border yellow if hit
    ;lda #YELLOW
    ;sta BORDER_COLOR
    lda SHIELD_BUMP                             ; Load .A with current Shield bump value
    bne complete_bump_setup                     ; If bump is already started then return else set the value
    lda #$01                                    ; Load .A with an "On" value (1)
    sta SHIELD_BUMP                             ; Turn on shield Bump
    jsr Calculate_YAR_SHIELD_HIT_Position       ; Calculate where YAR hit the shield
    jsr RemoveShieldComponent                   ; Remove the part of the shield hit
complete_bump_setup:
    rts 
checkNeutralZoneHit:   
    lda SPRITE_BACKGROUND_COLLISIONS            ; Load the VICII register that stores sprite/background collisions
    and #%00000001                              ; Use bitwise AND to see if Yar is involved in a collision
    beq finishBackgroundHit                     ; if zero flags not et then no collision
    ; Simple test to turn border yellow if hit
    lda #RED
    sta BORDER_COLOR
    rts                              
finishBackgroundHit:
    lda #BLUE
    sta BORDER_COLOR
    rts 
    

    ;****************************************************************
    ; ProcessIRQ
    ;   Determine if anything needs executed when the interrupt fires
    ;****************************************************************
ProcessIRQ:                   
    lda SCREEN_INTERUPT_COUNTER                 ; Load the screen interupt counter that tracks how many interupts have occurred
    cmp SCREEN_ANIMATION_TRIGGER                ; since the last screen update
    beq action_screen                           ; If the # updates = the trigger value then update the screen
check_sprite_animation:
    lda SPRITE_INTERUPT_COUNTER                 ; Load the sprite interupt counter that tracks how many interupts have occurred
    cmp SPRITE_ANIMATION_TRIGGER                ; since the last screen update
    beq animate_sprites                         ; If the # updates = the trigger value then update the sprites
check_user_input_irq:
    lda USER_INPUT_COUNTER
    cmp USER_INPUT_TRIGGER
    beq Do_User_Commands
complete_irq:
    rts                                         ; done checking for updates
Do_User_Commands:
    jsr Process_User_Input
    jsr Move_The_Player
    jmp complete_irq
action_screen:
    ;Set Qotile's position on the screen
    jsr Calculate_Qotile_Position
    jsr Do_Screen_Animation                     ; Translate the PETSCII screen changes onto the screen
    jmp check_sprite_animation                  ; Jump back to check the sprites

animate_bullet:
    lda BULLET_COLOR_COUNTER
    clc
    adc #$01
    sta BULLET_COLOR_COUNTER
    cmp BULLET_COLOR_OFFSET_MAX
    bcs finish_bullet_animation
    tay
    lda BULLET_COLOR_POINTER,y 
    sta SPRITE_2_COLOR
    rts
finish_bullet_animation:
    lda #$00
    sta BULLET_COLOR_COUNTER
    lda BULLET_COLOR_POINTER
    sta SPRITE_2_COLOR
    rts

animate_sprites:                                
    ldy #0                                      ; Reset Sprite animation counter
    sty SPRITE_INTERUPT_COUNTER
    ; Animate Yar
    ldy YARS_CURRENT_FRAME                      ; Get Yar's current animation frame
    lda YARS_ANIMATION_BASE,y                   ; Load .A with the current animation frame  
    sta YARS_SPRITE_POINTER                     ; Tell VICII chip to load the current animation frame
    iny                                         ; Move to the next higher animation frame reference
    sty YARS_CURRENT_FRAME
    cpy YARS_MAX_FRAME_OFFSET                   ; Compare the current animation frame to the max animation frame (last frame)
    bcc move_sprites                          ; If we not have reached the end of the animation then finish
    ldy #0                                      ; else reset the animation frame to the start
    sty YARS_CURRENT_FRAME
move_sprites:
    ;Set Yar's position on the screen
    jsr process_sprite_horizontal_movemement    ; Put YAR into the correct x position on the screen
    lda YARS_Y_COORDINATE                       ; Put Yar into the correct y position on the screen
    sta SPRITE_0_Y_COOR
finish_sprite:
    jmp Do_User_Commands


    ;Move the bullet
check_bullet_movement:
    lda BULLET_LIVE
    beq move_bullet_with_yar
    jsr process_bullet_horizontal_movement
    lda BULLET_X_COORDINATE
    cmp SPRITE_MAX_X_COORDINATE
    bcc move_bullet                             ; if not at max screen location then continue
    lda #$00                                    ; Load .A with FALSE flag
    sta BULLET_LIVE                             ; Turn Yars bullet off
    lda #$03
    sta BULLET_X_COORDINATE
    jsr process_bullet_horizontal_movement
    jmp bullet_movement_done
move_bullet:
    lda BULLET_X_COORDINATE                       ; Load x-coor
    clc                                         ; Clear Carry Flag before Add with Cary
    adc #BULLET_MOVEMENT_SPEED                    ; MAdd the speed of movement to the x-coor
    sta BULLET_X_COORDINATE                       ; store the new x-coor
    jmp bullet_movement_done
move_bullet_with_yar:
    lda YARS_Y_COORDINATE
    sta BULLET_Y_COORDINATE
    sta SPRITE_2_Y_COOR
bullet_movement_done:
    rts

    ;*****************************************************
    ; Process Updates to the screen and reset the counters
    ;*****************************************************
Do_Screen_Animation:
    ldy #0                                      ; Load a zero value to reset the PETSCII screen update values
    sty SCREEN_INTERUPT_COUNTER                 ; Reset the counters
    sty SCREEN_UPDATE_OCCURRED
    jsr Draw_The_Shield                         ; Draw the current shield location to the VICII memory
    jsr Draw_Neutral_Zone                       ; Draw the neutral zone to the VICII memory
    rts 

;==========================================================================================
; SPRITE Movement Routines
; Process sprite movemement of the screen
;   Each sprite has its own set of coordinate registers which determine where on the screen 
;   the sprites appear.  However, the sprites can move across more than 256 pixels in the
;   horizontal direction, and thus their x coordinate requires 9 bits, one more than is
;   available in an 8 bit memory location.  To accomidate for this the ninth and most
;   significant bit for each sprite is "gathered" in address $D010.  The least significant
;   bit cooresponds to sprite #0, and the most significant to sprite #7
;===========================================================================================
; Process the horizontal movement of sprites
process_sprite_horizontal_movemement:
    lda YARS_X_COORDINATE                       ; Load YAR'S x-coordinate
    asl                                         ; double the coordinate
    sta SPRITE_0_X_COOR                         ; store the result in the proper X register
    bcc clear_yars_ninth_bit                    ; If carry flag from doubling is clear, don't set 9th bit
    ;Set Yar's 9th bit
    lda SPRITE_X_MSB_LOCATION
    ora #%00000001                              ; Use bit-wise OR to set the bit for sprite 0
    jmp complete_horizontal_movement
clear_yars_ninth_bit:
    lda SPRITE_X_MSB_LOCATION
    and #%11111110                              ; Use bit-wise AND to unset the bit for sprite 0
    jmp complete_horizontal_movement
complete_horizontal_movement:
    sta SPRITE_X_MSB_LOCATION                   ; Store .A into X-MSB location for 9th bit
    rts

process_bullet_horizontal_movement:
    lda BULLET_X_COORDINATE                     ; Load YAR'S Bullet x-coordinate
    asl                                         ; double the coordinate
    sta SPRITE_2_X_COOR                         ; store the result in the proper X register
    bcc clear_bullet_ninth_bit                  ; If carry flag from doubling is clear, don't set 9th bit
    ;Set Yar's Bullet 9th bit
    lda SPRITE_X_MSB_LOCATION
    ora #%00000100                              ; Use bit-wise OR to set the bit for sprite 2
    jmp complete_horizontal_bullet_movement
clear_bullet_ninth_bit:
    lda SPRITE_X_MSB_LOCATION
    and #%11111011                              ; Use bit-wise AND to unset the bit for sprite 2
    jmp complete_horizontal_bullet_movement
complete_horizontal_bullet_movement:
    sta SPRITE_X_MSB_LOCATION                   ; Store .A into X-MSB location for 9th bit
    rts

Move_The_Player:
    ;Move YAR
    jsr process_sprite_horizontal_movemement    ; Process the horizontal move
    lda YARS_Y_COORDINATE                       ; set the Y coor
    sta SPRITE_0_Y_COOR                         ; store the new y coor for VICII chip
    rts

;===================================================================
; Game Controller Input
;   The Commodore 64 can handle 2 joysticks connected to 9-pin Atari 
; style connectors.  These are digital joysticks, where switches are
; either on or off, not analog like modern joysticks.
; This game only reads commands from a joystick in port 2
; The data is read from the CIA1 chip with the following bits used
;   1 - Up
;   2 - Down
;   3 - Left
;   4 - Right
;   5 - Fire
; The Commodore 64 internal logic states that is a switch is closed
; it will read zero, otherwise 1.  In simple terms
; if value is 0 then the user is doing something
;===================================================================
Process_User_Input:
    lda SHIELD_BUMP                             ; Load .Y with the current Shield bump value
    beq Start_Joystick_Read                     ; If Yar has not bumped Qotile's shield then allow movement
    ldx BUMP_DISTANCE_LEFT                      ; Load current bump distance into .X
    beq ResetShieldBump                         ; If no more bump movement reset the bump flag
    dex                                         ; Decrement .X
    stx BUMP_DISTANCE_LEFT                      ; Store the .X into the bump distance
    jmp process_left                            ; Move Yar to the left
ResetShieldBump:
    ldx #BUMP_DISTANCE_SETTING                  ; Load the bump distance to travel setting into .X
    stx BUMP_DISTANCE_LEFT                      ; Store .X in memory (Reset distance to bump)
    ldx #$00                                    ; Reset the bump indicator floag
    stx SHIELD_BUMP 
    rts
Start_Joystick_Read:
    jsr get_joystick_command                    ; Get user input
    bcs process_user_movement                   ; If fire button not pressed process any movement
    jsr Press_Fire_Button                       ; PROCESS FIRE BUTTON BEING PUSHED
process_user_movement:
    lda JOYSTICK_X                              ; Load the users joystick x-coordinate request
    beq check_verticle                          ; If the x-coor request = 0 then check y-coor
    bpl process_right                           ; If x-coor is positive then move right
process_left:
    lda YARS_X_COORDINATE                       ; Load YARS x-coordinate
    cmp #$0a                                    ; Check if we are already on left side of screen
    bcc check_verticle                          ; If YAR is as far left as possible check y-coor
    sec                                         ; Set carry flag for subtraction
    sbc #YARS_MOVEMENT_SPEED                    ; Reduce x-coor by the movement speed
    sta YARS_X_COORDINATE                       ; Store the new x-coor
    jmp check_verticle                          ; Check the y-coor
process_right:
    ldy YARS_X_COORDINATE                       ; Load YARS x-coordinate
    cpy #$9f                                    ; Check if we are already at the right side of screen
    bcc do_the_move_right                       ; If not then move right
    ldy #$9f                                    ; Set the max x-coor
    sty YARS_X_COORDINATE                       ; Set YARs max x coord (limit movement to right)
    jmp check_verticle                          ; Check y-coor
do_the_move_right:
    lda YARS_X_COORDINATE                       ; Load x-coor
    clc                                         ; Clear Carry Flag before Add with Cary
    adc #YARS_MOVEMENT_SPEED                    ; MAdd the speed of movement to the x-coor
    sta YARS_X_COORDINATE                       ; store the new x-coor
check_verticle:
    lda JOYSTICK_Y                              ; Load the user inputed y directive
    beq complete_user_input                     ; If user did not enter a y direction then finish
    bmi process_up                              ; If the request is negative move YAR up
process_down:
    lda YARS_Y_COORDINATE                       ; Load YARS y-coordinate
    cmp #$e7                                    ; Compare the Y-Coor to the bottom of the visible screen
    bcc do_the_move_down                        ; If y-coor is less than the bottom of the screen then move
    lda #$e7                                    ; Set YAR to the bottom of the screen
    sta YARS_Y_COORDINATE                       ; store the new y-coor
    jmp complete_user_input                     ; Finish processing move
do_the_move_down:
    lda YARS_Y_COORDINATE                       ; Load YARS y-coordinate
    clc                                         ; Clear the carry before add with carry
    adc #YARS_MOVEMENT_SPEED                    ; Add the speed movement to the down direction
    sta YARS_Y_COORDINATE                       ; Store the new Y-coor
    ldx BULLET_LIVE
    cpx #$01
    bcs complete_user_input
    sta BULLET_Y_COORDINATE
    sta SPRITE_2_Y_COOR
    jmp complete_user_input                     ; Already at bottom of screen so finish
process_up:
    lda YARS_Y_COORDINATE                       ; Load YAR's y-coordinate
    cmp #$30                                    ; Check if YAR is at top of screen
    bcs do_the_move_up                          ; If not then process the up move
    lda #$30                                    ; Set the min y-coor in the visible screen
    sta YARS_Y_COORDINATE                       ; Store the new y-coor
    jmp complete_user_input                     ; finsih processing the move
do_the_move_up:
    sec                                         ; Set the carry flag before subtraction with carry
    sbc #YARS_MOVEMENT_SPEED                    ; Move YAR up by denoted speed
    sta YARS_Y_COORDINATE                       ; Store new y-coord
    ldx BULLET_LIVE
    cpx #$01
    bcs complete_user_input
    sta BULLET_Y_COORDINATE
    sta SPRITE_2_Y_COOR
complete_user_input:
    jsr DetectYarBackgroundHit
    rts                                         ; Return to calling procedure

Press_Fire_Button:
    lda BULLET_LIVE                             ; Load .A with Yar's bullet status
    bne complete_fire_button                    ; Yar's bullet is already active so we can jump back to the calling process
    lda #$01                                    ; Load .A with literal number 1 to indicate the bullet is live
    sta BULLET_LIVE                             ; Store .A value into the BULLET_LIVE status indicator
    ;Set Bullet x,y tto match Yar's x,y
    lda SPRITE_0_Y_COOR                         ; Copy Yar's Y coordinate to the bullet
    sta SPRITE_2_Y_COOR
    lda #$03                                     ; back of screen
    sta SPRITE_2_X_COOR
    lda #$03
    sta BULLET_X_COORDINATE
    lda YARS_Y_COORDINATE
    sta BULLET_Y_COORDINATE
   ;display the bullet
    lda $d015                                   ; Load currently enabled sprites
    ora #%00000100                              ; Calculate OR to turn on Sprite #2 (Bullet)
    sta $d015                                   ; Tell the VICII chip which sprites to enable
complete_fire_button:
    rts                                         ; Return to calling subroutine

; The following routine for the joystick read was originally 
; written by Bill Hindorf and published in the Programmer's
; Reference Guide
get_joystick_command:
    lda GAMEPORT2                               ; Get input from port 2 only
djrrb:
    ldy #0                                      ; This routine reads and decodes the
    ldx #0                                      ; joystick/firebutton input data in
    lsr                                         ; the accumulator. This least significant
    bcs djr0                                    ; 5 bits contain the switch closure
    dey                                         ; information.  If a switch is closed then it
djr0:
    lsr                                         ; produces a zero bit.  if a switch is open then
    bcs drj1                                    ; produces a one bit.  The joystick dir-
    iny                                         ; ections are right, left, forward, backward
drj1:
    lsr                                         ; bit3=right, bit2=left, bit1=backward,
    bcs djr2                                    ; bit0=forward and bit4=fire button.
    dex                                         ; at rts time dx and dy contain 2's compliment
djr2:
    lsr                                         ; direction numbers i.e. $ff=-1, $00=0, $01=1.
    bcs djr3                                    ; JOYSTICK_X=1 (move right), JOYSTICK_X=-1 (move left),
    inx                                         ; JOYSTICK_X=0 (no x change). JOYSTICK_Y=-1 (move up screen),
djr3:    
    lsr                                         ; JOYSTICK_Y=0 (move down screen), JOYSTICK_Y=0 (no y change).
    stx JOYSTICK_X                              ; the forward joystick position corresponds
    sty JOYSTICK_Y                              ; to move up the screen and the backward
    rts                                         ; position to move down screen.
                                                ; NOTE:
                                                ; at rts time the carry flag contains the fire
                                                ; button state. if c=1 then button not pressed.
                                                ; if c=0 then pressed.    


;===================================================================
; Random numbers need to be seeded
;   A simple way to generate a random number on the
;   Commodore 64 is to generate white noise from the
;   sound (SID) chip and ensure no sound is output
;   then just read the current value of of the noise signal
;===================================================================
Setup_Random_Number:
    ;Initialize the SID (sound) chip to generate a noise pattern for Random numbers
    ; Random numbers can be found by looking in $d41b
    lda #$ff                            ; Set the maximum frequency value
    sta $d40e                           ; Set voice 3 frequency low byte
    sta $d40f                           ; Set voice 3 frequency high byte
    lda #$80                            ; Noise waveform, gate bit off (don't play sound)
    sta $d412                           ; set the voice 3 control register
    rts

;===================================================================
; Define Interupt for screen writing
;   In NA the old TV signal as NTSC which runs on a 60 Hz signal
;   This means that old televisions updated the screen 60 times
;   per second.  Since I want graphics to be smooth, I can't
;   update the screen while it is in the middle of being drawn
;   or else I'll see partial updates.  To fix this I wait
;   till the screen draw gets to the bottom of the updateable 
;   screen (just above the bottom border) before I update the
;   screen memory
;===================================================================
interupts:
    sei             ; disable the maskable IRQs
    lda #$7f                
    sta $dc0d       ; disable timer interrupts which can be generated by the two CIA chips    
    sta $dd0d       ; the kernel uses such an interrupt to flash the cursor, scan keyboard, etc
    lda $dc0d       ; by reading these registers we negate any pending CIA irqs
    lda $dd0d       ; if we don't do this, a pending CIA irq might occur after we finish 
                    ; setting up this code, and we don't want that
    lda #$01        ; This is how we tell VICII graphics chip to generate raster interrupt
    sta $d01a
    lda #$7f        ; We want to break about half way down (race the beam) to gove extra cycles to draw
    sta $d012 
    lda #$1b        ; as there are more than 256 rasterlines, the topmost bit of $d011 serves
    sta $d011       ; as the 9th bit for the rasterline we want our IRQ to be triggered
    lda #$35        ; we turn off the BASIC and KERNAL rom here
    sta $01         ; the cpu now sees RAM everywhere except $d000-$e000
                    ; where the register;SID;VICII/etc are still visible
    lda #<irq       ; Setup the address of my interrupt code
    sta $fffe
    lda #>irq
    sta $ffff
    cli             ; Enable maskable interrupts again
    rts
    ;jmp *           ; I don't RTS here as ROMS are switched off, there is no way back to the system

    ;==================================================
    ; irq 
    ;    Interupt code to execute
    ;==================================================
irq:
    ; Being that all kernal irq handles switched off we have to handle a few more 
    ; functions by ourselves.  The registers are not saved and when control is handed
    ; back the executing code will expect the registers to contain what they did when 
    ; control was flipped to the interrupt.  We must save and restore these values
    pha             ; Store register .A into the stack
    txa             ; Transfer .X into .A
    pha             ; Store register .A into the stack
    tya             ; Transfer .Y into .A
    pha             ; Store register .A into the stack
    lda #$ff        ; Clean way of clearing the interrupt condition of the VICII
    sta $d019       ; Inform the VICII that we acknowledged the interrupt, to prevent being reraised
    ldy SCREEN_INTERUPT_COUNTER     ; Load the Screen Aninmation Counter
    iny                             ; Increase the Screen Animation Counter
    sty SCREEN_INTERUPT_COUNTER     ; Store the Screen Animation Counter
    ldy SPRITE_INTERUPT_COUNTER     ; Load the Sprite animation counter
    iny                             ; Increase the sprite animation counter
    sty SPRITE_INTERUPT_COUNTER     ; Store the sprite animation counter
    ldy USER_INPUT_COUNTER          ; Load the User Input counter
    iny                             ; Increase the User Input counter
    sty USER_INPUT_COUNTER          ; Store the user Input counter
    jsr ProcessIRQ
    jsr animate_bullet
    jsr check_bullet_movement
    ;clear sprite to background collision flag to clear erronous hits
    ;register holds value till it is read
    lda SPRITE_BACKGROUND_COLLISIONS
    pla             ; Restore Y register from stack (Remeber stack is LIFO: Last In First Out)
    tay             ; Transfer .A to .Y
    pla             ; Restore X register from stack
    tax             ; Transfer .A to .X
    pla             ; Restore .A from the stack
    rti             ; Return from interrupt

;===================================================================
; Neutral Zone code
;===================================================================
    ;==================================================
    ; Draw the Neutral Zone
    ;    Should be called from the game routine
    ;==================================================
Draw_Neutral_Zone:
    ldx #0                                      ; Set CURRENT_SCREEN_LINE to zero
    stx CURRENT_SCREEN_LINE                     ; Store the CURRENT_SCREEN_LINE to memory
loop_neutral_zone_lines:
    ; Find where on the screen we should start the next neutral zone line at
    lda CURRENT_SCREEN_LINE                     ; Load current screen line number
    asl                                         ; Multiply by 2 (accounts for low and high byte memory locations)
    sta TEMP_OFFSET                             ; Store the result in TEMP_OFFSET
    ldy TEMP_OFFSET                             ; Load TEMP_OFFSET into .Y
    lda NEUTRAL_ZONE_OFFSET,y                   ; Load NEUTRAL ZONE OFFSET, then add .Y for the proper offset into memory
    sta NEUTRAL_SCR_POS_LOW_BYTE                ; Store the value at the defined low byte memory location
    iny                                         ; increate the TEMP_OFFSET by 1
    lda NEUTRAL_ZONE_OFFSET,y                   ; Load NEUTRAL ZONE OFFSET, then add .Y for the proper offset into memory
    sta NEUTRAL_SCR_POS_HIGH_BYTE               ; Store the value at the ddefined high byte memory location
    jsr render_neutral_zone
cleanup_after_neutral_zone_line:
    lda #MAX_SCREEN_LINES                       ; Load the current screen line into the accumulator
    cmp CURRENT_SCREEN_LINE                     ; Compare accumulator to MAX_SCREEN_LINES
    beq complete_neutral_zone                   ; Return from subroutine
    ldy CURRENT_SCREEN_LINE                     ; Load .y with current screen line
    iny                                         ; Increase the current screen line
    sty CURRENT_SCREEN_LINE                     ; Write the new value to the current screen line
    jmp loop_neutral_zone_lines
complete_neutral_zone:
    rts

    ;=========================================
    ; render_neutral_zone
    ;   Routine to control the drawing of the 
    ;   neutral zone on the screen
    ;=========================================
render_neutral_zone:
    lda NEUTRAL_SCR_POS_LOW_BYTE                ; Load the low byte of the first position
    ldx NEUTRAL_SCR_POS_HIGH_BYTE               ; Load the high byte of the first position
    jsr screen_locate                           ; Locate where the screen and memory locations are
    ldy #0                                      ; Set .Y as an index
poke_neutral_zone:
    lda RANDOM_NUMBER                           ; Randomly assign the color to the Neutral Zone character
    sta (ZP+2),y                                ; Store the character color at this ZeroPage memory addr
    jsr Generate_Random_Character               ; Pull a random character for the neutral zone
    txa                                         ; Transfer .X into .A
    sta (ZP),y                                  ; Store .A into screen memory
    iny                                         ; Increment the counter
    cpy #5                                      ; Have we drawn 5 characters
    bne poke_neutral_zone                       ;    No - continue to loop
    rts                                         ;   Yes - Return to subroutine

    ;=========================================
    ; Generate_Random_Character
    ;   Pulls a random number between 0 and 255 
    ;   Loads a character value into .X
    ;   based on the value of the random number
    ;=========================================
Generate_Random_Character:
    lda RANDOM_NUMBER                           ; Pull a random number from the SID (sound) chip
    cmp #193                                    ; If random number > $40 goto char2
    bcc char2
    ldx #160                                    ; display PETSCII code 160 (decimal)
    rts                                         ; return from this subroutine
char2:
    cmp #129                                    ; If random number > $81 goto char3
    bcc char3
    ldx #102                                    ; display PETSCII code 102 (decimal)
    rts                                         ; return from this subroutine
char3:
    cmp #63                                     ; If random number > $C1 goto char4
    bcc char4
    ldx #230                                    ; display PETSCII code 230 (decimal)
    rts                                         ; return from this subroutine
char4:
    ldx #232                                    ; display PETSCII code 232 (decimal)
    rts                                         ; return from this subroutine

;===================================================================
; Qotile's Shield code
;===================================================================
    ;==================================================
    ; Draw the Shield 
    ;    Should be called from the game routine
    ;==================================================
Draw_The_Shield:
    jsr RESET_SHIELD                            ; Ensure all values are correctly set before attempting to draw the PETSCII shield
    jsr render_shield                           ; Display the shield
    rts 

    ;==================================================
    ; NOTE: 
    ; The rest of Qotile's shield code should not be 
    ; called directly, this code is used to put
    ; the shield on the screen
    ;==================================================

    ;==================================================
    ; Reset_Shield 
    ;    Ensures all registers and memory is
    ;    configured before the screen draw starts
    ;==================================================    
RESET_SHIELD:
    ldx #0
    stx DRAW_SHIELD                             ; reset the value to indicate if the shield routine starts
    stx CURRENT_SCREEN_LINE                     ; reset the current screen line to draw
    stx TEMP_OFFSET                             ; reset the offset variable used to jump in memory
    stx DRAW_SHIELD_LINE                        ; Reset the shield line number being rendered
    rts

    ;=========================================
    ; draw_real_shield
    ;   Routine to control the drawing of the 
    ;   shield on the screen
    ;=========================================
draw_real_shield:
    lda SHIELD_SCREEN_POSITION_LOW_BYTE         ; Load the low byte of the first position
    ldx SHIELD_SCREEN_POSITION_HIGH_BYTE        ; Load the high byte of the first position
    jsr screen_locate                           ; Locate where the screen and memory locations are
    ldy #0                                      ; Set .Y as an index
    ; Calculate the offset to start of color memory from 
    ; memory where screen areas are stored for lookup
    ; The shield is 7 characters wide
    ; To find the correct character sequence in memory:
    ; Memory location offset calculation:
    ;       Use the current line to be drawn (zero based)
    ;       shift the line number to the left 3 times (multiple by 8)
    ;       subtract the current shield line number from the answer
    ; Now I can add the offset to the base shield character memory to 
    ; find the correct character to put on the screen
    lda DRAW_SHIELD_LINE                        ; Load line number into .A
    asl                                         ; Shift Left
    asl                                         ; Shift Left
    asl                                         ; Shift Left
    sec                                         ; Set carry flag for subtraction
    sbc DRAW_SHIELD_LINE                        ; Subtract the current shield line
    sta TEMP_OFFSET                             ; Store the result
    ldx TEMP_OFFSET                             ; Load the result to .X

    ;=========================================
    ; real_shield_poke
    ;   Put the correct character on the 
    ;   screen and set the proper color
    ;=========================================
real_shield_poke:
    lda COLOR_SHIELD_BASE,x                     ; Load the character color at COLOR_SHIELD_BASE + x
    sta (ZP+2),y                                ; Store the character color at this ZeroPage memory addr
    lda SHIELD_BASE,x                           ; Load the character stored at SHIELD_BASE + x
    sta (ZP),y                                  ; Store the character at this ZeroPage memory addr
    inx                                         ; Increase .X by one (next memory offset)
    iny                                         ; Increase .Y by one (next screen code)
    cpy #7                                      ; Have we drawn 7 characters yet
    bne real_shield_poke                        ; If no then continue to draw
    rts             

    ;=========================================
    ; draw_blank_shield
    ;   Routine to control the drawing of the 
    ;   blank characters on the screen where
    ;   the shield is not located
    ;   (This cleans up the screen when 
    ;    the shield moves)
    ;=========================================
draw_blank_shield:
    lda SHIELD_SCREEN_POSITION_LOW_BYTE         ; Load the low byte of the first position
    ldx SHIELD_SCREEN_POSITION_HIGH_BYTE        ; Load the high byte of the first position
    jsr screen_locate                           ; Locate where the screen and memory locations are
    ldy #0                                      ; Set .Y as an index

    ;=========================================
    ; blank_shield_poke
    ;   Put the space character on the 
    ;   screen and set the proper color
    ;=========================================    
blank_shield_poke:
    lda #BLACK                                  ; Color Value    
    sta (ZP+2),y                                ; Store the character color at this ZeroPage memory addr
    lda #$20                                    ; Space character in PETSCII
    sta (ZP),y                                  ; Store the character at this ZeroPage memory addr 
    iny                                         ; Increase .Y by one (next screen code)
    cpy #7                                      ; Have we drawn 7 characters yet
    bne blank_shield_poke                       ; If no then continue to draw
    rts 

    ;=============================================
    ; screen_locate
    ;   This code is used by sections needing to 
    ; draw columns.  Its purpose is to
    ; find the next screen location from memory
    ; and load that location into the ZeroPage ram
    ;===============================================    
screen_locate:
    sta ZP                                      ; store the low byte
    stx ZP+1                                    ; store the high byte
    ; add in offset for color memeory
    clc                                         ; Clear the carry flag before the addition
    adc #<COLOR_RAM_BASE                        ; Add the low byte of the color RAM location
    sta ZP+2                                    ; Store the low byte in ZeroPage memory
    txa                                         ; Transfer .X into .A
    adc #>COLOR_RAM_BASE                        ; Add the high byte of the color RAM location
    sta ZP+3                                    ; Store the high byte in ZeroPage memory
    rts 

    ;=============================================
    ; render_shield
    ;   Shield area is a rectangle on the right side of the screen
    ;   Screen is 40x25 characters, and the shield is drawn using 
    ;   PETSCII graphic characters
    ;   The shield can move up and down within the rectangle between
    ;   Line 1, x-position 34-40 and line 25, x-position 34-40
    ;   The screen memory starts at 1024 ($0400)
    ;   The first position on line 1 is 1057 ($0421)
    ;=============================================
render_shield:
    ; Set CURRENT_SCREEN_LINE to Zero
    ldx #0                                      ; Load 0 into .X
    stx CURRENT_SCREEN_LINE                     ; Store .X into the current screen line number

    ;=============================================
    ; loop_every_screen_line
    ;   Check if the shield should be marked for 
    ;   drawing
    ;===============================================     
loop_every_screen_line:
    lda CURRENT_SCREEN_LINE                     ; load current screen line to be rendered
    cmp SHIELD_DISPLAY_LINE_START               ; does the screen line match the start screen line of the shield
    bne continue_shield_draw                    ; If not then continue drawing
mark_shield_for_draw:
    ldx #1                                      ; Load 1 into .X
    stx DRAW_SHIELD                             ; Set the DRAW_SHIELD boolean value to 1 to indicate to draw the shield
continue_shield_draw:
    ; Find where on the screen we should start the next shield line at
    lda CURRENT_SCREEN_LINE                     ; Load current screen line number
    asl                                         ; Multiply by 2 (accounts for low and high byte memory locations)
    sta TEMP_OFFSET                             ; Store the result in TEMP_OFFSET
    ldy TEMP_OFFSET                             ; Load TEMP_OFFSET into .Y
    lda SCREEN_BASE_OFFSET,y                    ; Load SCREEN BASE OFFSET, then add .Y for the proper offset into memory
    sta SHIELD_SCREEN_POSITION_LOW_BYTE         ; Store the value at the defined low byte memory location
    iny                                         ; increate the TEMP_OFFSET by 1
    lda SCREEN_BASE_OFFSET,y                    ; Load SCREEN BASE OFFSET, then add .Y for the proper offset into memory
    sta SHIELD_SCREEN_POSITION_HIGH_BYTE        ; Store the value at the ddefined high byte memory location
    ldx DRAW_SHIELD                             ; Load DRAW_SHIELD boolean into .X
    bne draw_without_blank_line                 ; If not equal to zero, the we should be drawing part of the shield
draw_with_blank_line:
    jsr draw_blank_shield                       ; Draw the blank line
    jmp cleanup_after_shield_line               ; Cleanup and prepare for next line
draw_without_blank_line:
    jsr draw_real_shield                        ; Draw shield line here
cleanup_after_shield_line:
    lda #MAX_SCREEN_LINES                       ; Load the current screen line into the accumulator
    cmp CURRENT_SCREEN_LINE                     ; Compare accumulator to MAX_SCREEN_LINES
    beq render_complete                         ; Complete the draw routine 
    ldy CURRENT_SCREEN_LINE                     ; Load .y with current screen line
    iny                                         ; Increase the current screen line
    sty CURRENT_SCREEN_LINE                     ; Write the new value to the current screen line
    ; Clean up actual shield
    ldx DRAW_SHIELD                             ; Load DRAW_SHIELD boolean into .X
    bne update_actual_shield_draw               ; If not equal to Zero the update values
    jmp loop_every_screen_line                  ; Loop to draw the next line on screen
update_actual_shield_draw:
    lda DRAW_SHIELD_LINE                        ; Load current shield line into .A
    cmp #NUM_SHIELD_LINES                       ; Compare against number of lines in the shield
    bne complete_shield_updates                 ; if all shield lines have not been drawn update for the next line
    lda #0                                      ; Load zero into .A
    sta DRAW_SHIELD                             ; Set the shield subroutine indicator to false
    jmp loop_every_screen_line                  ; Continue drawing the screen
complete_shield_updates:
    ldx DRAW_SHIELD_LINE                        ; Load the line number of the currently drawn shield line into .X
    inx                                         ; Increase the counter by one
    stx DRAW_SHIELD_LINE                        ; Save the new shield line number to memory
    jmp loop_every_screen_line                  ; continue drawing the screen
render_complete:
    rts                                         ; Return to the calling function





;=============================================================
; Data for the game
;   Contains graphics, variable memory, and screen information
;   Data is loaded into memory starting at 28672 ($7000)
;=============================================================
*=$3000

; Shield graphic at $3000
!byte $20, $20, $20, $20, $E9, $A0, $69     ; Line 1  (Start $3000 End $3006)
!byte $20, $20, $E9, $A0, $A0, $69, $20     ; Line 2  (Start $3007 End $300D)
!byte $20, $E9, $A0, $A0, $69, $20, $20     ; Line 3  (Start $300E End $3014)
!byte $20, $A0, $A0, $69, $20, $20, $20     ; Line 4  (Start $3015 End $301B)
!byte $E9, $A0, $69, $20, $20, $20, $20     ; Line 5  (Start $301C End $3022)
!byte $A0, $A0, $20, $20, $20, $20, $20     ; Line 6  (Start $3023 End $3029)
!byte $5F, $A0, $DF, $20, $20, $20, $20     ; Line 7  (Start $302A End $3030)
!byte $20, $A0, $A0, $DF, $20, $20, $20     ; Line 8  (Start $3031 End $3037)
!byte $20, $5F, $A0, $A0, $DF, $20, $20     ; Line 9  (Start $3038 End $303E)
!byte $20, $20, $5F, $A0, $A0, $DF, $20     ; Line 10 (Start $303F End $3045)
!byte $20, $20, $20, $20, $5F, $A0, $DF     ; Line 11 (Start $3046 End $304C)

; Shield/Screen Variables10
!byte $10 ; SHIELD_SCREEN_POSITION_LOW_BYTE [Memory Location = $304D]
!byte $00 ; SHIELD_SCREEN_POSITION_HIGH_BYTE [Memory Location = $304E]
!byte $00 ; CURRENT_SCREEN_LINE [Memory Location = $304F]
!byte $00 ; TEMP_OFFSET [Memory Location = $3050]
!byte $05 ; SHIELD_DISPLAY_LINE_START [Memory Location = $3051]
!byte $00 ; DRAW_SHIELD [Memory Location = $3052]
!byte $00 ; DRAW_SHIELD_LINE [Memory Location = $3053]
!byte $00 ; TEMP_STORAGE [Memory Location = $3054]

; Color for Shield
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 1  (Start $3055 End $305B)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 2  (Start $305C End $3062)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 3  (Start $3063 End $3069)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 4  (Start $306A End $3070)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 5  (Start $3071 End $3077)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 6  (Start $3078 End $307E)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 7  (Start $307F End $3085)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 8  (Start $3086 End $308C)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 9  (Start $308D End $3093)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 10 (Start $3094 End $309A)
!byte $03, $03, $03, $03, $03, $03, $03     ; Line 11 (Start $309b End $30A1)

; Screen Base addresses for potential shield locations low_byte, high_byte pairs
!byte $21, $04  ; Screen Address ($0421 = Line 1, Column 34 [Memory: $30A2, $30A3])
!byte $49, $04  ; Screen Address ($0449 = Line 2, Column 34 [Memory: $30A4, $30A5])
!byte $71, $04  ; Screen Address ($0471 = Line 3, Column 34 [Memory: $30A6, $30A7])
!byte $99, $04  ; Screen Address ($0499 = Line 4, Column 34 [Memory: $30A8, $30A9])
!byte $C1, $04  ; Screen Address ($04C1 = Line 5, Column 34 [Memory: $30AA, $30AB])
!byte $E9, $04  ; Screen Address ($04E9 = Line 6, Column 34 [Memory: $30AC, $30AD])
!byte $11, $05  ; Screen Address ($0511 = Line 7, Column 34 [Memory: $30AE, $30AF])
!byte $39, $05  ; Screen Address ($0539 = Line 8, Column 34 [Memory: $30B0, $30B1])
!byte $61, $05  ; Screen Address ($0511 = Line 9, Column 34 [Memory: $30B2, $30B3])
!byte $89, $05  ; Screen Address ($0511 = Line 10, Column 34 [Memory: $30B4, $30B5])
!byte $B1, $05  ; Screen Address ($0511 = Line 11, Column 34 [Memory: $30B6, $30B7])
!byte $D9, $05  ; Screen Address ($0511 = Line 12, Column 34 [Memory: $30B8, $30B9])
!byte $01, $06  ; Screen Address ($0511 = Line 13, Column 34 [Memory: $30BA, $30BB])
!byte $29, $06  ; Screen Address ($0511 = Line 14, Column 34 [Memory: $30BC, $30BD])
!byte $51, $06  ; Screen Address ($0511 = Line 15, Column 34 [Memory: $30BE, $30BF])
!byte $79, $06  ; Screen Address ($0511 = Line 16, Column 34 [Memory: $30C0, $30C1])
!byte $A1, $06  ; Screen Address ($0511 = Line 17, Column 34 [Memory: $30C2, $30C3])
!byte $C9, $06  ; Screen Address ($0511 = Line 18, Column 34 [Memory: $30C4, $30C5])
!byte $F1, $06  ; Screen Address ($0511 = Line 19, Column 34 [Memory: $30C6, $30C7])
!byte $19, $07  ; Screen Address ($0511 = Line 20, Column 34 [Memory: $30C8, $30C9])
!byte $41, $07  ; Screen Address ($0511 = Line 21, Column 34 [Memory: $30CA, $30CB])
!byte $69, $07  ; Screen Address ($0511 = Line 22, Column 34 [Memory: $30CC, $30CD])
!byte $91, $07  ; Screen Address ($0511 = Line 23, Column 34 [Memory: $30CE, $30CF])
!byte $B9, $07  ; Screen Address ($0511 = Line 24, Column 34 [Memory: $30D0, $30D1])
!byte $E1, $07  ; Screen Address ($0511 = Line 25, Column 34 [Memory: $30D2, $30D3])
!byte $9f ; Sprite Max horizontal movement [Memory: $30D4]
!byte $01 ; Shield Direction of movement [Memory: $30D5]

; Neutral Zone Screen Locations at $30D6
!byte $14, $04  ; Screen Address ($0414 = Line 1, Column 34 [Memory: $30D6, $30D7])
!byte $3c, $04  ; Screen Address ($043c = Line 2, Column 34 [Memory: $30D8, $30D9])
!byte $64, $04  ; Screen Address ($0464 = Line 3, Column 34 [Memory: $30DA, $30DB])
!byte $8c, $04  ; Screen Address ($048c = Line 4, Column 34 [Memory: $30DC, $30DD])
!byte $b4, $04  ; Screen Address ($04b4 = Line 5, Column 34 [Memory: $30DE, $30DF])
!byte $dc, $04  ; Screen Address ($04dc = Line 6, Column 34 [Memory: $30E0, $30E1])
!byte $04, $05  ; Screen Address ($0504 = Line 7, Column 34 [Memory: $30E2, $30E3])
!byte $2c, $05  ; Screen Address ($052c = Line 8, Column 34 [Memory: $30E4, $30E5])
!byte $54, $05  ; Screen Address ($0554 = Line 9, Column 34 [Memory: $30E6, $30E7])
!byte $7c, $05  ; Screen Address ($057c = Line 10, Column 34 [Memory: $30E8, $30E9])
!byte $a4, $05  ; Screen Address ($05a4 = Line 11, Column 34 [Memory: $30EA, $30EB])
!byte $cc, $05  ; Screen Address ($05cc = Line 12, Column 34 [Memory: $30EC, $30ED])
!byte $f4, $05  ; Screen Address ($05f4 = Line 13, Column 34 [Memory: $30EE, $30EF])
!byte $1c, $06  ; Screen Address ($061c = Line 14, Column 34 [Memory: $30F0, $30F1])
!byte $44, $06  ; Screen Address ($0644 = Line 15, Column 34 [Memory: $30F2, $30F3])
!byte $6c, $06  ; Screen Address ($066c = Line 16, Column 34 [Memory: $30F4, $30F5])
!byte $94, $06  ; Screen Address ($0694 = Line 17, Column 34 [Memory: $30F6, $30F7])
!byte $bc, $06  ; Screen Address ($06bc = Line 18, Column 34 [Memory: $30F8, $30F9])
!byte $e4, $06  ; Screen Address ($06e4 = Line 19, Column 34 [Memory: $30FA, $30FB])
!byte $0c, $07  ; Screen Address ($070c = Line 20, Column 34 [Memory: $30FC, $30FD])
!byte $34, $07  ; Screen Address ($0734 = Line 21, Column 34 [Memory: $30FE, $30FF])
!byte $5c, $07  ; Screen Address ($075c = Line 22, Column 34 [Memory: $3100, $3101])
!byte $84, $07  ; Screen Address ($0784 = Line 23, Column 34 [Memory: $3102, $3103])
!byte $ac, $07  ; Screen Address ($07ac = Line 24, Column 34 [Memory: $3104, $3105])
!byte $d4, $07  ; Screen Address ($07d4 = Line 25, Column 34 [Memory: $3106, $3107])

; CREATE VARIABLES FOR THESE
; ReWRITE DELAY LOOP TO TRIGGER EVENTS OFF SCREEN INTERUPT (1/60 sec)
; Put YAR on screen
; Read Joystick
!byte $c5, $c6, $c7, $c8, $c9, $ca  ; Yar's animation frames [Memory: $3108-$310D]
!byte $00                           ; Yar's current animation frame [Memory: $310E]
!byte $06                           ; Yar's max animation frame [Memory: $310F]
!byte $00                           ; Screen animation interupt counter [Memory: $3110]
!byte $09                           ; Screen Interupt action trigger [Memory: $3111]
!byte $00                           ; Sprite animation interupt counter [Memory: $3112]
!byte $03                           ; Sprite animation Interupt action trigger [Memory: $3113]
!byte $00                           ; Screen Update Occurred [Memory: $3114]
!byte $3f, $89                      ; Yar's x & y coordinates [Memory: $3115, $3116]
!byte $00, $00, $00                 ; Players joystick commands [Memory: $3117, $3118, $3119]
!byte $00                           ; User Input interupt counter [Memory: $311A]
!byte $02                           ; User input interupt action trigger [Memory: $311B]
!byte $00                           ; BULLET screen y-coordinate (PETSCII) [Memory: $311C]
!byte $00                           ; BULLET screen x-coordinate (PETSCII) [Memory: $311D]
!byte $1e, $81                      ; Qotile's x & y coordinates [Memory: $311E, $311F]
!byte $00                           ; Shield Bump variable [Memory: $3120]
!byte $0f                           ; Bump Distance [Memory: $3121]
!byte $03, $89                      ; Yar's Bullet x & y coordinates [Memory: $3122, $3123]
!byte $00                           ; Yar's Bullet Status [Memory: $3124]
!byte $06                           ; Yars Bullet color counter max [Memory: $3125]
!byte $00                           ; Yars Bullet color counter [Memory: $3126]
!byte $00, $07, $08, $09, $02, $09, $08, $07 ; Yars bullet colors [Memory $3127-$312E]
!byte $00, $07, $0E, $15, $1C, $23, $2A, $31, $38, $3F, $46  ; Multiply lookup by 7 [Memory $312F-$3139]


*=$3140
; SPRITE IMAGE DATA : 14 images : total size is 896 ($380) bytes.
; ===========================================
; Sprite's for Yar's animation
; ===========================================
; Yar - Image #1 - Offset: $c5
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $30,$00,$00,$0c,$00,$00,$c3,$02,$00,$c0,$c4,$00,$ff,$38,$00,$ff
!byte $38,$00,$ff,$38,$00,$ff,$38,$00,$c0,$c4,$00,$c3,$02,$00,$0c,$00
!byte $00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Yar - Image #2 - Offset: $c6
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00
!byte $18,$00,$00,$86,$00,$00,$c1,$02,$00,$c0,$c4,$00,$ff,$38,$00,$7f
!byte $38,$00,$7f,$38,$00,$ff,$38,$00,$c0,$c4,$00,$c1,$02,$00,$86,$00
!byte $00,$18,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Yar - Image #3 - Offset: $c7
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00,$18,$00,$00
!byte $44,$00,$00,$43,$00,$00,$60,$82,$00,$60,$c4,$00,$7f,$38,$00,$3f
!byte $38,$00,$3f,$38,$00,$7f,$38,$00,$60,$c4,$00,$60,$82,$00,$43,$00
!byte $00,$46,$00,$00,$18,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$01
; Yar - Image #4 - Offset: $c8
!byte $00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$04,$00,$00,$02,$00,$01
!byte $c1,$00,$00,$61,$00,$00,$20,$82,$00,$20,$c4,$00,$3f,$38,$00,$1f
!byte $38,$00,$1f,$38,$00,$3f,$38,$00,$20,$c4,$00,$20,$82,$00,$61,$00
!byte $01,$c3,$00,$00,$02,$00,$00,$04,$00,$00,$08,$00,$00,$00,$00,$01
; Yar - Image #5 - Offset: $c9
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00,$18,$00,$00
!byte $44,$00,$00,$43,$00,$00,$60,$82,$00,$60,$c4,$00,$7f,$38,$00,$3f
!byte $38,$00,$3f,$38,$00,$7f,$38,$00,$60,$c4,$00,$60,$82,$00,$43,$00
!byte $00,$46,$00,$00,$18,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$01
; Yar - Image #6 - Offset: $ca
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00
!byte $18,$00,$00,$86,$00,$00,$c1,$02,$00,$c0,$c4,$00,$ff,$38,$00,$7f
!byte $38,$00,$7f,$38,$00,$ff,$38,$00,$c0,$c4,$00,$c1,$02,$00,$86,$00
!byte $00,$18,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; ===========================================
; Sprite for Yar's bullet
; ===========================================
; Yar - Bullet - Offset: $cb
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00
!byte $ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; ===========================================
; Sprite for Qotile's missle
; ===========================================
; Qotile - Guided Missle - Offset: $cc
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fe,$00,$00,$fe,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06
; ===========================================
; Sprite for Qotile 
; ===========================================
; Qotile - Offset: $cd
!byte $00,$00,$0c,$00,$00,$1c,$00,$00,$3c,$00,$00,$6c,$00,$00,$cc,$00
!byte $01,$8c,$00,$03,$0c,$00,$06,$0c,$00,$1c,$0c,$00,$70,$0c,$00,$7f
!byte $fc,$00,$70,$0c,$00,$1c,$0c,$00,$06,$0c,$00,$03,$0c,$00,$01,$8c
!byte $00,$00,$cc,$00,$00,$6c,$00,$00,$3c,$00,$00,$1c,$00,$00,$0c,$09
; ===========================================
; Sprite's for Qotile's Swirl animation
; ===========================================
; Qotile Swirl - Image #1 - Offset: $ce
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00
!byte $20,$00,$00,$40,$00,$00,$40,$00,$00,$43,$80,$00,$3c,$40,$00,$3c
!byte $20,$04,$3c,$00,$02,$3c,$00,$01,$c2,$00,$00,$02,$00,$00,$02,$00
!byte $00,$04,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Qotile Swirl - Image #2  - Offset: $cf
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00
!byte $10,$00,$00,$20,$00,$00,$20,$00,$00,$20,$00,$00,$3f,$80,$04,$3c
!byte $40,$02,$3c,$20,$01,$fc,$00,$00,$04,$00,$00,$04,$00,$00,$04,$00
!byte $00,$08,$00,$00,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Qotile Swirl - Image #3 - Offset: $d0
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00
!byte $08,$00,$00,$10,$00,$00,$10,$00,$00,$10,$00,$04,$18,$00,$02,$3f
!byte $80,$01,$fc,$40,$00,$18,$20,$00,$08,$00,$00,$08,$00,$00,$08,$00
!byte $00,$10,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Qotile Swirl - Image #4 - Offset: $d1
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00
!byte $04,$00,$00,$08,$00,$00,$08,$00,$04,$08,$00,$02,$18,$00,$01,$fc
!byte $00,$00,$3f,$80,$00,$18,$40,$00,$10,$20,$00,$10,$00,$00,$10,$00
!byte $00,$20,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
; Qotile Swirl - Image #4 - Offset: $d2
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $01,$80,$02,$02,$00,$02,$04,$00,$01,$04,$00,$00,$fc,$00,$00,$3c
!byte $00,$00,$3c,$00,$00,$3f,$00,$00,$20,$80,$00,$20,$40,$00,$40,$40
!byte $01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
