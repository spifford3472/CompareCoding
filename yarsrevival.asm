;===========================================================================================================
;                                         Yars' Revival
;                                  (c)2022 by Geoffrey Kline
;
; A resonable POC of game "Yar's Revenge". Originally coded by Howard Scott Warshaw in 1982 for Atari.
; Purpose of this code is to demonstrate the differences between technology of 1982 and 2022
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

;==================================================
; Load initial source files 
;    These files contain no executable code
;    They are used to group labels for readability
;=================================================
!source "basicboot.asm"
!source "includes.asm"

;===================================================================
; Load the program into memory start at $0800
; This is a ~32k free RAM area for a BASIC program
; NOTE: First several bytes used to store the 
;       default BASIC startup program
;===================================================================
+start_at $1000


;===================================================================
; Main Game Code
;===================================================================
START_GAME:
    jmp InitializeGame



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
    ; Check if game is over
    lda GAMEOVERFLAG                ; Load .A with Game Over flag
    bne Quit_Game                   ; Goto Quit_Game if game has ended
    jsr CheckMissleMove
    ; Check for Screen update
    lda SCREEN_UPDATE_OCCURRED      ; Check if the PETSCII screen has been updated
    cmp #1                          ; If the screen was updated during an interupt
    bne process_updates             ; process the next animation frame                                    
    ; Check for SWIRL
    lda SWIRL_LIVE                  ; Load if SWIRL is active flag
    beq do_swirl_checks             ; If the SWIRL Live flag is false, check if it is time for the SWIRL
    lda #0                          ; SWIRL must be live so reset the swirl counter
    sta SWIRL_INTERUPT_COUNTER      ; Save the updated SWIRL counter
    jmp GamePlay
do_swirl_checks:
    lda SWIRL_INTERUPT_COUNTER      ; Load the current SWIRL Interupt counter
    cmp SWIRL_CHECK_TRIGGER         ; subtract trigger value
    bcs Check_Swirl_Create          ; Need to see if a Swirl is created
    jmp GamePlay                    ; else loop
process_updates:
    jsr check_screen_update         ; Special coding to get RTS to work correctly (INVESTIGATE::IS THIS REALLY NEEDED)
    jmp GamePlay
check_screen_update:
    jsr process_movement            ; Calculate Shield Move and Neutral zone animation
    ldy #1                          ; Mark the PETSCII Screen as being updated in memory
    sty SCREEN_UPDATE_OCCURRED
    jmp GamePlay
Check_Swirl_Create:
    lda #$00                        ; Reset the SWIRL interupt counter
    sta SWIRL_INTERUPT_COUNTER      ; Store the reset SWIRL INTERUPT counter
    lda RANDOM_NUMBER               ; obtain a new random number
    cmp SWIRL_THRESHOLD             ; compare the SWIRL trigger number to the random number
    bpl Try_To_Swirl                ; If the random number is >= SWIRL threshold, then we attempt to SWIRL
    jmp GamePlay
Try_To_Swirl:
    ldy SWIRL_RUN_COUNT             ; Load the number of attempts make to SWIRL
    iny                             ; Increase the attempt number
    sta SWIRL_RUN_COUNT             ; Store the SWIRL attempt count
    lda SWIRL_RUN_COUNT             ; Load the SWIRL attempt count into .A
    cmp #$02                        ; Have we attempted at least twice
    bpl Set_Swirl_On                ; If Yes the allow the SWIRL
    jmp GamePlay
Set_Swirl_On:
    lda #$00                        ; Reset the SWIRL attempts to zero
    sta SWIRL_RUN_COUNT
    lda RANDOM_NUMBER               ; Obtain a new random number and put into 
    sta SWIRL_THRESHOLD             ;   the SWIRL threshold
    lda #$01                        ; Set the SWIRL Live flag to True
    sta SWIRL_LIVE
    ldx SWIRL_COUNTDOWN_RESET_VALUE ; Load value into .X for the SWIRL to wait to launch
    stx SWIRL_COUNTDOWN             ; put the .X value into the Swirl launch countdown
    jmp GamePlay

