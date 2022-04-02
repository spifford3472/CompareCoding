import sys, pygame
from Shield import Shield
from Neutral import NeutralZone
from Yar import Yar
from Qotile import Qotile
import time

pygame.init()

fps = 10 # frames per second
size = width, height = 300, 200
speed = [2, 2]
black = (0, 0, 0)

# Initialize the screen 
screen = pygame.display.set_mode(size)
screen.fill(black)

# Initialize the classes
# Create Qotile's shield class instance
qotile_shield = Shield()
qotile_shield.draw_shield()
clock = pygame.time.Clock()
yar = Yar()
yar_animation = pygame.sprite.Group(yar)
neutralzone = NeutralZone()
qotile = Qotile()
qotile_animation = pygame.sprite.Group(qotile)

#Setup the joystick 
joystick1 = pygame.joystick.get_count()
if joystick1 == 0:
    print("No joystick to configure.")
else:
    joystick = pygame.joystick.Joystick(0)
    joystick.init()

# Enter the repeating game loop
while 1:
    for event in pygame.event.get():    
        if event.type == pygame.QUIT:
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_d:
                yar.move_right()
            if event.key == pygame.K_a:
                yar.move_left()
            if event.key == pygame.K_w:
                yar.move_up()    
            if event.key == pygame.K_x:
                yar.move_down() 
        if event.type == pygame.JOYBUTTONDOWN:
            print("Fire...")
    if joystick != 0:
        x_movement = joystick.get_axis(0)
        y_movement = joystick.get_axis(1)
        if x_movement < -0.01:
            yar.move_left()
        if x_movement > 0.01:
            yar.move_right()
        if y_movement < -0.01:
            yar.move_up()
        if y_movement > 0.01:
            yar.move_down()
    screen.fill((0,0,0))
    qotile_shield.draw_shield()
    screen.blit(qotile_shield.get_shield(), (264,qotile_shield.get_shield_screen_y()) )
    neutralzone.draw_zone()
    screen.blit(neutralzone.get_neutral_zone(), (170,0))
    qotile.set_qotile_y_position(qotile_shield.get_shield_center_coordinate())
    qotile_animation.update()
    qotile_animation.draw(screen)
    pygame.display.flip()
    yar_animation.update()
    yar_animation.draw(screen)
    pygame.display.update()
    clock.tick(fps)
    

