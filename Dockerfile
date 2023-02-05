FROM python:3.11-bullseye
RUN apt-get -y update && apt-get -y install inotify-tools nginx git ffmpeg emscripten vim wget curl \
       git curl wget lz4 pv pkg-config build-essential cmake
RUN mkdir /archives
RUN git clone --depth 1 https://github.com/pygame-web/archives /archives/archives
RUN chmod -R a+r /archives

RUN apt-get install -y patchelf wget lz4 sudo lsb-release

RUN mkdir /vg_lib
WORKDIR /vg_lib
COPY lib/python-wasm-sdk /vg_lib/python-wasm-sdk
RUN cd /vg_lib/python-wasm-sdk && chmod +x ./python-wasm-sdk.sh && bash -c "./python-wasm-sdk.sh"

ENV SDK_VERSION=3.1.31.1
ENV SYS_PYTHON=/usr/bin/python3
ENV PACKAGES="emsdk lvgl pygame"
ENV STATIC=true
ENV BUILDS="3.11"
ENV CYTHON="Cython-3.0.0a11-py2.py3-none-any.whl"
ENV LD_VENDOR="-sUSE_GLFW=3"
ENV PYBUILD="3.11"

COPY lib/pygbag /vg_lib/pygbag
COPY setup.py /vg_lib/pygbag/setup.py
RUN bash /vg_lib/pygbag/packages.d/lvgl/lvgl.sh
RUN cd /vg_lib/pygbag && bash ./scripts/build-pkg.sh
RUN cd /vg_lib/pygbag && bash ./scripts/build-loader.sh
RUN cd /vg_lib/pygbag && pip install -e .

RUN cp -a /vg_lib/pygbag/build/web/archives/0.7 /archives/archives/0.7

RUN mkdir /vg_app
WORKDIR /vg_app
ADD requirements.txt .
RUN pip install -r requirements.txt

RUN whereis ffmpeg
ENV PATH="$PATH:/usr/bin"

WORKDIR /vg_lib
# RUN apt-get install -y 
ENV CODE_SERVER_VERSION=4.9.1
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_SERVER_VERSION/code-server_${CODE_SERVER_VERSION}_amd64.deb && dpkg -i code-server_${CODE_SERVER_VERSION}_amd64.deb
# ENV CODER_SERVER_VERSION=0.16.0
# RUN curl -fOL https://github.com/coder/coder/releases/download/v$CODER_SERVER_VERSION/coder_${CODER_SERVER_VERSION}_linux_amd64.deb && dpkg -i coder_${CODER_SERVER_VERSION}_linux_amd64.deb
# 

RUN apt-get install -y shellcheck postgresql-13

RUN useradd -ms /bin/bash you
RUN mkdir -p /mount && chown you:you /mount
WORKDIR /mount
USER you
ENTRYPOINT /bin/bash
CMD ./in-container.sh