CheckMissleMove:
    lda MISSLE_INTERUPT_COUNTER
    cmp MISSLE_MOVE_TRIGGER
    bcc complete_missle_check
    lda #$00
    sta MISSLE_INTERUPT_COUNTER
    jsr move_missle
complete_missle_check:
    rts

    ;****************************************
    ; QUIT GAME
    ; Display the win or loss message
    ;****************************************
Quit_Game:
    ; Display Game Over Message
    ldy #0                          ; Set message counter to zero
    lda GAMEMESSAGEINDICATOR        ; Load message indicator
    beq DisplayWin                  ; Jump to win message
DisplayLoss:
    lda GAMELOSTMESSAGE,y           ; Get character to display
    sta $056B,y                     ; Store the character in screen memory
    iny                             ; Increase the message counter
    cpy GAMEMESSAGELENGTH           ; Check if message is completely displayed
    bcs Complete_Game               ; If displayed then quit
    jmp DisplayLoss                 ; Keep displaying
DisplayWin:
    lda GAMEWONMESSAGE,y            ; Get character to display
    sta $056B,y                     ; Store the character in screen memory
    iny                             ; Increase the message counter
    cpy GAMEMESSAGELENGTH           ; Check if message is completely displayed
    bcs Complete_Game               ; If displayed then quit
    jmp DisplayWin                  ; Keep displaying
Complete_Game:
    lda RANDOM_NUMBER               ; Load a random number for color
    sta BORDER_COLOR                ; Set the border color to the random color
    jmp Complete_Game


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

    ;**************************************
    ; Find the position on the text screen
    ; where Yar hit the shield
    ;**************************************
Calculate_YAR_SHIELD_HIT_Position:
    jsr find_YAR_Y_screenline
    jsr find_YAR_X_screenline
    rts 


    ;**************************
    ; Intialize the Sprites
    ;   Sprite 0 - Yar
    ;   Sprite 1 - Qotile/Swirl
    ;   Sprite 2 - Yar's Cannon
    ;   Sprite 3 - Guided Missle
    ;**************************
Initialize_Sprites:
    ;Set YARs Sprite Pointers    (Sprites are $40 bytes, offset $C5 means sprite at $40*$C5=$3140)
    lda YARS_ANIMATION_BASE                     ; Load Yar's sprite memory offset (NOTE: this is $C5 in the above calculation)
    sta YARS_SPRITE_POINTER                     ; Store the sprite memory offset for Yar
    lda #$cd                                    ; Load Qotiles sprite memory offset
    sta QOTILE_SPRITE_POINTER                   ; Store the sprite memory offset for Qotile
    lda #$cb                                    ; Load YAR's BULLET sprite memory offset
    sta BULLET_SPRITE_POINTER                   ; Store the sprite memory offset for YAR's BULLET
    lda #$cc                                     ; Load Missle sprite memory offset
    sta MISSLE_SPRITE_POINTER                   ; Store the sprite memory offset for MISSLE
    ;Turn on Sprites
    lda #$0F                                    ; Set which sprites to enable on the screen 1=sprite zero, etc
    sta $d015                                   ; Tell the VICII chip which sprites to enable
    ;Set Yar's position on the screen
    jsr process_sprite_horizontal_movemement    ; Process YARs X-Coor
    lda YARS_Y_COORDINATE                       ; Load YARs y-coord into .A
    sta SPRITE_0_Y_COOR                         ; Set y-coor for Yar
    ;Set Yar's Bullet position
    jsr process_bullet_horizontal_movement      ; Process Yar's bullet x-coor
    lda BULLET_Y_COORDINATE                     ; Load YARs bullet y-coor
    sta SPRITE_2_Y_COOR                         ; Store the bullet location on screen
    ;Set Yar's and Qotile's color
    lda WHITE                                   ; Load the white color into .A
    sta SPRITE_0_COLOR                          ; Set YARs color
    sta SPRITE_1_COLOR                          ; Set Qotile's color
    sta SPRITE_2_COLOR                          ; Set YAR's BULLET color
    lda BLUE                                    ; Load Blue color into .A
    sta SPRITE_3_COLOR                          ; Set MISSLE color
    ;Set Sprites to HiRes
    lda #0                                      ; load Hires value to .A
    sta SPRITE_MODE                             ; Store .A into sprite mode
    ;Set Qotile's initial position
    lda QOTILE_Y_COORDINATE                     ; Load Qotiles Y coordinste into .A
    sta SPRITE_1_Y_COOR                         ; Store y-coordinate for Qotile
    ;Set Qotiles X coordinate using 9th bit
    lda DEFAULT_SWIRL_LOCATION
    sta SWIRL_X_COORDINATE
    sta QOTILE_X_COORDINATE
    asl                                         ; double the coordinate
    sta SPRITE_1_X_COOR
    ;Set Qotiles's 9th bit for x position
    lda SPRITE_X_MSB_LOCATION
    ora #%00000010                              ; Use bit-wise OR to set the bit for sprite 1
    sta SPRITE_X_MSB_LOCATION 
    jsr complete_horizontal_movement
    ;Set Missle start location
    lda MISSLE_X_COORDINATE
    asl
    sta SPRITE_3_X_COOR
    lda MISSLE_Y_COORDINATE
    sta SPRITE_3_Y_COOR
    lda SPRITE_X_MSB_LOCATION
    ora #%00001000                              ; Use bit-wise OR to set the bit for sprite 3
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
    lda SWIRL_CHASE                             ; Load the SWIRL Chase flag
    beq use_qotile
    lda SWIRL_Y_COORDINATE
    sta SPRITE_1_Y_COOR
