import pygame
from Yar import Yar

class ZorlonCannon(pygame.sprite.Sprite):
    """
    ZorlonCannon Contains the code for the Zorlon Cannon object

    :param pygame: the Sprite class from pygame.sprite
    :type pygame: Sprite
    """
    def __init__(self):
        """
        __init__ Constructs the necessary objects for the Qotile character
        """            
        super(ZorlonCannon, self).__init__()
        self.image = pygame.image.load('Python/images/cannon.png') # (PUBLIC)
        self.screen_x = 1                       # x-coordinate on screen for the Zorlon Cannon (PUBLIC)
        self.screen_y = 110                     # y-coordinate on screen for the Zorlon Cannon (PUBLIC)
        self._x_max = 288                       # max x-coordinate the cannon can travel across the screen (PRIVATE)
        self._x_begin = 1                       # x-coordinate where the cannon should start from (PRIVATE)
        self._cannon_width = 9                  # width of the cannon sprite (PRIVATE)
        self._cannon_height = 8                 # height of the cannon sprite (PRIVATE)
        self._currently_fired = False           # flag to indicate if the cannon was shot and being tracked (PRIVATE)
        self._cannon_speed = 20                 # number of pixels the cannon shot should travel each update (PRIVATE)
        self._slow_cannon_speed = 4             # number of pixels the cannon shot should travel once it nears the shield (avoid overshooting) (PRIVATE)
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._cannon_width, self._cannon_height) # Sprite collision rectangle (PUBLIC)

    def update(self,yar:Yar):
        """
        update Updates the cannon on the screen (PUBLIC)

        :param yar: The player object Yar
        :type yar: Yar
        """     
        # If cannon was shot move it to the right
        if self._currently_fired==True:
            self.move_right()
        else:
            self.screen_y = yar.screen_y
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._cannon_width, self._cannon_height)


    def move_right(self):
        """
        move_right Move the cannon to the right if it was fired (PUBLIC)
        """        
        # Will only move the cannon to the right if the cannon was shot
        if self._currently_fired!=True: return
        if self.screen_x < 270:
            self.screen_x += self._cannon_speed
        else:
            self.screen_x += self._slow_cannon_speed
            if self.screen_x >= self._x_max:
                self.screen_x = self._x_begin
                self._currently_fired = False

    def fire_cannon(self):
        """
        fire_cannon Alert the class that the cannon was fired (PUBLIC)
        """        
        if self._currently_fired==False:
            self._currently_fired=True

    def cannon_hit_shield(self):
        """
        cannon_hit_shield Reset the cannon to the start position if the shield was hit (PUBLIC)
        """        
        self.screen_x = self._x_begin
        self._currently_fired=False


