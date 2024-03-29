;===================================================================
; Sprite Data Loader
; Filename: data_sprites.asm
; Created By: Geoffrey Kline
; Copyright 2022
;===================================================================

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
; Qotile Swirl - Image #5 - Offset: $d2
!byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
!byte $01,$80,$02,$02,$00,$02,$04,$00,$01,$04,$00,$00,$fc,$00,$00,$3c
!byte $00,$00,$3c,$00,$00,$3f,$00,$00,$20,$80,$00,$20,$40,$00,$40,$40
!byte $01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