use_qotile:
    lda QOTILE_Y_COORDINATE                     ; Qotile only moves in the y axis, so 
    sta SPRITE_1_Y_COOR                         ; no need to update X coordinate    
    sta SWIRL_Y_COORDINATE                      ; Keep Qotile and Swirl on Same Y coordindate
    rts

    ;****************************************************
    ; Calculate what part of the shield should be removed
    ;****************************************************
RemoveShieldComponent:
    lda YAR_SHIELD_HIT_X_COORDINATE             ; Load the text x coordinate
    sec                                         ; Set for Carry
    sbc #$0f                                    ; Subtract $0F (Shield starts at $0F)
    sta TEMP_STORAGE                            ; Temporarily store the offset
    lda YAR_SHIELD_HIT_Y_COORDINATE             ; Load the text y coordinate
    sec                                         ; Set for Carry
    sbc SHIELD_DISPLAY_LINE_START               ; Subtract the start text line of the shield to get how far from top of shield Yar is
    tay                                         ; Transfer value to .Y
    lda MULTIPLY_TABLE,y                        ; Need to multiply the verticle start line by 7 (Use lookup table)
    clc                                         ; Clear the Carry Flag
    adc TEMP_STORAGE                            ; Add the offset x offset to the y offset
    tay                                         ; store the shield memory offset into .Y
    ;Check if block exists
    lda SHIELD_BASE,y                           ; Load the calculated shield position from memory
    cmp #$20                                    ; Compare the memory contents to PETSCII "Space" character
    beq DO_CALC_OFFSET                          ; If it is a space then handle differently
    lda #$20                                    ; Load the PETSCII "Space" character into .A
    sta SHIELD_BASE,y                           ; Set the shield collision location to a space
    rts                                         ; Return
DO_CALC_OFFSET:                                 ; Calculated position is off slightly so lets make a compensation move
    iny                                         ; Move the collision location to the right one character position
    lda #$20                                    ; Load the PETSCII "Space" character into .A
    sta SHIELD_BASE,y                           ; Set the shield collision location to a space
    rts                                         ; Return


