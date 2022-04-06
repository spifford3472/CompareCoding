import pygame;
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
        self._xcoordinates = [140,148,156,164,172]      # Screen coordinates for each column of the Neutral Zone
        self._xsections = len(self._xcoordinates)       # The number of Neutral Zone columns
        self._ysections = 50                            # The number of rows for each column of the Neutral Zone
        self._yheight = 4                               # The height of each Neutral Zone rectangle
        self.nz_surface = pygame.Surface((40,200))
        seed(1)                                         # Seed the random number generator

    def _random_color(self):
        """
        _random_color Creates three random colors 

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
        get_neutral_zone_x_coordinates Returns the min and max x-coordinates of the neutral zone

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
        draw_zone Draws the Neutral zone onto the surface object
        """  
        # Draw rectangles for each row, column in the Neutral Zone and set a random color to it
        for y in range(self._ysections):
            for x in range(self._xsections):
                pygame.draw.rect(self.nz_surface, self._random_color(),(x*8,y*8,7,4))
    
    def get_neutral_zone(self):
        """
        get_neutral_zone Returns the surface object containin the shield

        :return: Surface object of the neutral zone
        :rtype: Surface
        """        
        return self.nz_surface