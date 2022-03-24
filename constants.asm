;===================================================================
; Constant File
; Filename: constants.asm
; Created By: Geoffrey Kline
; Copyright: 2022
;===================================================================

;===================================================================
; Define system registers for the game
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

;===================================================================
; Define constants for the game
;===================================================================
    ;**************************
    ; ZeroPage Memory Constants
    ;**************************
    ZP                                  = $FB       ; ZeroPage Memory Area
    ZP_COLOR_BASE                       = $2F       ; Zero Page location to put base of color map for drawing
    ZP_SHIELD_BASE                      = $31       ; Zero Page location to put base of shield map for drawing

    ;**************************
    ; SCREEN DRAW CONSTANTS
    ;**************************
    MAX_SCREEN_LINES                    = 24        ; Maximum number of Text lines to draw (zero based)
    NUM_SHIELD_LINES                    = 10        ; Number of lines in actual shield (zero based)
    SHIELD_SCREEN_POSITION_LOW_BYTE     = $304D     ; Memory location of low byte for drawing shield to screen
    SHIELD_SCREEN_POSITION_HIGH_BYTE    = $304E     ; Memory location of high byte for drawing shield to screen 
    SCREEN_BASE_OFFSET                  = $30A2     ; Memory location where screen location bytes are stored for shield
    COLOR_SHIELD_BASE                   = $3055     ; Memory location where shield color is stored
    SHIELD_BASE                         = $3000     ; Memory where PETSCII shield graphics are stored
    MAX_SHIELD_LINE                     = $0e       ; What is the max screen line the shield can be rendered on
    MIN_SHIELD_LINE                     = $00       ; What is the top-most line the shield can be rendered on
    
    ;***************************
    ; Neutral Zone Constants
    ;***************************
    NEUTRAL_ZONE_OFFSET                 = $30D6     ; Where the neutral zone is defined in memory
    NEUTRAL_SCREEN_START                = $0414     ; Start the neutral zone at screen location 1044              
    NEUTRAL_SCR_POS_LOW_BYTE            = $304D     ; Memory location of low byte for drawing shield to screen
    NEUTRAL_SCR_POS_HIGH_BYTE           = $304E     ; Memory location of high byte for drawing shield to screen

    ;***************************
    ;SWIRL VALUES
    ;***************************
    SWIRL_CHECK_TRIGGER                 = $3513     ; IRQ counter before checking if SWIRL should generate  
    DEFAULT_SWIRL_LOCATION              = $3525     ; Starting X-Coordinate    


    ;***********************
    ; Sprite Movement 
    ;***********************
    YARS_MOVEMENT_SPEED                 = $03       ; Controls many pixels YAR moves with each user input
    BULLET_MOVEMENT_SPEED               = $04       ; Controls how many pixels Yar's bullet moves 
    MISSLE_MOVEMENT_SPEED               = $01       ; COntrols how many pixels Qotile's missle moves
    SPRITE_MAX_X_COORDINATE             = $30D4     ; Since we move sprites in 2 pixel steps, we limit the x-coordinate

    ;*****************
    ; Bullet Animation
    ;*****************
    BULLET_COLOR_OFFSET_MAX             = $3125     ; Max memory offset for color animation
    BULLET_COLOR_COUNTER                = $3126     ; Current color count offset
    BULLET_COLOR_POINTER                = $3127     ; Start of color map

    ;************************
    ; User/Sprite  Constants
    ;************************
    USER_INPUT_TRIGGER                  = $311B     ; The number of screen interupts to occur before updating the user input
    BUMP_DISTANCE_SETTING               = $03       ; Distance for bump to move left
    YARS_ANIMATION_BASE                 = $3108     ; Base memory location containing offsets for YAR's animation
    YARS_MAX_FRAME_OFFSET               = $310F     ; Number of animation frames used for YAR
    SWIRL_ANIMATION_BASE                = $351b     ; Base memory containing offsets for SWIRL's animation
    SWIRL_MAX_FRAME_OFFSET              = $3521     ; Number of animation frames used for SWIRL
    MISSLE_MOVE_TRIGGER                 = $352B     ; Number of interupts before moving the missle

    ;********************
    ; Caluclation Lookups
    ;********************
    MULTIPLY_TABLE                      = $312F     ; Lookup table to track multiples of 7 to avoid doing multiplication routine

    ;*****************************
    ; Game Over Constants
    ;*****************************
    GAMEMESSAGELENGTH                   = $3501     ; Length of game over message
    GAMEWONMESSAGE                      = $3502     ; Start of game Won Message
    GAMELOSTMESSAGE                     = $350A     ; Start of game lost Message

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
; Define variables for the game
;===================================================================

    ;**************************
    ; SHIELD DRAW CONSTANTS
    ;**************************
    CURRENT_SCREEN_LINE                 = $304F     ; Stores current line number being processed
    TEMP_OFFSET                         = $3050     ; Location to temporarily store offset calculation results
    SHIELD_DISPLAY_LINE_START           = $3051     ; Screen line where shield should start to render
    DRAW_SHIELD                         = $3052     ; Boolean to trigger drawing of shield instead of blank line
    DRAW_SHIELD_LINE                    = $3053     ; Track what line of the shield is being drawn
    SHIELD_DIRECTION                    = $30D5     ; Specifies which direction the shield on the screen is moving

    ;******************
    ; INTERUPT COUNTERS
    ;******************
    SCREEN_INTERUPT_COUNTER             = $3110     ; The number of screen interupts that have occurred since the last screen update
    SCREEN_ANIMATION_TRIGGER            = $3111     ; The number of screen interupts to occur before updating the PETSCII art on the screen
    SPRITE_INTERUPT_COUNTER             = $3112     ; The number of screen interupts that have occurred since the last Sprite update
    SPRITE_ANIMATION_TRIGGER            = $3113     ; The number of screen interupts to occur before updating the sprites
    USER_INPUT_COUNTER                  = $311A     ; The number of screen interupts that have occurred since the last user update
    SWIRL_INTERUPT_COUNTER              = $3515     ; The number of screen interupts that have occurred since the last SWIRL creation check
    MISSLE_INTERUPT_COUNTER             = $352A     ; The number of screen interupts that have occurred since the last missle move
         
    ;***********************
    ; Player Tracking Values
    ;***********************
    SHIELD_BUMP                         = $3120     ; Shield Bump in Progress (0=No 1=Yes) - Used as the nibble of Yar
    BUMP_DISTANCE_LEFT                  = $3121     ; Distance remaining on the shield bump
    BULLET_LIVE                         = $3124     ; Indicate's the status of YAR's bullet
    GAMEOVERFLAG                        = $3500     ; Stores Game Over flag
    GAMEMESSAGEINDICATOR                = $3512     ; Which message to display
    YARS_CURRENT_FRAME                  = $310E     ; Current YAR animation frame
    YARS_X_COORDINATE                   = $3115     ; Memory location to store YAR'S X-coordinate on screen
    YARS_Y_COORDINATE                   = $3116     ; Memory location to store YAR'S Y-coordinate on screen
    JOYSTICK_X                          = $3117     ; Players X Input value
    JOYSTICK_Y                          = $3118     ; Players Y Input Value
    JOYSTICK_FIRE                       = $3119     ; Players Fire Input Value
    YAR_SHIELD_HIT_X_COORDINATE         = $311C     ; Yar Shield Hit screen text position - Y
    YAR_SHIELD_HIT_Y_COORDINATE         = $311D     ; Yar Shield Hit screen text position - X
    SWIRL_LIVE                          = $3516     ; Denotes if SWIRL is Active or off screen
    DISABLE_FIRE_BUTTON                 = $3518     ; If non-zero then fire button should be disabled
    SWIRL_CURRENT_FRAME                 = $3520     ; Current SWIRL animation frame
    SWIRL_COUNTDOWN_RESET_VALUE         = $3523     ; Value to countdown from for SWIRL launch
    SWIRL_COUNTDOWN                     = $3522     ; Storage for countdown timer to fire the SWIRL
    SWIRL_CHASE                         = $3524     ; Flag to indicate if the SWIRL is on the move

    ;**************************
    ; OTHER VALUES
    ;**************************
    RANDOM_NUMBER                       = $D41B     ; Memory location to read a psuedo random number from
    SCREEN_UPDATE_OCCURRED              = $3114     ; Tracks whether the CPU has updated the PETSCII art to be drawn
    TEMP_STORAGE                        = $3054     ; Temporary memory storage
    SWIRL_RUN_COUNT                     = $3517     ; Used to reduce SWIRL appearance
    SWIRL_THRESHOLD                     = $3514     ; Value to compare against random number, if greater then generate a SWIRL

    ;**************************
    ; Enemy SPRITE Locations
    ;**************************
    QOTILE_X_COORDINATE                 = $311E     ; Memory location to Qotile's X-coordinate on screen
    QOTILE_Y_COORDINATE                 = $311F     ; Memory location to Qotile's Y-coordinate on screen
    BULLET_X_COORDINATE                 = $3122     ; Memory location to store YAR's bullet actual x screen position
    BULLET_Y_COORDINATE                 = $3123     ; Memory location to store YAR's bullet actual y screen position
    SWIRL_X_COORDINATE                  = $3519     ; Memory location to store SWIRL's X Coordinate
    SWIRL_Y_COORDINATE                  = $351A     ; Memory location to store SWIRL's Y Coordinate
    MISSLE_X_COORDINATE                 = $3526     ; Memory Location to store Missle's X Coordinate
    MISSLE_Y_COORDINATE                 = $3527     ; Memory Location to store Missle's Y Coordinate
    MISSLE_X_DIRECTION                  = $3528     ; Memory location to store Missle's x direction
    MISSLE_Y_DIRECTION                  = $3529     ; Memory location to store Missle's y direction