Quick_Check_Bullet_Collision:
    lda BULLET_LIVE
    beq stop_quick_check
    lda SPRITE_X_MSB_LOCATION                   ; Load the 9th bit sprite register
    and #%00000100                              ; use bitwise AND to zero all but Yar's bullet bit
    beq stop_quick_check                        ; bullet not on right side of screen, stop check
    lda SPRITE_BACKGROUND_COLLISIONS            ; Load the VICII register that stores sprite/background collisions
    and #%00000100                              ; Use bitwise AND to see if the bullet is involved with a collision
    beq stop_quick_check                        ; no shield impact, stop check
    jsr bullet_hit_shield
stop_quick_check:
    rts


    ;***********************************
    ; Guided Missle
    ; Process the guided missle movement
    ;***********************************
    ;Check if fire button is disable
    ;  If yes then must be in neutral zone, so keep missle moving till boundry then bounce a direction
    ;  If no, calculate the quickest x and y movememnt toward Yar and move 1 pixel in both x and y
move_missle:
    lda DISABLE_FIRE_BUTTON
    beq track_yar
make_move:
    jmp calculateMisslePosition
track_yar:
    ; check if yar location compare to missle then move
    lda YARS_X_COORDINATE
    cmp MISSLE_X_COORDINATE
    bcc missleleft
    ldx #$00
    stx MISSLE_X_DIRECTION
    jmp track_yar_y
missleleft:
    ldx #$01
    stx MISSLE_X_DIRECTION
track_yar_y:
    lda YARS_Y_COORDINATE
    cmp MISSLE_Y_COORDINATE
    bcc missleup
    ldx #$00
    stx MISSLE_Y_DIRECTION
    jmp calculateMisslePosition
missleup:
    ldx #$01
    stx MISSLE_Y_DIRECTION
calculateMisslePosition:
    ldx MISSLE_X_COORDINATE
    lda MISSLE_X_DIRECTION
    beq movemissleright
    dex 
    stx MISSLE_X_COORDINATE
    cpx #$03
    bcc reversemisslex
    jmp misslechecky
movemissleright:
    inx 
    stx MISSLE_X_COORDINATE
    cpx SPRITE_MAX_X_COORDINATE
    bcs reversemisslex
    jmp misslechecky
reversemisslex:
    lda MISSLE_X_DIRECTION
    eor #$01
    sta MISSLE_X_DIRECTION
misslechecky:
    ldx MISSLE_Y_COORDINATE
    lda MISSLE_Y_DIRECTION
    beq movemissledown
    dex 
    stx MISSLE_Y_COORDINATE
    cpx #$30
    bcc reversemissley
    jmp misslemovefinish
movemissledown:
    inx 
    stx MISSLE_Y_COORDINATE
    cpx #$e7
    bcc misslemovefinish
reversemissley:
    lda MISSLE_Y_DIRECTION
    eor #$01
    sta MISSLE_Y_DIRECTION
misslemovefinish:
    lda MISSLE_Y_COORDINATE
    sta SPRITE_3_Y_COOR
    jsr process_missle_horizontal_movemement
    rts


    ;***********************************************************
    ; Detect Bullet Impacts
    ; If the bullet impacts the neutral zone nothing happens
    ; If the bullet impacts the shield, then reset the bullet
    ; If the bullet hits Yar, game over
    ; If the bullet hits Qotile, then win
    ;***********************************************************
DetectBulletImpacts:
    ; Ignore if bullet is not live
    lda BULLET_LIVE
    beq finishBulletImpact                      ; Jump out if bullet is not live
    ; Check for background impact
    ; Yar's bullet can not impact the neutral zone so we can check
    ; the SPRITE_X_MSB_LOCATION to detect what to do
    lda SPRITE_X_MSB_LOCATION                   ; Load the 9th bit sprite register
    and #%00000100                              ; use bitwise AND to zero all but Yar's bullet bit
    beq detect_bullet_and_sprite                ; bullet not on right side of screen, jump and check for sprite impacts
