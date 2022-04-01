import pygame

class Yar(pygame.sprite.Sprite):
    def __init__(self):
        super(Yar, self).__init__()
        self.images=[]
        self.images.append(pygame.image.load('images/Yar1.png'))
        self.images.append(pygame.image.load('images/Yar2.png'))
        self.images.append(pygame.image.load('images/Yar3.png'))
        self.images.append(pygame.image.load('images/Yar4.png'))
        self.images.append(pygame.image.load('images/Yar5.png'))
        self.images.append(pygame.image.load('images/Yar6.png'))
        self.images.append(pygame.image.load('images/Yar5.png'))
        self.images.append(pygame.image.load('images/Yar4.png'))
        self.images.append(pygame.image.load('images/Yar3.png'))
        self.images.append(pygame.image.load('images/Yar2.png'))
        self.index = 0
        self.image = self.images[self.index]
        self.rect = pygame.Rect(7, 2, 16, 18)
    
    def update(self):
        self.index += 1
        if self.index >= len(self.images):
            self.index = 0
        self.image = self.images[self.index]
        