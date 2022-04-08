import pygame

class Yar(pygame.sprite.Sprite):
    """
    Yar Contains the code for the Yar actor

    :param pygame: the Sprite class from pygame.sprite
    :type pygame: Sprite
    """
    def __init__(self):
        """
        __init__ Constructs the necessary objects for the Yar character
        """        
        super(Yar, self).__init__()
        self._images=[]                                 # List to contain the animation images for Yar (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar1.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar2.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar3.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar4.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar5.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar6.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar5.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar4.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar3.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Yar2.png')) # (PRIVATE)
        self._index = 0                                 # Index to indicate which image to display to the screen (PRIVATE)
        self.image = self._images[self._index]          # Current image being displayed (PUBLIC)
        self.screen_x = 120                             # Yar's x-coordinate on the screen (PUBLIC)
        self.screen_y = 110                             # Yar's y-coordinate on the screen (PUBLIC)
        self._yar_speed = 6                             # Speed at which Yar moves on the screen (PRIVATE)
        self._yar_x_min = 12                            # The min x-coordinate which Yar can move (leave room for Zorlon cannon) (PRIVATE)
        self._yar_x_max = 274                           # The max x-coordinate which Yar can move (can't go past shield end) (PRIVATE)
        self._yar_y_min = 0                             # The min y-coordinate Yar can move to (PRIVATE)
        self._yar_y_max = 180                           # The max y-coordinate Yar can move to and remain visually on the screen (PRIVATE)
        self._yar_width = 16                            # Width of the Yar sprite (PRIVATE)
        self._yar_height = 18                           # Height of the Tar sprite (PRIVATE)
        self._neutralzone_min = 0                       # min x-coordinate of the neutral zone (Place holder here - Set later) (PRIVATE)
        self._neutralzone_max = 1                       # max x-coordinate of the neutral zone (Place holder here - Set later) (PRIVATE)
        self._inNeutralZone = False                     # Flag to indicate if in the Neutral Zone (PRIVATE)
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._yar_width, self._yar_height) # Sprite collision rectangle (PUBLIC)
    
    def update(self):
        """
        update Animates the Yar character and places on the screen (PUBLIC)
        """   
        # loops the images to create the animation   
        self._index += 1
        if self._index >= len(self._images):
            self._index = 0
        self.image = self._images[self._index]
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._yar_width, self._yar_height)

    def move_right(self):
        """
        move_right Moves the Yar character to the right (PUBLIC)
        """       
        if self.screen_x >= self._yar_x_max:
            self.screen_x = self._yar_x_max
        else:
            self.screen_x += self._yar_speed
        self._check_neutral_zone()

    def move_left(self):
        """
        move_left Moves the Yar character to the left (PUBLIC)
        """         
        if self.screen_x <= self._yar_x_min:
            self.screen_x = self._yar_x_min
        else:
            self.screen_x -= self._yar_speed
        self._check_neutral_zone()

    def move_up(self):
        """
        move_up Moves the YAR character up (PUBLIC)
        """       
        if self.screen_y <= self._yar_y_min:
            self.screen_y = self._yar_y_min
        else:
            self.screen_y -= self._yar_speed

    def move_down(self):
        """
        move_down Moves the Yar character down (PUBLIC)
        """        
        if self.screen_y >= self._yar_y_max:
            self.screen_y = self._yar_y_max
        else:
            self.screen_y += self._yar_speed    

    def set_start_position(self,x,y):
        """
        set_start_position Sets the position of the Yar character on the screen (PUBLIC)

        :param x: x-coordinate to place Yar on the screen
        :type x: int
        :param y: y-coordinate to place Yar on the screen
        :type y: int
        """
        if x >= self._yar_x_max or x <= self._yar_x_min:
            self.screen_x = 120
        else:
            self.screen_x = x
        if y >= self._yar_y_max or y <= self._yar_y_min:
            self.screen_y = 110
        else:
            self.screen_y = y     
        
    def _check_neutral_zone(self):
        """
        _check_neutral_zone Updates if YAR is in the neutral zone (PRIVATE)
        """        
        if self.screen_x >= self._neutralzone_min and self.screen_x <= self._neutralzone_max:
            self._inNeutralZone=True
        else:
            self._inNeutralZone=False

    def set_neutral_zone(self, min_x:int, max_x:int):
        """
        set_neutral_zone Set the neutral zone location (PUBLIC)

        :param min_x: The start x coordinate of the neutral zone
        :type min_x: int
        :param max_x: The end x-coordinate of the neutral zone
        :type max_x: int
        """
        self._neutralzone_min = min_x
        self._neutralzone_max = max_x


    def get_neutral_zone_flag(self):
        """
        get_neutral_zone_flag Return boolean flag True if Yar is in the neutral zone (PUBLIC)

        :return: Boolean flag of Neutral zone status
        :rtype: boolean
        """  
        return self._inNeutralZone 
           