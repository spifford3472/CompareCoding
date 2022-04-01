;===================================================================
; Memory Data 3500
; Filename: data_3500.asm
; Created By: Geoffrey Kline
; Copyright: 2022
;===================================================================

*=$3500
!byte $00                           ; Game Over Flag [Memory: $3500]
!byte $08                           ; Message Length [Memory: $3501]
!byte $19, $0F, $15, $20, $17, $0F, $0E, $21    ; Game Won [Memory: $3502 - $3509]
!byte $19, $0F, $15, $20, $0C, $0F, $13, $14    ; Game Lost [Memory: $350A - $3511]
!byte $00                           ; GameMessage [Memory: $3512]
!byte $FA                           ; Swirl Check Trigger [Memory: $3513]
!byte $FF                           ; Swirl Threshold [Memory: $3514]
!byte $00                           ; SWIRL Interupt Counter [Memory: $3515]
!byte $00                           ; SWIRL Live [Memory: $3516]
!byte $00                           ; SWIRL RUN COUNT [Memory: $3517]
!byte $00                           ; Disable Fire button [Memory: $3518]
!byte $8F                           ; SWIRL_X_COORDINATE [Memory: $3519]
!byte $00                           ; SWIRL_Y_COORDINATE [Memory: $351A]
!byte $CE, $CF, $D0, $D1, $D2       ; SWIRL Animation Frames [Memory: $351B - $351F]
!byte $00                           ; SWIRL Current Frame [Memory: $3520]
!byte $05                           ; SWIRL Max Animation [Memory: $3521]  
!byte $00                           ; SWIRL countdown [Memory: $3522]
!byte $78                           ; SWIRL countdown reset value [Memory: $3523]
!byte $00                           ; SWIRL Chase flag [Memory: $3524]
!byte $9C                           ; DEFAULT_SWIRL_LOCATION [Memory: $3525]
!byte $8F                           ; Default Missle X location [Memory: $3526]
!byte $30                           ; Default Missle Y location [Memory: $3527]
!byte $01                           ; Missle's x direction [Memory: $3528]
!byte $01                           ; Missle's y direction [Memory: $3529]
!byte $00                           ; Missle's interrupt counter [Memory: $352A]
!byte $0a                           ; Missle's intrupt trigger value [Memory: $352B]
