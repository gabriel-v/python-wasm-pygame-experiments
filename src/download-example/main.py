import numpy

import platform
from pathlib import Path
import asyncio

cdn = Path("https://cdn.jsdelivr.net/pyodide/dev/full")

async def main():
    x = numpy.array()
    async with platform.fopen(cdn / "repodata.json", "r") as textfile:
        print('download = ' + len(textfile.read()))
asyncio.run(main())
#
