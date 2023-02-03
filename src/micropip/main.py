import platform
import micropip
async def main():
    async with platform.fopen('https://pypi.org/pypi/torch/json') as f:
        print('json len = ' + str(len(f.read())))
    await micropip.install('torch')

asyncio.run(main())
