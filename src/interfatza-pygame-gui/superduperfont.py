import pygame
import pygame.font

class Font(pygame.font.Font):
    def __init__(self, *a, **k):
        super().__init__(*a, **k)
        self.origin = False
        self.pad = False
        self.__g__poz = (0, 0)

    def get_rect(self, text):
        size = self.size(text)
        print(size)
        return pygame.Rect(size[0], size[1], self.__g__poz[0], self.__g__poz[1])

    def render(self, text, fgcolor=None, bgcolor=None, **kw):
        antialias = False
        return (super().render(text, antialias, fgcolor, bgcolor), self.get_rect())

    def render_to(self, surf, dest, text, fgcolor=None, bgcolor=None, **kw):
        antialias = False
        new_surf = super().render(text, antialias, fgcolor, bgcolor)
        surf.blit(new_surf, dest)
        x, y = self.size(text)
        self.__g__poz = (self.__g__poz[0] + x, self.__g__poz[1])
        return self.get_rect(text)

    def get_metrics(self, *a, **k):
        return super().metrics(*a, **k)

# import pygame.freetype
# pygame.freetype.init()
# Font = pygame.freetype.Font
