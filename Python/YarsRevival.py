import sys                                  # Used for the exit function
import pygame                               # pygame 1.2 library used for game implementation
from Shield import Shield                   # Custom class used to represent Qotile's Shield
from Neutral import NeutralZone             # Custom class used to represent the Neutral Zone
from Yar import Yar                         # Custom class used to represent Yar
from Qotile import Qotile                   # Custom class used to represent Qotile and the Swirl
from ZorlonCannon import ZorlonCannon       # Custom class used to represent the Zorlon Cannon
from GuidedMissle import GuidedMissle       # Custom class used to represent the Guided Missle                         
from random import randint                  # Used to create random numbers for colors


fps = 15                                    # frames per second for the screen
size = width, height = 300, 200             # Size of the screen
black = (0, 0, 0)                           # RGB color for black game screen
green = (0, 255, 0)                         # RGB color for Text font                     
blue = (0, 0, 255)                          # RGB color for text background
bounce_yar=False                            # Signal to bounce Yar away from the shield after nibbling a section
bounce_yar_start = 0                        # Used to track how far to bounce Yar away from the shield


def GameOver(msg:str):
    """
     Handles displaying the game over screen and waiting for user exit
    """   
    # Create Game Over message 
    font = pygame.font.Font('freesansbold.ttf',32)
    message = "GAME OVER - " + msg
    text = font.render(message, True, green, blue)
    textRect = text.get_rect()
    textRect.center = (200,200)
    # Display the window for the Game Over message
    display_surface = pygame.display.set_mode((400,400))
    pygame.display.set_caption('Game Over')
    display_surface.fill(blue)
    display_surface.blit(text, textRect)
    # Loop till user quits
    while True:
        # Randomly change Game Over text color while we wait
        c1 = randint(1, 255)
        c2 = randint(1, 255)
        c3 = randint(1, 255)
        text = font.render(message, True, (c1, c2, c3), blue)
        display_surface.blit(text, textRect)
        # Check for a user quit event
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()
        pygame.display.update()

#=====================================================
# Initialize all imported pygame modules
#=====================================================
pygame.init()                              

#=====================================================
# Initialize the screen for game play
#=====================================================
screen = pygame.display.set_mode(size)
screen.fill(black)

#=====================================================
# Initialize the classes that will be used in the game
#=====================================================
# Create the game clock (It will delay execution based on the defined frames per second rate)
clock = pygame.time.Clock()

# Create Qotile's Shield 
qotile_shield = Shield()
qotile_shield.draw_shield()

# Create Yar (The player of the game)
yar = Yar()
yar_animation = pygame.sprite.Group(yar)

# Create the Neutral Zone
neutralzone = NeutralZone()
nz_min,nz_max=neutralzone.get_neutral_zone_x_coordinates()
yar.set_neutral_zone(nz_min,nz_max)     # Pass Neutral zone x-coordinates to Yar

# Create Qotile/Swirl
qotile = Qotile()
qotile_animation = pygame.sprite.Group(qotile)

# Create the Zorlon Cannon
cannon = ZorlonCannon()
cannon_animation = pygame.sprite.Group(cannon)

# Create the Guided Missile
missle = GuidedMissle()
missle_animation = pygame.sprite.Group(missle)

#=========================================================
#Setup the joystick, this will be the only supported input
#=========================================================
joystick1 = pygame.joystick.get_count()
if joystick1 == 0:
    print("ERROR: No joystick to configure.")
    sys.exit()
else:
    joystick = pygame.joystick.Joystick(0)  #Set the first joystick detected as the game joystick
    joystick.init()

