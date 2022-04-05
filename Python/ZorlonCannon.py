import pygame

class ZorlonCannon(pygame.sprite.Sprite):

    def __init__(self):
        """
        __init__ Constructs the necessary objects for the Qotile character
        """            
        super(ZorlonCannon, self).__init__()
        self.image = pygame.image.load('Python/images/cannon.png')
        self.screen_x = 1
        self.screen_y = 110
        self._x_max = 288
        self._x_begin = 1
        self._cannon_width = 9
        self._cannon_height = 8
        self._currently_fired = False
        self._cannon_speed = 20
        self._slow_cannon_speed = 8
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._cannon_width, self._cannon_height)

    def update(self):
        if self._currently_fired==True:
            self.move_right()
        self.rect = pygame.Rect(self.screen_x, self.screen_y, self._cannon_width, self._cannon_height)

    def set_cannon_y_position(self,y):
        if self._currently_fired==False:
            self.screen_y = y

    def move_right(self):
        if self._currently_fired==True:
            if self.screen_x < 270:
                self.screen_x += self._cannon_speed
            else:
                self.screen_x += self._slow_cannon_speed
                if self.screen_x >= self._x_max:
                    self.screen_x = self._x_begin
                    self._currently_fired = False

    def fire_cannon(self):
        if self._currently_fired==False:
            self._currently_fired=True

    def cannon_hit_shield(self):
        print("x={} y={}".format(self.screen_x, self.screen_y))
        self.screen_x = self._x_begin
        self._currently_fired=False