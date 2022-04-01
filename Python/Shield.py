import pygame;

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

    
    Methods
    -------
    draw_shield(surface):
        Draws the current shield location to the screen

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
        self.shield_surface = pygame.Surface((56,200))

    def draw_shield(self):
        for y in range(len(self.shield_layout)):
            for x in range(len(self.shield_layout[0])):
                point_a = (((x*self.shield_block_size_x)+7),(y*self.shield_block_size_y))
                point_b = ((x*self.shield_block_size_x),((y*self.shield_block_size_y)+7))
                point_c = (((x*self.shield_block_size_x)+7),((y*self.shield_block_size_y)+7))
                point_d = ((x*self.shield_block_size_x),(y*self.shield_block_size_y))
                if self.shield_layout[y][x]==1:
                    pygame.draw.polygon(self.shield_surface, (0,0,255), (point_a,point_c,point_b))
                if self.shield_layout[y][x]==2:
                    pygame.draw.rect(self.shield_surface, (0,0,255), (x*self.shield_block_size_x,y*self.shield_block_size_y,self.shield_block_size_x,self.shield_block_size_y))
                if self.shield_layout[y][x]==3:
                    pygame.draw.polygon(self.shield_surface, (0,0,255), (point_d,point_a,point_b))
                if self.shield_layout[y][x]==4:
                    pygame.draw.polygon(self.shield_surface, (0,0,255), (point_d,point_a,point_c))
                if self.shield_layout[y][x]==5:
                    pygame.draw.polygon(self.shield_surface, (0,0,255), (point_d,point_c,point_b))                    
    def get_shield(self):
        return self.shield_surface


    
