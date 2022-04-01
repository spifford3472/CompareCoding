import sys, pygame
from Shield import Shield
from Yar import Yar
import time

pygame.init()

fps = 10 # frames per second
size = width, height = 320, 240
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


# Enter the repeating game loop
while 1:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
    screen.fill((0,0,0))
    qotile_shield.draw_shield()
    screen.blit(qotile_shield.get_shield(), (264,qotile_shield.get_shield_screen_y()) )
    pygame.display.flip()
    yar_animation.update()
    yar_animation.draw(screen)
    pygame.display.update()
    clock.tick(fps)
    #time.sleep(0.1)