check_bullet_shield_hit:
    lda SPRITE_BACKGROUND_COLLISIONS            ; Load the VICII register that stores sprite/background collisions
    and #%00000100                              ; Use bitwise AND to see if the bullet is involved with a collision
    beq detect_bullet_and_sprite                ; no shield impact, check for sprite collection
    ; Shield hit destroys bullet and resets it
bullet_hit_shield:
    lda #$00                                    ; Load .A with FALSE flag
    sta BULLET_LIVE                             ; Turn Yars bullet live flag off
    lda #$03                                    ; Set the default bullet x-coordinate
    sta BULLET_X_COORDINATE                     ; store the default x-coordinate
    jsr process_bullet_horizontal_movement      ; Move the bullet back to the default start position
    jmp finishBulletImpact                      ; Bullet has been reset, jump back
detect_bullet_and_sprite:
    ; Two conditions to check here
    ; 1) Yar hit by his bullet (He dies)
    ; 2) Bullet hits Quotile (Yar wins)
    lda SPRITE_SPRITE_COLLISIONS                ; Load the VICII register that stores sprite/sprite collisions
    sta TEMP_STORAGE                            ; Store the collision register for later processing
    and #%00000101                              ; use bitwise AND to zero all but YAR and bullet collision flags
    sec                                         ; Set for Carry
    sbc #$05                                    ; Subtract #5, which indicates a collision between sprites 0 and 2
    beq Yar_Shot                                ; If result is 0 then Yar and bullet have collided, so handle the collision
check_bullet_and_qotile:
    lda TEMP_STORAGE                            ; Reload the collision register
    and #%00000110                              ; Use bitwise AND to zero all but Yars bullet and Qotile coliision flags
    sec                                         ; Set for Carry
    sbc #$06                                    ; Subtract #6 which indicates a collision between sprites 1 and 2
    beq Yar_Wins
    jmp finish_bullet_animation
Yar_Shot:
    lda #$01                                    ; Set the GAME OVER flag
    sta GAMEOVERFLAG                            ; Store the Game Over flag
    sta GAMEMESSAGEINDICATOR                    ; Set Game Lost Message for display
    jmp finishBulletImpact
Yar_Wins:
    lda #$01                                    ; Set the GAME OVER flag
    sta GAMEOVERFLAG                            ; Store the Game Over flag
    ldx #$00                                    ; Set game status
    stx GAMEMESSAGEINDICATOR                    ; Set Game Won Message for display
    jmp finishBulletImpact
finishBulletImpact:
    rts

    ;****************************************************
    ; Detect if SWIRL kills Yar
    ; Check if SWIRL impacts with YAR, and if so kill YAR
    ; and end the game
    ;****************************************************
DetectSwirlKillYar:
    lda SWIRL_CHASE                             ; Load the SWIRL Chase flag
    beq no_kill_chance                          ; If the SWIRL Chase flag is zero then swirl isn't chasing and cant kill
    lda SPRITE_SPRITE_COLLISIONS                ; Load the VICII register for sprite to sprite collisions
    and #%00000011                              ; Isolate YAR and SWIRL impact codes (bullet and missle don't impact here)
    cmp #$03                                    ; Check the value >= 3 (should never be higher) then we have an impact
    bcc no_kill_chance                          ; If less than 3 then return
    lda #$01                                    ; Load flag for game over and loss
    sta GAMEOVERFLAG
    sta GAMEMESSAGEINDICATOR
no_kill_chance:
    rts                                         ; Return


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
    lda #$01                                    ; Disable the fire button if in the neutral zone
    sta DISABLE_FIRE_BUTTON                     ; Store the flag update
    rts                              
finishBackgroundHit:
    lda #$00                                    ; Reenable the fire button
    sta DISABLE_FIRE_BUTTON                     ; Store the fire button update
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
    jsr DetectBulletImpacts         ; See if bullet hit anything
    jmp complete_irq
