FROM python:3.11-bullseye
RUN apt-get -y update && apt-get -y install inotify-tools nginx git ffmpeg
RUN mkdir /archives
RUN git clone --depth 1 https://github.com/pygame-web/archives /archives/archives
RUN chmod -R a+r /archives

ADD requirements.txt .
RUN pip install -r requirements.txt

RUN whereis ffmpeg
ENV PATH="$PATH:/usr/bin"
