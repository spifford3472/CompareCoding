;===================================================================
; Constants File
; Filename: constants.asm
; Created By: Geoffrey Kline
; Copyright: 2022
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

