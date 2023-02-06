import logging
log = logging.getLogger(__name__)

import asyncio


def register_autorefresh(interval_sec=1.0):
    print('=' * 10)
    print('|\n|     AUTOREFRESH\n|')
    print('=' * 10)

    import platform
    import asyncio
    import urllib.parse
    import json
    import sys
    import os
    import aio.gthread
    from threading import Thread
    import limeade
    FILES = ['version', 'log', 'status']
    urls = {}
    page_url = str(platform.window.location)
    check_url = urllib.parse.urlparse(page_url)
    app_name = check_url.path.strip('/')
    app_name = app_name
    check_url = check_url._replace(fragment='')
    for file in FILES:
        urls[file] = check_url._replace(path=os.path.join(check_url.path, f'build-{file}.txt')).geturl()

    async def get_data(file):
        async with platform.fopen(urls[file], 'r') as f:
            return f.read().strip()

    async def get_changed(since=''):
        q = f'?app_name={app_name}&since={since}'
        changed_url = "http://localhost:8000/api/http/has-code-changed"
        async with platform.fopen(changed_url + q, 'r') as f:
            s = f.read()
            try:
                return json.loads(s)
            except Exception as e:
                print('bad json: ' + str(e) + ": " + s)

    async def install_files(filenames):
        if not filenames:
            return
        for file in filenames:
            src_url = "http://localhost:8000/" + os.path.join('src', app_name, file)
            async with platform.fopen(src_url, 'r') as f:
                s = f.read()
            with open(file, 'w') as f:
                f.write(s)
        full_paths = set(os.path.join(os.getcwd(), file) for file in filenames)
        mods = [
            mod for mod in sys.modules.values() 
            if getattr(mod, '__file__', None) in full_paths
        ]
        if '__main__' in (m.__name__ for m in mods):
            log.warning("change in main ==> RELOADING PAGE")
            await asyncio.sleep(3)
            platform.window.location.reload()
        if mods:
            log.info('refreshing modules: ' + ', '.join(m.__name__ for m in mods))
        limeade.refresh(batch=mods)

    async def check_autorefresh():
        old_ts = (await get_changed())['now']
        while True:
            await asyncio.sleep(interval_sec)
            if aio.exit:
                break

            changed_files = await get_changed(old_ts)
            if await get_data('status') != 'ok':
                log.error(await get_data('log'))
                
            try:
                await install_files([d['path'] for d in changed_files['timestamps']])
                old_ts = max([old_ts] + [d['mtime'] for d in changed_files['timestamps']])
            except Exception as e:
                log.error('error when installing new files: ' + repr(e))
                log.exception(e)
            
    Thread(target=check_autorefresh).start()


async def main():
    register_autorefresh()
    import pygame
    import game

    print('=' * 10)
    print('|\n|      MAIN LOOP\n|')
    print('=' * 10)

    while True:
        game.main_loop_tick()
        pygame.display.update()
        await asyncio.sleep(0)


asyncio.run(main())
