;===================================================================
; Memory Data 3000
; Filename: data_3000.asm
; Created By: Geoffrey Kline
; Copyright: 2022
;===================================================================

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
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 1  (Start $3055 End $305B)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 2  (Start $305C End $3062)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 3  (Start $3063 End $3069)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 4  (Start $306A End $3070)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 5  (Start $3071 End $3077)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 6  (Start $3078 End $307E)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 7  (Start $307F End $3085)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 8  (Start $3086 End $308C)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 9  (Start $308D End $3093)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 10 (Start $3094 End $309A)
!byte $06, $06, $06, $06, $06, $06, $06     ; Line 11 (Start $309b End $30A1)

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
!byte $1e, $81                      ; Qotile's x & y coordinates [Memory: $311E, $311F] (Raw x is $8F)
!byte $00                           ; Shield Bump variable [Memory: $3120]
!byte $0f                           ; Bump Distance [Memory: $3121]
!byte $03, $89                      ; Yar's Bullet x & y coordinates [Memory: $3122, $3123]
!byte $00                           ; Yar's Bullet Status [Memory: $3124]
!byte $06                           ; Yars Bullet color counter max [Memory: $3125]
!byte $00                           ; Yars Bullet color counter [Memory: $3126]
!byte $00, $07, $08, $09, $02, $09, $08, $07 ; Yars bullet colors [Memory: $3127-$312E]
!byte $00, $07, $0E, $15, $1C, $23, $2A, $31, $38, $3F, $46  ; Multiply lookup by 7 [Memory: $312F-$3139]