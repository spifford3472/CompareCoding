import pygame

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
        self.image = self._images[self._index]
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._qotile_width, self._qotile_height)
    
    def set_qotile_y_position(self,y):
        """
        set_qotile_y_position Sets Qotile's position on the screen, when acting as Qotile

        :param y: The y-coordinate of the screen to place Qotile at
        :type y: int
        """        
        self.screen_y = y