#=========================================================
# Main Game Loop - Remains here till player wins or loses
#=========================================================
while 1:
    screen.fill((0,0,0))                        # Clear the screen

    #-----------------------------------------------------------------
    # Check if Yar nibbled some of the shield and needs to be bounced
    #-----------------------------------------------------------------
    if bounce_yar==False:
        # Yar did not nibble the shield, so let's check game events
        for event in pygame.event.get():    
            # Did user request to quit (close the window)
            if event.type == pygame.QUIT:
                sys.exit()
            # Did the user press the fire button on the joystick
            if event.type == pygame.JOYBUTTONDOWN:
                # Ensure player is not in the neutral zone before firing the Zorlon cannon
                if yar.get_neutral_zone_flag()==False:
                    cannon.fire_cannon()
        # Did the user move the joystick
        if joystick != 0:
            # Read the analog movement of the joystick
            x_movement = joystick.get_axis(0)
            y_movement = joystick.get_axis(1)
            # We account for the fact that the joystick may not be perfectly centered
            # If a tolerance is met then we process the requested movement
            # Process x-coordinate movements
            if x_movement < -0.01:
                yar.move_left()
            if x_movement > 0.01:
                yar.move_right()
            # Process y-coordinate movements
            #   Note: the Zorlon cannon stays aligned with Yar
            if y_movement < -0.01:
                yar.move_up()
                cannon.set_cannon_y_position(yar)
            if y_movement > 0.01:
                yar.move_down()
                cannon.set_cannon_y_position(yar)

        # Check Yar collision with shield
        collision=qotile_shield.check_shield_collision(yar.screen_x+23, yar.screen_y)  # fix x location of yar for shield collision
        if collision==True:
            # Positive hit on the shield so bounce Yar backwards, with no other processing
            bounce_yar=True
            bounce_yar_start=5
    # Else we need to process the bounce for Yar with no movement options from user
    else: 
        if bounce_yar_start > 0:
            yar.move_left()
            yar.move_left()
            bounce_yar_start -= 1
        else:
            bounce_yar = False  # Done with the bounce for Yar

    #-----------------------------------------------------------------
    # Check for collision events between the game objects
    #-----------------------------------------------------------------
    # Check if the Zorlon Cannon hit the Shield
    cannon_shield_collision=qotile_shield.check_cannon_collision(cannon.screen_x, cannon.screen_y)  
    if cannon_shield_collision == True:
        cannon.cannon_hit_shield()

    # Check Zorlon Cannon and Yar collision - since both sprites can use sprite collision routine
    # Yar dies if hit by own Zorlon cannon shot
    if cannon.rect.colliderect(yar.rect)==True:
        GameOver("You Lose")

    # Check Zorlon Cannon and Qotile collision
    # Yar's Zorlon Cannon shot can only hit Qotile, the Swirl is immune to the Zorlon Cannon
    if cannon.rect.colliderect(qotile.rect)==True and qotile._swirl_active==False:
        GameOver("You Win")

    # Check if the Swirl hit Yar
    if qotile.rect.colliderect(yar.rect)==True and qotile._swirl_active==True:
        GameOver("You Lose")

    # Check if the Guided Missile hit Yar
    if missle.rect.colliderect(yar.rect)==True:
        GameOver("You Lose")

    #-----------------------------------------------------------------
    # Draw and move items on the screen
    #-----------------------------------------------------------------
    # Move Qotile's shield and redraw it
    qotile_shield.draw_shield()
    screen.blit(qotile_shield.get_shield(), (qotile_shield.shield_screen_offset_x,qotile_shield.get_shield_screen_y()))

    # Redraw the Neutral Zone with new colors
    neutralzone.draw_zone()
    screen.blit(neutralzone.get_neutral_zone(), (170,0))

    # Move Qotile and check if animation or movement needed for the Swirl
    qotile.set_qotile_y_position(qotile_shield, yar)
    qotile_animation.update()
    qotile_animation.draw(screen)

    # Move and animate Yar
    yar_animation.update()
    yar_animation.draw(screen)

    # Move and update the Zorlon Cannon
    cannon.update()
    cannon_animation.draw(screen)

    # Move and update the Guided Missile
    missle.update(yar)
    missle_animation.draw(screen)

    # Redraw the screen
    pygame.display.update()

    # Wait for the next clock tick
    clock.tick(fps)
    