action_screen:
    ;Set Qotile's position on the screen
    jsr Calculate_Qotile_Position
    jsr Do_Screen_Animation                     ; Translate the PETSCII screen changes onto the screen
    jmp check_sprite_animation                  ; Jump back to check the sprites

    ;****************************************************************
    ; animate_bullet
    ;   Rotate the colors of Yar's bullet
    ;****************************************************************
animate_bullet:
    lda BULLET_LIVE
    beq do_bullet_animation
    lda #WHITE
    sta SPRITE_2_COLOR
    rts
do_bullet_animation:
    lda BULLET_COLOR_COUNTER                    ; Load the animation counter for Yar's bullet
    clc                                         ; Clear the carry flag
    adc #$01                                    ; Add one to the animation counter
    sta BULLET_COLOR_COUNTER                    ; Store the new animation counter value
    cmp BULLET_COLOR_OFFSET_MAX                 ; Compare the animation counter value to the max counter value
    bcs finish_bullet_animation                 ; If counter is >= max then reset the counter
    tay                                         ; Transfer .A into Y
    lda BULLET_COLOR_POINTER,y                  ; Load the new animation color from the offset
    sta SPRITE_2_COLOR                          ; Set the new animation color
    rts                                         ; Return
finish_bullet_animation:
    lda #$00                                    ; Reset counter to zero
    sta BULLET_COLOR_COUNTER                    ; store zero as the new counter value
    lda BULLET_COLOR_POINTER                    ; load the first animation color
    sta SPRITE_2_COLOR                          ; change the bullet to the current color
    rts                                         ; return

    ;****************************************************************
    ; animate_sprites
    ;   Put animation into the moving sprites
    ;****************************************************************
animate_sprites:                                
    ldy #0                                      ; Reset Sprite animation counter
    sty SPRITE_INTERUPT_COUNTER
    ;-------------
    ; Animate Yar
    ;------------
    ldy YARS_CURRENT_FRAME                      ; Get Yar's current animation frame
    lda YARS_ANIMATION_BASE,y                   ; Load .A with the current animation frame  
    sta YARS_SPRITE_POINTER                     ; Tell VICII chip to load the current animation frame
    iny                                         ; Move to the next higher animation frame reference
    sty YARS_CURRENT_FRAME
    cpy YARS_MAX_FRAME_OFFSET                   ; Compare the current animation frame to the max animation frame (last frame)
    bcc animate_swirl                           ; If we not have reached the end of the animation then move to next animation
    ldy #0                                      ; else reset the animation frame to the start
    sty YARS_CURRENT_FRAME
animate_swirl:
    ;--------------
    ; Animate Swirl
    ;--------------
    lda SWIRL_LIVE                              ; Load the SWIRL Live flag to .A
    beq ShowQotile                              ; if not set then go to move sprites
    ldy SWIRL_CURRENT_FRAME                     ; Get SWIRL's current frame
    lda SWIRL_ANIMATION_BASE,y                  ; Load .A with the current animation frame
    sta QOTILE_SPRITE_POINTER                   ; Ensure Qotile becomes the SWIRL
    iny                                         ; Move to the next higher animation frame reference
    sty SWIRL_CURRENT_FRAME
    cpy SWIRL_MAX_FRAME_OFFSET                  ; Compare the current SWIRL animation frame to the max animation frame (last frame)
    bcc move_sprites                            ; If we have not reached the end of the animation move on
    ldy #0                                      ; else reset the animation frame to the start
    sty SWIRL_CURRENT_FRAME                     
    jmp move_sprites
ShowQotile:
    lda #$cd                                    ; Load Qotiles sprite memory offset
    sta QOTILE_SPRITE_POINTER                   ; Store the sprite memory offset for Qotile
move_sprites:
    ;Set Yar's position on the screen
    jsr process_sprite_horizontal_movemement    ; Put YAR into the correct x position on the screen
    lda YARS_Y_COORDINATE                       ; Put Yar into the correct y position on the screen
    sta SPRITE_0_Y_COOR
finish_sprite:
    jmp Do_User_Commands

    ;***********************
    ;Move the SWIRL
    ;***********************
