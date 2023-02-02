import numpy

import platform
from pathlib import Path
import asyncio

cdn = Path("https://cdn.jsdelivr.net/pyodide/dev/full")



async def main():
    print("PENIS")
    async with platform.fopen(cdn / "repodata.json", "r") as textfile:
        print(len(textfile.read()))
        print("2 PENIS")
asyncio.run(main())
#
