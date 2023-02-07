# 

## start servers

### Bash + Docker

```bash
git clone --recurse-submodules https://github.com/gabriel-v/python-wasm-pygame-experiments

cd python-wasm-pygame-experiments

./run.sh
```

### PowerShell + Docker

```
git clone --recurse-submodules https://github.com/gabriel-v/python-wasm-pygame-experiments

cd python-wasm-pygame-experiments

docker run --name pygame-server-experiments-wasm --rm -i     -p 127.0.0.1:8000:8000     -v ${PWD}:/mount   -w "/mount"     --entrypoint "/bin/bash" --hostname videogame     gabrielv/python-browser-experiments:pygbag-wasm-0.7.2 /mount/in-container.sh
```

## open links

- split screen in 2
- code editor http://localhost:8000/vs-code/?folder=/mount
- hot reload pong - http://localhost:8000/test-hotreload/#debug
- in vs-code editor, change `src/test-hotreload/game.py` and see game reset itself to new code

## how to use

- copy `src/test-hotreload` into `src/your-new-thing`
- restart container and open http://localhost:8000/your-new-thing/#debug
- edit src/your-new-thing/game.py` in vs-code

## browser hot reload

- changing anything in http://localhost:8000/vs-code automatically writes changes to container
- browser thread started by `register_autorefresh()` periodically downloads new code from http://localhost:8000/src/ into the virtual fs
- then it uses vendored limeade library to hot-reload new code
- each module refreshed independently, see https://github.com/CFSworks/limeade
- update of main.py (`__name__ == "__main__"`) triggers browser tab refresh (slow), use more modules


todo:
- port https://github.com/breuleux/jurigged for per-function reloads
- debounce edits ~3s in `api_autoreloader.py`
- use inotifywait in `api_autoreloader.py` instead of polling
- trigger bash rebuilds from `api_autoreloader.py` before returning a changed main.py
- websockets?
- upstream hot reload?


---

todo:
- torch
- nodezator
