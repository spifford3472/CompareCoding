import pygame
from random import seed
from random import randint


class Qotile(pygame.sprite.Sprite):
    """
    Qotile Contains the code for the actor Qotile and the Swirl

    :param pygame: the Sprite class from pygame.sprite
    :type pygame: Sprite
    """    
    def __init__(self):
        """
        __init__ Constructs the necessary objects for the Qotile character
        """            
        super(Qotile, self).__init__()
        self._images=[]
        self._images.append(pygame.image.load('Python/images/Qotile.png'))
        self._images.append(pygame.image.load('Python/images/Swirl1.png'))
        self._images.append(pygame.image.load('Python/images/Swirl2.png'))
        self._images.append(pygame.image.load('Python/images/Swirl3.png'))
        self._images.append(pygame.image.load('Python/images/Swirl4.png'))
        self._images.append(pygame.image.load('Python/images/Swirl5.png'))
        self._index = 0
        self.image = self._images[self._index]
        self.screen_x = 274
        self.screen_y = 110
        self._qotile_x_min = 9
        self._qotile_x_max = 274
        self._qotile_y_min = 0
        self._qotile_y_max = 180
        self._qotile_width = 16
        self._qotile_height = 18
        self._swirl_active = False
        self._swirl_wait_cycles = randint(100, 600)
        self._swirl_countdown = 100
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._qotile_width, self._qotile_height)

    def swirl_fire(self, yar_x:int, yar_y:int):
        if self._swirl_active==True:
            if self._swirl_countdown != 0:
                self._swirl_countdown -= 1
            else:
                # Simple trajectory
                if yar_y < self.screen_y:
                    self.screen_y -= 3
                else:
                    self.screen_y += 3
                if self.screen_y < 0:
                    self.screen_y=0
                if self.screen_y>200:
                    self.screen_y=200
            self.screen_x -= 10
            if self.screen_x <= 10:
                self.screen_x = self._qotile_x_max
                self._swirl_active=False
                self._swirl_countdown = randint(50, 200)
                self.get_next_swirl_apperance()

    def get_next_swirl_apperance(self):
        """
        get_next_swirl_apperance Sets the number of pygame clock cycles to wait before transforming to the swirl
        """    
        self._swirl_wait_cycles = randint(100, 600)
    
    def update(self):
        """
        update Rotates the current animation image, and places the correct Qotile or Swirl image on the screen
        """         
        if self._swirl_active == True:
            self._index += 1
            if self._index >= len(self._images):
                self._index = 1
        else:
            self._index = 0
            if self._swirl_wait_cycles == 0:
                self._swirl_active=True
            else:
                self._swirl_wait_cycles -= 1
        self.image = self._images[self._index]
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._qotile_width, self._qotile_height)
    
    def set_qotile_y_position(self,y: int,yar_x: int,yar_y: int):
        """
        set_qotile_y_position Sets Qotile's position on the screen, when acting as Qotile

        :param y: The y-coordinate of the screen to place Qotile at
        :type y: int
        """   
        if self._swirl_active==False:     
            self.screen_y = y
        else:
            if self._swirl_countdown==0:
                self.swirl_fire(yar_x, yar_y)
            else:
                self.screen_y = y
                self._swirl_countdown -= 1