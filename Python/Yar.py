import pygame

class Yar(pygame.sprite.Sprite):
    def __init__(self):
        super(Yar, self).__init__()
        self.images=[]
        self.images.append(pygame.image.load('Python/images/Yar1.png'))
        self.images.append(pygame.image.load('Python/images/Yar2.png'))
        self.images.append(pygame.image.load('Python/images/Yar3.png'))
        self.images.append(pygame.image.load('Python/images/Yar4.png'))
        self.images.append(pygame.image.load('Python/images/Yar5.png'))
        self.images.append(pygame.image.load('Python/images/Yar6.png'))
        self.images.append(pygame.image.load('Python/images/Yar5.png'))
        self.images.append(pygame.image.load('Python/images/Yar4.png'))
        self.images.append(pygame.image.load('Python/images/Yar3.png'))
        self.images.append(pygame.image.load('Python/images/Yar2.png'))
        self.index = 0
        self.image = self.images[self.index]
        self.screen_x = 120
        self.screen_y = 120
        self.yar_speed = 3
        self.yar_x_min = 9
        self.yar_x_max = 274
        self.yar_y_min = 0
        self.yar_y_max = 180

    
    def update(self):
        self.index += 1
        if self.index >= len(self.images):
            self.index = 0
        self.image = self.images[self.index]
        self.rect = pygame.Rect(self.screen_x, self.screen_y, 16, 18)


    def move_right(self):
        if self.screen_x >= self.yar_x_max:
            self.screen_x = self.yar_x_max
        else:
            self.screen_x += self.yar_speed

    def move_left(self):
        if self.screen_x <= self.yar_x_min:
            self.screen_x = self.yar_x_min
        else:
            self.screen_x -= self.yar_speed

    def move_up(self):
        if self.screen_y <= self.yar_y_min:
            self.screen_y = self.yar_y_min
        else:
            self.screen_y -= self.yar_speed

    def move_down(self):
        if self.screen_y >= self.yar_y_max:
            self.screen_y = self.yar_y_max
        else:
            self.screen_y += self.yar_speed            
        