check_SWIRL_movement:
    ; Check should we be moving the swirl
    lda SWIRL_CHASE                             ; Load the SWIRL chase flag
    beq finish_SWIRL_movement                   ; If flag not set return out of this routine
    ; Calculate new position of the SWIRL
    lda YARS_Y_COORDINATE                       ; Load the YAR's Y coordinate
    cmp SWIRL_Y_COORDINATE                      ; Compare to the Y of SWIRL
    bcc yar_above_swirl                         ; Jump if YAR is above the SWIRL
yar_below_swirl:
    ldy SWIRL_Y_COORDINATE                      ; Load .Y with the SWIRL Y coordinate
    iny                                         ; Increment Y to move down on the screen
    cpy #$e7                                    ; Compare to $E7 (Are we at bottom of screen?)
    bcc update_swirl_x                          ; Not at bottom of screen keep moving
    ldy #$e7                                    ; Set SWIRL Y-Corrdinate to bottom of screen
    jmp update_swirl_x
yar_above_swirl:
    ldy SWIRL_Y_COORDINATE                      ; Load .Y with SWIRL Y Coordinate
    dey                                         ; Decrement T to move up on the screen
    cpy #$30                                    ; Compare to $30 (Are we at top of screen)
    bcs update_swirl_x                          ; Not at top of screen keep moving
    ldy #$30                                    ; Set SWIRL to top of screen
update_swirl_x:
    sty SWIRL_Y_COORDINATE                      ; Store the new y coordinate
    ldx SWIRL_X_COORDINATE                      ; Load the x coordinate
    dex                                         ; decrememnt the x register by one
    dex                                         ; decrememnt the x register by one
    stx SWIRL_X_COORDINATE
    cpx #$06                                    ; Are we too far to the left
    bcc turn_off_swirl                          ; If we hit the left side return to Qotile
    jsr process_swirl_horizontal_movement       ; Set SWIRL Location
    lda SWIRL_Y_COORDINATE                      ; Set SWIRL Y location
    sta SPRITE_1_Y_COOR
    jsr DetectSwirlKillYar
    jmp finish_SWIRL_movement
turn_off_swirl:                                 ; Turn off the SWIRL and retrun to Qotile
    lda #$00                                    ; Load zero value for flags
    sta SWIRL_CHASE                             ; Set SWIRL Chase to false
    sta SWIRL_LIVE                              ; Set SWIRL Live to false
    sta DISABLE_FIRE_BUTTON                     ; Turn on Fire Button
    lda #$CD                                    ; Set the sprite pointer back to Qotile
    sta QOTILE_SPRITE_POINTER
    lda QOTILE_Y_COORDINATE                     ; load quotile's Y coord back into defaults
    sta SPRITE_1_Y_COOR
    sta SWIRL_Y_COORDINATE
    lda DEFAULT_SWIRL_LOCATION
    sta SWIRL_X_COORDINATE
    sta QOTILE_X_COORDINATE                     ; Load Quotiles x Coordinate
    sta SPRITE_1_X_COOR
    jsr process_swirl_horizontal_movement
finish_SWIRL_movement:
    rts

    ;----------------
    ;Move the bullet
    ;----------------
check_bullet_movement:
    lda BULLET_LIVE                             ; Load the "Is the bullet live" flag
    beq move_bullet_with_yar                    ; if the flag is false (0) then handle default movement
    jsr process_bullet_horizontal_movement      ; Process the horizontal movement 
    lda BULLET_X_COORDINATE                     ; Get the current x position of the bullet
    cmp SPRITE_MAX_X_COORDINATE                 ; compare the bullet x position to the max x position on the screen
    bcc move_bullet                             ; if not at max screen location then continue
    lda #$00                                    ; Load .A with FALSE flag
    sta BULLET_LIVE                             ; Turn Yars bullet live flag off
    lda #$03                                    ; Set the default bullet x-coordinate
    sta BULLET_X_COORDINATE                     ; store the default x-coordinate
    jsr process_bullet_horizontal_movement      ; Move the bullet back to the default start position
    jmp bullet_movement_done                    ; complete the bullet move routine
