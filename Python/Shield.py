import pygame;
import enum;

class Shield:
    """
    A class to represent Qotile's shield
    ...
    Attributes
    ----------
    shield_layout : [list[list]]
            representation of the shield objects
    shield_block_size_x : int
            denotes the horizontal size of a text character from the original Commodore 64 game
    shield_block_size_y : int
            denotes the verticle size of a text character from the original Commodore 64 game
    shield_screen_y_location : int
            denotes the y location on the screen where the shield should be placed
    shield_screen_max_y : int
            denotes the max y coordinate where the shield should start to draw
    shield_direction : int
            denotes which direction the shield should be moving
    shield_surface : pygame.Surface
            Contains the surface object from pygame which the shield is drawn on
    blue = tuple(int,int,int)
            denotes the RGB value of the color Blue
    
    Methods
    -------
    draw_shield(surface):
        Draws the current shield location to the screen

    get_shield():
        Returns the surface object containing the shield

    get_shield_screen_y():
        Returns an integer of which y coordinate to start drawing the shield at
    """
    def __init__(self):
        """
        Contructs all the necessary attributes for Qotile's shield object.
        """
        self.shield_layout = [[0,0,0,0,1,2,3],
                             [0,0,1,2,2,3,0],
                             [0,1,2,2,3,0,0],
                             [0,2,2,3,0,0,0],
                             [1,2,3,0,0,0,0],
                             [2,2,0,0,0,0,0],
                             [4,2,5,0,0,0,0],
                             [0,2,2,5,0,0,0],
                             [0,4,2,2,5,0,0],
                             [0,0,4,2,2,5,0],
                             [0,0,0,0,4,2,5]]
        self.shield_block_size_x = 8
        self.shield_block_size_y = 8
        self.shield_screen_y_location = 0
        self.shield_screen_max_y = 112
        self.shield_direction = 1
        self.shield_surface = pygame.Surface((56,200))
        self.blue = (0,0,255)

    def draw_shield(self):
        """
        Moves the shield, and draws the shield graphic onto the surface object
        """
        self.__move_shield()
        for y in range(len(self.shield_layout)):
            for x in range(len(self.shield_layout[0])):
                point_a = (((x*self.shield_block_size_x)+7),(y*self.shield_block_size_y))
                point_b = ((x*self.shield_block_size_x),((y*self.shield_block_size_y)+7))
                point_c = (((x*self.shield_block_size_x)+7),((y*self.shield_block_size_y)+7))
                point_d = ((x*self.shield_block_size_x),(y*self.shield_block_size_y))
                if self.shield_layout[y][x]==1:
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_a,point_c,point_b))
                if self.shield_layout[y][x]==2:
                    pygame.draw.rect(self.shield_surface, self.blue, (x*self.shield_block_size_x,y*self.shield_block_size_y,self.shield_block_size_x,self.shield_block_size_y))
                if self.shield_layout[y][x]==3:
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_a,point_b))
                if self.shield_layout[y][x]==4:
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_a,point_c))
                if self.shield_layout[y][x]==5:
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_c,point_b))     

    def get_shield(self):
        """
        Returns the surface object containin the shield
        """
        return self.shield_surface
    
    def get_shield_screen_y(self):
        """
        Returns an integer that denotes the y-coordinate to blit the shield to
        """
        return self.shield_screen_y_location
    
    def __move_shield(self):
        """
        Moves the shield and corrects the direction of movement when screen limits are reached
        """
        if self.shield_screen_y_location<=0:
            self.shield_direction = 1
        if self.shield_screen_y_location>=self.shield_screen_max_y:
            self.shield_direction = -1
        self.shield_screen_y_location = self.shield_screen_y_location + (8 * self.shield_direction)



    
