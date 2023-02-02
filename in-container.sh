#!/bin/bash -ex

rm -rf /mount/www/data
mkdir -p /mount/www/data

make_index() {
    echo '<body>' > /mount/www/data/index.html
    for full_path in $(find /mount/www/data/ -type d -maxdepth 1 -mindepth 1 | sort); do
	dirname=$(basename "$full_path")

	echo "<a href=\"/${dirname}\">/$dirname</a>" >> /mount/www/data/index.html
	echo '<br/>' >> /mount/www/data/index.html
    done
    echo '</body>' >> /mount/www/data/index.html
}

build() {
  (

    for full_path in $(find /mount/$1/ -type d -maxdepth 1 -mindepth 1); do
	dirname=$(basename "$full_path")
	echo "building $dirname..."
	(
	  (
	    pygbag \
		--template noctx.tmpl \
		--app_name src \
		--ume_block 1 \
		--can_close 1 \
		--package src \
		--title src \
		--cdn http://localhost:8000/archives/0.6/ \
		--build \
		$1/$dirname/main.py
		# --directory /mount/www/data \
		# --cache /mount/cache \

	    rm -rf /mount/www/data/$dirname
	    mkdir -p /mount/www/data/$dirname
	    mv /mount/$1/$dirname/build/web/* /mount/www/data/$dirname
	  ) || echo "\nERROR!!!\n $full_path"
	) &
    done
    wait
  )
}

start_nginx() {
  mkdir -p logs/nginx
  cp nginx.conf logs/nginx/nginx.conf
  /usr/sbin/nginx -p $PWD/logs/nginx -c nginx.conf
}

start_nginx &

build examples
build src
make_index

code_watch () {
  while /usr/bin/inotifywait --exclude '/mount/src/build/web' -e modify ./src; do
      echo "output reloading ..."
      build src
      make_index
  done
}

code_watch
