;===================================================================
; Variables File
; Filename: variables.asm
; Created By: Geoffrey Kline
; Copyright: 2022
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
