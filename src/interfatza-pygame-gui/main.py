with open('main.py') as f:
    print(f.read())

import asyncio
import pygame
import pygame_gui  # noqa

from pygame_gui import UIManager, UI_BUTTON_PRESSED
from pygame_gui.elements import UIButton


pygame.init()
pygame.display.set_caption('Quick Start')
window_surface = pygame.display.set_mode((800, 600))
background = pygame.Surface((800, 600))
print('pygame init done')


class Loader:
    def __init__(self):
        self.started = False

    def start(self):
        print('starting asset loader')
        self.started = True

    def started(self):
        return self.started

    def add_resource(self, resource):
        print('adding resource ' + str(resource))
        return resource.load()

    def update(self):
        return 1.0


print('creating manager...')
manager = UIManager(
    window_resolution=(800, 600),
    theme_path='pygame_gui_data/default_theme.json',
    enable_live_theme_updates=False,
    resource_loader=Loader(),
)
print('manager loaded.')


async def main():
    import pygame.freetype
    pygame.freetype.init()
    import pygame.ftfont
    pygame.ftfont.init()

    print('hello from main...')
    background.fill(manager.ui_theme.get_colour('dark_bg'))
    clock = pygame.time.Clock()
    is_running = True
    print()
    print("G: pygame GUI init done")
    print()
    hello_button = UIButton(
        relative_rect=pygame.Rect(100, 100, 350, 280),
        text='Hello',
        manager=manager,
    )

    while is_running:
        time_delta = clock.tick(60)/1000.0
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                is_running = False
            if event.type == UI_BUTTON_PRESSED:
                if event.ui_element == hello_button:
                    print('Hello World!')
            manager.process_events(event)

        manager.update(time_delta)

        window_surface.blit(background, (0, 0))
        manager.draw_ui(window_surface)

        pygame.display.update()
        await asyncio.sleep(0)  # Very important, and keep it 0


print()
print('G: starting asyncio main loop')
print()

asyncio.run(main())
#
