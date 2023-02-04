import pygame, sys, random

# normal game set up
pygame.mixer.pre_init()
pygame.init()
clock = pygame.time.Clock()

# to set the screen size of the main window
screen_width = 1280
screen_height = 960
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption('Pong')

# Rectangles for the game

ball = pygame.Rect(screen_width/2 - 15, screen_height/2 - 15, 30, 30)
player = pygame.Rect(screen_width - 20, screen_height/2 - 70, 10, 140)
opponent = pygame.Rect(10, screen_height/2 - 70, 10, 140)


bg_color = pygame.Color(0, 0, 0)
ball_color = (255, 255, 255)
line_color = (132, 132, 130)
player_color = (0, 255, 0)
opponent_color = (255, 0, 0)
white = (255, 255, 255)

# game variables
ball_speed_x = 7 * random.choice((1, -1))
ball_speed_y = 7 * random.choice((1, -1))
player_speed = 0
opponent_speed = 7

# score timer
score_time = True


# text variables
player_score = 0
opponent_score = 0
game_font = pygame.font.Font("freesansbold.ttf", 32)

# game sound
pong_sound = pygame.mixer.Sound("sound/sfx_point.ogg")
pong_sound.set_volume(0.0)
score_sound = pygame.mixer.Sound("sound/sfx_swooshing.ogg")
score_sound.set_volume(0.0)




def ball_animation():
    global ball_speed_x, ball_speed_y, player_score, opponent_score, score_time
    ball.x += ball_speed_x
    ball.y += ball_speed_y

    if ball.top <= 0 or ball.bottom >= screen_height:
        pygame.mixer.Sound.play(pong_sound)
        ball_speed_y *= -1

    # player score    
    if ball.left <= 0:
        pygame.mixer.Sound.play(score_sound)
        player_score += 1
        score_time = pygame.time.get_ticks()

    # opponent score    
    if ball.right >= screen_width:
        pygame.mixer.Sound.play(score_sound)
        opponent_score += 1
        score_time = pygame.time.get_ticks()

    if ball.colliderect(player) and ball_speed_x > 0:
        pygame.mixer.Sound.play(pong_sound)
        if abs(ball.right - player.left) < 10:
            ball_speed_x *= -1
        elif abs(ball.bottom - player.top) < 10 and ball_speed_y > 0:
            ball_speed_y *= -1
        elif abs(ball.top - player.bottom) < 10 and ball_speed_y < 0:
            ball_speed_y *= -1

    if ball.colliderect(opponent) and ball_speed_x < 0: 
        pygame.mixer.Sound.play(pong_sound)
        if abs(ball.left - opponent.right) < 10:
            ball_speed_x *= -1
        elif abs(ball.bottom - opponent.top) < 10 and ball_speed_y > 0:
            ball_speed_y *= -1
        elif abs(ball.top - opponent.bottom) < 10 and ball_speed_y < 0:
            ball_speed_y *= -1

def player_animation():
    player.y += player_speed
    if player.top <= 0:
        player.top = 0
    if player.bottom >= screen_height:
        player.bottom = screen_height


def opponent_animation():
    if opponent.top < ball.y:
        opponent.y += opponent_speed
    if opponent.bottom > ball.y:
        opponent.y -= opponent_speed

    if opponent.top <= 0:
        opponent.top = 0
    if opponent.bottom >= screen_height:
        opponent.bottom = screen_height


def ball_start():
    global ball_speed_x, ball_speed_y, score_time

    current_time = pygame.time.get_ticks()
    ball.center = (screen_width/2, screen_height/2)

    if current_time - score_time < 700:
        number_three = game_font.render("3", False, white)
        screen.blit(number_three, (screen_width/2 - 10, screen_height/2 + 20))
    if 700 < current_time - score_time < 1400:
        number_number = game_font.render("2", False, white)
        screen.blit(number_number, (screen_width/2 - 10, screen_height/2 + 20))
    if 1400 < current_time - score_time < 2100:
        number_one = game_font.render("2", False, white)
        screen.blit(number_one, (screen_width/2 - 10, screen_height/2 + 20))

    if current_time - score_time < 2100:
        ball_speed_x, ball_speed_y = 0,0
    else:
        ball_speed_y = 7 * random.choice((1, -1))
        ball_speed_x = 7 * random.choice((1, -1))
        score_time = None


def main_loop():
    global player_speed
    #Handling input
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_DOWN:
                player_speed += 7
            if event.key == pygame.K_UP:
                player_speed -= 7
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_DOWN:
                player_speed -= 7
            if event.key == pygame.K_UP:
                player_speed += 7

    ball_animation()
    player_animation()
    opponent_animation()

    #game visuals
    screen.fill(bg_color)
    pygame.draw.rect(screen, player_color, player)
    pygame.draw.rect(screen, opponent_color, opponent)
    pygame.draw.ellipse(screen, ball_color, ball)
    pygame.draw.aaline(screen, line_color, (screen_width/2,0), (screen_width/2, screen_height))

    if score_time:
        ball_start()

    player_text = game_font.render(f"{player_score}", False, white)
    screen.blit(player_text, (660, 470))

    opponent_text = game_font.render(f"{opponent_score}", False, white)
    screen.blit(opponent_text, (600, 470))

    #updating the gamme window
    pygame.display.flip()
    clock.tick(75)


def register_autorefresh(interval_sec=1.0):
    import platform
    import urllib.parse
    import os
    import aio.gthread
    from threading import Thread
    FILES = ['version', 'log', 'status']
    urls = {}
    page_url = str(platform.window.location)
    check_url = urllib.parse.urlparse(page_url)
    check_url = check_url._replace(fragment='')
    for file in FILES:
        urls[file] = check_url._replace(path=os.path.join(check_url.path, f'build-{file}.txt')).geturl()
    print('autorefresh check urls = ' + str(urls))

    async def get_data(file):
        async with platform.fopen(urls[file], 'r') as f:
            return f.read().strip()

    async def check_autorefresh():
        old_version = None
        while True:
            await asyncio.sleep(interval_sec)
            if aio.exit:
                break
            new_version = await get_data('version')
            if old_version and old_version != new_version:
                status = await get_data('status')
                print('autorefresh: new version detected!')
                if status == 'ok':
                    print(f'autorefresh: refreshing {page_url}...')
                    platform.window.location.reload()
                else:
                    print(f'autorefresh: build status is {status}')
                    print('autorefresh: PAGE NOT REFRESHING!')
                    print(await get_data('log'))
            old_version = new_version
    Thread(target=check_autorefresh).start()


async def main():
    register_autorefresh()
    while True:
        main_loop()
        pygame.display.update()
        await asyncio.sleep(0)

asyncio.run(main())
