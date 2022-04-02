import pygame;
from CustomMath import CustomMath
import enum;


class Shield:
    """
     Qotile's shield class
    """

    def __init__(self):
        """
        __init__ Constructs the needed information for Qotile's shield
        """   
        # Contains the representation of Qotile's shield
        #   0 - blank space
        #   2 - square block
        #   <other> - different triangles 
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
        self.shield_block_size_x = 8                        # Size of the standard shield character in the x-axis
        self.shield_block_size_y = 8                        # Size of the standard shield character in the y-axis
        self.shield_screen_y_location = 0                   # Current shield top y-coordinate on the screen
        self.shield_screen_max_y = 112                      # The max value the top of the shield component can have
        self.shield_direction = 1                           # Direction of shield movement (1=Down / -1=Up)
        self.shield_surface = pygame.Surface((56,200))      # The surface object where the shield is rendered
        self.blue = (0,0,255)                               # The color Blue for the shield
        self.shield_screen_offset_x = 264                   # The screen x-coordinate to start each shield line at
        self._empty = pygame.Color(0, 0, 0, 0)              # Denotes a blank/transparent color for clearing the surfacee
        self._shield_part_desc = {}                         # Dictionary item to hold specific objects for each shield block
        self._shield_parts = []                             # A tuple to hold all the shield objects

    
    def draw_shield(self):
        """
        draw_shield Moves the shield, and draws the shield graphic onto the surface
        """        
        # Clear the contents of the surface before redrawing, and move the shield
        self.shield_surface.fill(self._empty)  
        self._move_shield()
        # Process the shield for each shield block
        self._shield_parts.clear()
        for y in range(len(self.shield_layout)):
            for x in range(len(self.shield_layout[0])):
                # Calculate the corners of each 8x8 shield block
                point_ax = ((x*self.shield_block_size_x)+7)+self.shield_screen_offset_x
                point_ay = (y*self.shield_block_size_y)+self.shield_screen_y_location
                vert_a = [point_ax,point_ay]
                point_a = (((x*self.shield_block_size_x)+7),(y*self.shield_block_size_y))
                #----
                point_bx = (x*self.shield_block_size_x)+self.shield_screen_offset_x
                point_by = ((y*self.shield_block_size_y)+7)+self.shield_screen_y_location
                vert_b = [point_bx,point_by]
                point_b = ((x*self.shield_block_size_x),((y*self.shield_block_size_y)+7))
                #---
                point_cx = ((x*self.shield_block_size_x)+7)+self.shield_screen_offset_x
                point_cy = ((y*self.shield_block_size_y)+7)+self.shield_screen_y_location
                vert_c = [point_cx,point_cy]
                point_c = (((x*self.shield_block_size_x)+7),((y*self.shield_block_size_y)+7))
                #-------
                point_dx = (x*self.shield_block_size_x)+self.shield_screen_offset_x
                point_dy = (y*self.shield_block_size_y)+self.shield_screen_y_location
                vert_d = [point_dx, point_dy]
                point_d = ((x*self.shield_block_size_x),(y*self.shield_block_size_y))
                #-----
                _rectname = str(x)+"|"+str(y)
                # Create right triangle with 90 degree angle in lower right
                if self.shield_layout[y][x]==1:
                    # Draw the current block onto the surface
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_a,point_c,point_b))
                    # Create a CustomMath object to calculate collisions with the Yar
                    polygon_calc = CustomMath([vert_a,vert_c,vert_b])
                    # Create the shield component and store it
                    self._shield_part_desc = {'rectname': _rectname, 'array_x':x, 'array_y':y, 'collision_check':polygon_calc, 'remove':False}
                    self._shield_parts.append(self._shield_part_desc)
                # Create a full 8x8 block
                if self.shield_layout[y][x]==2:
                    # Draw the current block onto the surface
                    pygame.draw.rect(self.shield_surface, self.blue, (x*self.shield_block_size_x,y*self.shield_block_size_y,self.shield_block_size_x,self.shield_block_size_y))
                    # Create a CustomMath object to calculate collisions with the Yar
                    polygon_calc = CustomMath([vert_a,vert_c, vert_b, vert_d])
                    # Create the shield component and store it
                    self._shield_part_desc = {'rectname': _rectname, 'array_x':x, 'array_y':y, 'collision_check':polygon_calc, 'remove':False}
                    self._shield_parts.append(self._shield_part_desc)
                # Create a right triangle with the 90 degree corner in upper left
                if self.shield_layout[y][x]==3:
                    # Draw the current block onto the surface
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_a,point_b))
                    # Create a CustomMath object to calculate collisions with the Yar
                    polygon_calc = CustomMath([vert_d, vert_a, vert_b])
                    # Create the shield component and store it
                    self._shield_part_desc = {'rectname': _rectname, 'array_x':x, 'array_y':y, 'collision_check':polygon_calc, 'remove':False}                    
                    self._shield_parts.append(self._shield_part_desc)
                # Create a right triangle with the 90 degree corner in the upper right
                if self.shield_layout[y][x]==4:
                    # Draw the current block onto the surface
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_a,point_c))
                    # Create a CustomMath object to calculate collisions with the Yar
                    polygon_calc = CustomMath([vert_d,vert_a,vert_c])
                    # Create the shield component and store it
                    self._shield_part_desc = {'rectname': _rectname, 'array_x':x, 'array_y':y, 'collision_check':polygon_calc, 'remove':False}
                    self._shield_parts.append(self._shield_part_desc)
                # Create a right triangle with the 90 degree corner in the lower left
                if self.shield_layout[y][x]==5:
                    # Draw the current block onto the surface
                    pygame.draw.polygon(self.shield_surface, self.blue, (point_d,point_c,point_b))  
                    # Create a CustomMath object to calculate collisions with the Yar 
                    polygon_calc = CustomMath([vert_d,vert_c, vert_b]) 
                    # Create the shield component and store it
                    self._shield_part_desc = {'rectname': _rectname, 'array_x':x, 'array_y':y, 'collision_check':polygon_calc, 'remove':False}
                    self._shield_parts.append(self._shield_part_desc)

    def get_shield(self):
        """
        get_shield Returns the shield's surface object 

        :return: pygame surface object
        :rtype: Surface
        """        
        return self.shield_surface
    
    def get_shield_screen_y(self):
        """
        get_shield_screen_y Returns an integer that denotes the y-coordinate to blit the shield to

        :return: screen y coordinate of the top of the shield
        :rtype: int
        """        
        return self.shield_screen_y_location
    
    def _move_shield(self):
        """
        _move_shield Moves the shield and corrects the direction of movement when screen limits are reached
        """        
        if self.shield_screen_y_location<=0:
            self.shield_direction = 1
        if self.shield_screen_y_location>=self.shield_screen_max_y:
            self.shield_direction = -1
        self.shield_screen_y_location = self.shield_screen_y_location + (8 * self.shield_direction)

    def get_shield_center_coordinate(self):
        """
        get_shield_center_coordinate Returns the screen y-coordinate of the center of the shield

        :return: y-coordinate of the center of the shield
        :rtype: int
        """        
        return self.get_shield_screen_y()+35

    def check_shield_collision(self, object_screen_x, object_screen_y):
        """
        check_shield_collision Detects if a passed point hits the visible shield

        :param object_screen_x: a screen x-coordinate to test
        :type object_screen_x: int
        :param object_screen_y: a screen y-coordinate to test
        :type object_screen_y: int
        :return: boolean value to indicate if the point hit the shield
        :rtype: boolean
        """        
        collision_occurred = False
        # Load 3 points in to account for the height of the YAR (assumption is player has to hit shield with front of Yar)
        check_points = [(object_screen_x, object_screen_y),(object_screen_x, object_screen_y+4),(object_screen_x, object_screen_y+7)]
        # Loop through the points to check for a collision
        for point_to_check in check_points:
            for shield_part in self._shield_parts:
                if shield_part['remove']==False:
                    test_collision = shield_part['collision_check']
                    if test_collision.isInsidePolygon(point_to_check,False)==True:
                        shield_x = shield_part['array_x']
                        shield_y = shield_part['array_y']
                        # Remove the shield where the collision occurred
                        self.shield_layout[shield_y][shield_x]=0
                        shield_part['remove']=True
                        collision_occurred = True
                        break   #Stop processing and fall out of the loop
            if collision_occurred==True:
                break
        return collision_occurred





    
