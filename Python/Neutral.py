import pygame
import itertools
from random import seed
from random import randint

class NeutralZone:
    """
     Contains the code for the neutral zone
    """       
    def __init__(self):
        """
        __init__ Contructs all the necessary attributes for Neutral Zone object.
        """        
        self._xcoordinates = [140,148,156,164,172]      # Screen coordinates for each column of the Neutral Zone (PRIVATE)
        self._xsections = len(self._xcoordinates)       # The number of Neutral Zone columns (PRIVATE)
        self._ysections = 50                            # The number of rows for each column of the Neutral Zone (PRIVATE)
        self._yheight = 4                               # The height of each Neutral Zone rectangle (PRIVATE)
        self.nz_surface = pygame.Surface((40,200))
        seed(1)                                         # Seed the random number generator

    def _random_color(self):
        """
        _random_color Creates three random colors (PRIVATE)

        :return: three integers to use for RGB values
        :rtype: int
        """        
        # Generate numbers for a RGB color
        _color_rgb1 = randint(0, 255)                   # Red color value 
        _color_rgb2 = randint(0, 255)                   # Green color value
        _color_rgb3 = randint(0, 255)                   # Blue color value
        return _color_rgb1, _color_rgb2, _color_rgb3

    def get_neutral_zone_x_coordinates(self):
        """
        get_neutral_zone_x_coordinates Returns the min and max x-coordinates of the neutral zone (PUBLIC)

        :return: min and max x-coordinate values
        :rtype: int, int
        """        
        # Actual x-coordinates are offset to account for Yar processing as a single point
        # Offset accounts for the visual screen representation
        min_x = self._xcoordinates[0]+6                     
        max_x = self._xcoordinates[self._xsections-1]+14
        return min_x, max_x

    def draw_zone(self):
        """
        draw_zone Draws the Neutral zone onto the surface object (PUBLIC)
        """  
        # Draw rectangles for each row, column in the Neutral Zone and set a random color to it
        # Used itertools here to eliminate a nested for loop ( for x .... for y... do x,y)
        # NOTE: _random_color call is expensive (no impact here), but it would probably
        #       make sense to load an object with random colors once during game initialization
        #       then just offset into object to assign the color for faster performance if needed
        for y_coor, x_coor in itertools.product(range(self._ysections), range(self._xsections)):
            pygame.draw.rect(self.nz_surface, self._random_color(),(x_coor*8,y_coor*8,7,4))
    
    def get_neutral_zone(self):
        """
        get_neutral_zone Returns the surface object containin the shield (PUBLIC)

        :return: Surface object of the neutral zone
        :rtype: Surface
        """        
        return self.nz_surface