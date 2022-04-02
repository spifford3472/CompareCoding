import pygame

class Qotile(pygame.sprite.Sprite):
    def __init__(self):
        """
        Contructs all the necessary attributes for Qotile
        """        
        super(Yar, self).__init__()
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

    def qotile_move(self,y):
        self.screen_y=y