move_bullet:
    lda BULLET_X_COORDINATE                     ; Load x-coor
    clc                                         ; Clear Carry Flag before Add with Cary
    adc #BULLET_MOVEMENT_SPEED                  ; Add the speed of movement to the x-coor
    sta BULLET_X_COORDINATE                     ; store the new x-coor
    jsr Quick_Check_Bullet_Collision
    jmp bullet_movement_done                    ; complete the bullet move routine
move_bullet_with_yar:
    lda YARS_Y_COORDINATE                       ; load Yars y-coordinate
    sta BULLET_Y_COORDINATE                     ; Set the bullet to the same y location
    sta SPRITE_2_Y_COOR                         ; Set the y position of the bullet on the screen
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

process_swirl_horizontal_movement:
    lda SWIRL_X_COORDINATE                      ; Load SWIRLS's x-coordinate
    asl                                         ; Double the coordinate
    sta SPRITE_1_X_COOR                         ; Store the result in the proper X register
    bcc clear_swirl_ninth_bit
    ;Set SWIRL's 9th bit
    lda SPRITE_X_MSB_LOCATION
    ora #%00000010                              ; Use bitwise OR to set the bit for sprite 1
    jmp complete_swirl_horizontal_movement
clear_swirl_ninth_bit:
    lda SPRITE_X_MSB_LOCATION
    and #%11111101                              ; Use bitwise AND to unset the bit for sprite 1
    jmp complete_swirl_horizontal_movement
complete_swirl_horizontal_movement:
    sta SPRITE_X_MSB_LOCATION
    rts

process_missle_horizontal_movemement:
    lda MISSLE_X_COORDINATE                     ; Load Missle's x-coordinate
    asl                                         ; double the coordinate
    sta SPRITE_3_X_COOR                         ; store the result in the proper X register
    bcc clear_missle_ninth_bit                  ; If carry flag from doubling is clear, don't set 9th bit
    ;Set missle's 9th bit
    lda SPRITE_X_MSB_LOCATION
    ora #%00001000                              ; Use bit-wise OR to set the bit for sprite 3
    jmp complete_missle_horizontal_movement
clear_missle_ninth_bit:
    lda SPRITE_X_MSB_LOCATION
    and #%11110111                              ; Use bit-wise AND to unset the bit for sprite 3
complete_missle_horizontal_movement:
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
    lda DISABLE_FIRE_BUTTON                     ; Load Fire Button disabled flag
    bne process_user_movement                   ; if not equal to zero then do not press the button click
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
    ldy MISSLE_INTERUPT_COUNTER     ; Load the missle movement interupt counter
    iny
    sty MISSLE_INTERUPT_COUNTER
    ldy SWIRL_INTERUPT_COUNTER      ; Load the SWIRL counter
    iny                             ; Increase the SWIRL counter
    sty SWIRL_INTERUPT_COUNTER      ; Store the SWIRL Interupt counter
    lda SWIRL_LIVE                  ; Load the SWIRL Live flag
    beq skip_swirl_irq              ; If flag is not set don't compute countdown to fire 
    ldx SWIRL_COUNTDOWN             ; Load the current SWIRL fire countdown timer
    beq swirl_chase_set
    dex                             ; Decrement the counter by 1
    stx SWIRL_COUNTDOWN             ; Store .X for SWIRL Countdown
    jmp skip_swirl_irq
swirl_chase_set:
    lda #$01                        ; Set flag to True
    sta SWIRL_CHASE                 ; Save the flag into SWIRL CHASE
    sta DISABLE_FIRE_BUTTON         ; Turn off the fire button
skip_swirl_irq:
    jsr ProcessIRQ
    jsr animate_bullet
    jsr check_bullet_movement
    jsr check_SWIRL_movement
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
;   Data is loaded into memory starting at $3000
;=============================================================
!source "binarydata.asm"




