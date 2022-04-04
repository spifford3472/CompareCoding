import pygame

class ZorlonCannon(pygame.sprite.Sprite):
        def __init__(self):
        """
        __init__ Constructs the necessary objects for the Qotile character
        """            
        super(Qotile, self).__init__()
        self.image = pygame.image.load('Python/images/cannon.png')
        self.screen_x = 274
        self.screen_y = 110
        