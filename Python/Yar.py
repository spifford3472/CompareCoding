import pygame

class Yar(pygame.sprite.Sprite):
    """
    A class to represent the players character Yar
    
    Attributes
    ----------
    image : pygame.image
        Denotes the current displayable image for the Yar character
    screen_x : int
        Denotes the characters current x position on the screen
    screen_y : int
        Denotes the characters current y position on the screen
 
    Methods
    -------
    update():
        Creates the next animation frame and places it on the screen

    move_right():
        Moves the Yar character coordinates to the right
    
    move_left():
        Moves the Yar character coordinates to the left

    move_up():
        Moves the Yar character coordinates up

    move_down():
        Moves the Yar character coordinates down

    set_start_position(x,y)
        Sets the initial screen coordinate for the Yar
    """
    def __init__(self):
        """
        Contructs all the necessary attributes for the Yar.
        """        
        super(Yar, self).__init__()
        self._images=[]
        self._images.append(pygame.image.load('Python/images/Yar1.png'))
        self._images.append(pygame.image.load('Python/images/Yar2.png'))
        self._images.append(pygame.image.load('Python/images/Yar3.png'))
        self._images.append(pygame.image.load('Python/images/Yar4.png'))
        self._images.append(pygame.image.load('Python/images/Yar5.png'))
        self._images.append(pygame.image.load('Python/images/Yar6.png'))
        self._images.append(pygame.image.load('Python/images/Yar5.png'))
        self._images.append(pygame.image.load('Python/images/Yar4.png'))
        self._images.append(pygame.image.load('Python/images/Yar3.png'))
        self._images.append(pygame.image.load('Python/images/Yar2.png'))
        self._index = 0
        self.image = self._images[self._index]
        self.screen_x = 120
        self.screen_y = 110
        self._yar_speed = 6
        self._yar_x_min = 9
        self._yar_x_max = 274
        self._yar_y_min = 0
        self._yar_y_max = 180
        self._yar_width = 16
        self._yar_height = 18
    
    def update(self):
        """
        Rotates the current animation image, and places the Yar on the screen.
        """        
        self._index += 1
        if self._index >= len(self._images):
            self._index = 0
        self.image = self._images[self._index]
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._yar_width, self._yar_height)

    def move_right(self):
        """
        Moves the Yar's screen x location to the right
        """        
        if self.screen_x >= self._yar_x_max:
            self.screen_x = self._yar_x_max
        else:
            self.screen_x += self._yar_speed

    def move_left(self):
        """
        Moves the Yar's screen x location to the left
        """         
        if self.screen_x <= self._yar_x_min:
            self.screen_x = self._yar_x_min
        else:
            self.screen_x -= self._yar_speed

    def move_up(self):
        """
        Moves the Yar's screen y location to the up
        """         
        if self.screen_y <= self._yar_y_min:
            self.screen_y = self._yar_y_min
        else:
            self.screen_y -= self._yar_speed

    def move_down(self):
        """
        Moves the Yar's screen y location down
        """         
        if self.screen_y >= self._yar_y_max:
            self.screen_y = self._yar_y_max
        else:
            self.screen_y += self._yar_speed    

    def set_start_position(self,x,y):
        """
        Function set set the position of Yar on the screen
        """ 
        if x >= self._yar_x_max or x <= self._yar_x_min:
            self.screen_x = 120
        else:
            self.screen_x = x
        if y >= self._yar_y_max or y <= self._yar_y_min:
            self.screen_y = 110
        else:
            self.screen_y = y     
        