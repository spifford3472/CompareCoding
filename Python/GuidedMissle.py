import pygame

class GuidedMissle(pygame.sprite.Sprite):
    """
    GuidedMissle Contains the code for the Guided Missle object

    :param pygame: the Sprite class from pygame.sprite
    :type pygame: Sprite
    """
    def __init__(self):
        """
        __init__ Constructs the necessary objects for the guided missle
        """            
        super(GuidedMissle, self).__init__()
        self.image = pygame.image.load('Python/images/missle.png')  
        self.screen_x = 274                 # Screen X-Coordinate for the missile
        self.screen_y = 9                   # Screen Y-Coordinate for the missile
        self._x_max = 288                   # Max X-Coordinate for the screen
        self._x_min = 10                    # Min X-Coordinate for the screen
        self._y_max = 195                   # Max Y-Coordinate for the screen
        self._y_min = 5                     # Min Y-Coordinate for the screen
        self._missle_width = 9              # Pixel width of the missile sprite 
        self._missle_height = 4             # Pixel height of the missile sprite
        self._missle_speed = 1              # Number of pixels to move the missile each update
        self._yar_x = 0                     # The x-coordinate of Yar
        self._yar_y = 0                     # The y-coordinate of Yar
        self._yar_neutral_zone = False      # Yar's current neutral zone status
        self._x_direction = 0               # Current direction the missile is moving (x-coordinate)
        self._y_direction = 0               # Current direction the missile is moving (y-coordinate)
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._missle_width, self._missle_height)

    def set_yars_position(self, yar_x:int, yar_y:int, neutralzone:bool):
        """
        set_yars_position Sets Yar's position for the Guided Missle to reference (Public)

        :param yar_x: Yar's x-coordinate on the screen
        :type yar_x: int
        :param yar_y: Yar's y-coordinate on the screen
        :type yar_y: int
        :param neutralzone: A flag to indicate whether Yar is in the neutral zone
        :type neutralzone: bool
        """        
        self._yar_x = yar_x
        self._yar_y = yar_y
        self._yar_neutral_zone = neutralzone

    def update(self):
        """
        update Handles the movement of the guided missle (Public)
        """        
        self._hunt_yar()
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._missle_width, self._missle_height)

    def _hunt_yar(self):
        """
        _hunt_yar Calculates what direction to move the guided missle to chase Yar (Private)
        """        
        if self._yar_neutral_zone == False:                 # Only chase if Yar is not in the Neutral Zone,
            if self.screen_x > self._yar_x:                 # otherwise use the last direction the missile was traveling
                self._x_direction = -self._missle_speed
            if self.screen_x < self._yar_x:
                self._x_direction = self._missle_speed
            if self.screen_y > self._yar_y:
                self._y_direction = -self._missle_speed
            if self.screen_y < self._yar_y:
                self._y_direction = self._missle_speed
        self.screen_x += self._x_direction
        self.screen_y += self._y_direction
        self._check_boundry()                               # Need to ensure the missile stays on the screen
    
    def _check_boundry(self):
        """
        _check_boundry Checks that the guided Missle stays in the boundry and reverses direction (Private)
        """        
        # Check each boundry and if the boundry is surpassed, reset the location to the boundry
        # then change the direction of the missile as Yar could be hiding in the Neutral Zone
        if self.screen_x > self._x_max:         
            self.screen_x = self._x_max
            self._x_direction *= -1
        if self.screen_x < self._x_min:
            self.screen_x = self._x_min
            self._x_direction *= -1
        if self.screen_y > self._y_max:
            self.screen_y = self._y_max
            self._y_direction *= -1
        if self.screen_y < self._y_min:
            self.screen_y = self._y_min
            self._x_direction *= -1
