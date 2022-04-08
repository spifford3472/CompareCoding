import pygame
from random import seed
from random import randint
from Yar import Yar
from Shield import Shield

class Qotile(pygame.sprite.Sprite):
    """
    Qotile Contains the code for the actor Qotile and the Swirl

    :param pygame: the Sprite class from pygame.sprite
    :type pygame: Sprite
    """    
    def __init__(self):
        """
        __init__ Constructs the necessary objects for the Qotile character
        """            
        super(Qotile, self).__init__()
        self._images=[]                             # a list to contain the animation images (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Qotile.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Swirl1.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Swirl2.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Swirl3.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Swirl4.png')) # (PRIVATE)
        self._images.append(pygame.image.load('Python/images/Swirl5.png')) # (PRIVATE)
        self._index = 0                             # Contains the index of the image to display on the screen (PRIVATE)
        self.image = self._images[self._index]      # Contains the actual image to display (PUBLIC)
        self.screen_x = 274                         # Current screen x-coordinate for Qotile/Swirl (PUBLIC)
        self.screen_y = 110                         # Current screen y-coordinate for Qotile/Swirl (PUBLIC)
        self._qotile_x_min = 9                      # Min X-Coordinate when Swirl fires across the screen (PRIVATE)
        self._qotile_x_max = 274                    # The default location for Qotile and starting location for Swirl (PRIVATE)
        self._qotile_y_min = 0                      # The min y-coordinate for Swirl (PRIVATE)
        self._qotile_y_max = 180                    # The max y-coordinate for Swirl (PRIVATE)
        self._qotile_width = 16                     # The width of the Qotile/Swirl sprite (PRIVATE)
        self._qotile_height = 18                    # The height of the Qotile/Swirl sprite (PRIVATE)
        self._swirl_active = False                  # Flag to indicate if the Swirl character is active (PRIVATE)
        self._swirl_wait_cycles = randint(100, 600) # Number of screen updates (frames) to wait before activating the Swirl (PRIVATE)
        self._swirl_countdown = 100                 # Number of screen updates to keep Swirl behind the shield before launching (PRIVATE)
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._qotile_width, self._qotile_height) # Sprite collision rectangle (PUBLIC)

    def swirl_fire(self, yar:Yar):
        """
        swirl_fire Controls the Swirl action on the screen (PUBLIC)

        :param yar: The Yar class representing the player
        :type yar: Yar
        """  
        if self._swirl_active != True: return  # Check if Swirl is active, if not then skip
        if self._swirl_countdown != 0:      # Check if the Swirl launch count down has reached zero
            self._swirl_countdown -= 1
        else:                               # Countdown has reached or is already at zero
            # Calculate simple trajectory toward Yar by only moving the y-coordinate towards Yar
            if yar.screen_y < self.screen_y:
                self.screen_y -= 3
            else:
                self.screen_y += 3
            # Probably not needed, but ensures the Swirl stays on the visible screen
            if self.screen_y < 0:
                self.screen_y=0
            if self.screen_y>200:
                self.screen_y=200
        # The Swirl x-coordinate moves at a set speed
        self.screen_x -= 10
        # If Swirl has reached the far end of the screen then reset the Swirl back into Qotile 
        # and reset Qotile's standard position in the shield
        if self.screen_x <= 10:
            self.screen_x = self._qotile_x_max
            self._swirl_active=False
            # Set the next launch countdown to a random number of screen updates (between 50 and 200)
            self._swirl_countdown = randint(50, 200)  
            # Set the amount of time before the Swirl appears again  
            self._get_next_swirl_apperance() 

    def _get_next_swirl_apperance(self):
        """
        get_next_swirl_apperance Sets the number of pygame clock cycles to wait before transforming to the swirl (PRIVATE)
        """    
        self._swirl_wait_cycles = randint(100, 600) # Wait between 100 and 600 screen updates
    
    def update(self):
        """
        update Rotates the current animation image, and places the correct Qotile or Swirl image on the screen (PUBLIC)
        """  
        # If the Swirl is active, ensure the animation is active       
        if self._swirl_active == True:
            self._index += 1
            if self._index >= len(self._images):
                self._index = 1
        else: # Qotile is active and no animation is needed
            self._index = 0
            if self._swirl_wait_cycles == 0:
                self._swirl_active=True
            else:
                self._swirl_wait_cycles -= 1
        self.image = self._images[self._index]          # Set the current image to display
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._qotile_width, self._qotile_height)
    
    def set_qotile_y_position(self,shield: Shield,yar: Yar):
        """
        set_qotile_y_position Sets Qotile's position on the screen, when acting as Qotile (PUBLIC)

        :param shield: The Shield class representing the shield
        :type shield: Shield
        :param yar: The Yar class representing the player
        :type yar: Yar
        """
        # If Qotile is active set the y-coordinate from the main game loop (match the center of the shield)
        if self._swirl_active==False:     
            self.screen_y = shield.get_shield_center_coordinate()
        else: # Swirl is active so keep in center of shield till countdown reaches zero
            if self._swirl_countdown==0:
                self.swirl_fire(yar)
            else:
                self.screen_y = shield.get_shield_center_coordinate()
                self._swirl_countdown -= 1