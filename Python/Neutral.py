import pygame;
from random import seed;
from random import randint

class NeutralZone:
    def __init__(self):
        """
        Contructs all the necessary attributes for Neutral Zone object.
        """
        self._xcoordinates = [140,148,156,164,172]
        self._xsections = 5
        self._ysections = 50
        self._yheight = 4
        self.nz_surface = pygame.Surface((40,200))
        seed(1)

    def _random_color(self):
        _color_rgb1 = randint(0, 255)
        _color_rgb2 = randint(0, 255)
        _color_rgb3 = randint(0, 255)
        return _color_rgb1, _color_rgb2, _color_rgb3


    def draw_zone(self):
        """
        Draws the Neutral zone onto the surface object
        """
        for y in range(self._ysections):
            for x in range(self._xsections):
                pygame.draw.rect(self.nz_surface, self._random_color(),(x*8,y*8,7,4))
    
    def get_neutral_zone(self):
        """
        Returns the surface object containin the shield
        """
        return self.nz_surface