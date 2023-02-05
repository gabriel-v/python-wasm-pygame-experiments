#!/bin/bash -e

export PATH_EXPORT=/mount/www/data
export PATH_TEMP_BUILD=/mount/.build
export PATH_NGINX=/mount/.build/nginx

rm -rf $PATH_EXPORT
mkdir -p $PATH_EXPORT
rm -rf $PATH_TEMP_BUILD
mkdir -p $PATH_TEMP_BUILD
rm -rf $PATH_NGINX
mkdir -p $PATH_NGINX

make_index() {
  (
  echo "making index..."

    echo '<body>' > $PATH_EXPORT/index.html
    for full_path in $(find $PATH_EXPORT/ -type d -maxdepth 1 -mindepth 1  | sort); do
    dirname=$(basename "$full_path")

    echo "<a href=\"/${dirname}\">/$dirname</a>" >> $PATH_EXPORT/index.html
    echo '<br/>' >> $PATH_EXPORT/index.html
    done
    echo '</body>' >> $PATH_EXPORT/index.html
  )
}

copy_assets() {
  (
  echo "copying assets to $1 ..."
  # cp /usr/local/lib/python3.11/pdb.py $1/pdb.py
  )
}

build_one() {
  (
    cd "$PATH_TEMP_BUILD"

    full_path="$2"
    dirname=$(basename "$full_path")
    echo "START build: $full_path ..."
    destpath="$PATH_TEMP_BUILD/$1/$dirname"
    destparent="$PATH_TEMP_BUILD/$1"
    mkdir -p $destpath
    main="$PATH_TEMP_BUILD/$1/$dirname/main.py"
    logpath="$PATH_TEMP_BUILD/$1/$dirname/build/web/build-log.txt"
    versionpath="$PATH_TEMP_BUILD/$1/$dirname/build/web/build-version.txt"
    statuspath="$PATH_TEMP_BUILD/$1/$dirname/build/web/build-status.txt"
    mkdir -p "$(dirname "$logpath")"
    touch "$logpath" "$versionpath" "$statuspath"

    set +e
    (
      (
      set -e
      copy_assets "$destpath"
      cp -a "$full_path" "$destparent"

      pygbag \
      --template noctx.tmpl \
      --app_name src \
      --ume_block 0 \
      --can_close 1 \
      --package src \
      --title src \
      --cdn http://localhost:8000/archives/0.7/ \
      --build \
      "$main"
      # --directory $PATH_EXPORT \
      # --cache /mount/cache \
      ) 2>&1
    ) > $logpath
    status=$?
    if [ $status -eq 0 ] ; then
      echo "build OK:    $full_path"
      date > "$versionpath"
      echo "ok" > "$statuspath"
    else
      echo "build FAIL:  $full_path"
      cat $logpath | tail -n20
      date > "$versionpath"
      echo "error" > "$statuspath"
    fi

    rm -rf $PATH_EXPORT/$dirname
    mv $1/$dirname/build/web $PATH_EXPORT/$dirname
  )
}

build() {
  (
    mkdir -p "$PATH_TEMP_BUILD"
    cd "$PATH_TEMP_BUILD"
    for full_path in $(find "/mount/$1/" -type d -maxdepth 1 -mindepth 1 | sort); do
      (
    build_one "$1" "$full_path"
      ) &
    done
    wait
  )
}

start_nginx() {
  (
  cp nginx.conf "$PATH_NGINX/nginx.conf"
  cd $PATH_NGINX
  /usr/sbin/nginx -p "$PATH_NGINX" -c nginx.conf
  )
}

start_code_server() {
  (
    echo "STARTING CODE SERVER..."
    code-server --config code-server.yaml
  )
}

code_watch () {
  (
  while true; do
    echo "starting autoreloader..."
    (
      /usr/bin/inotifywait -m --recursive --exclude 'build/web' --exclude 'build/web-cache' -e modify ./src | \
      while read -r dir action file; do
    (
      src_folder=$(echo $dir | cut -d/ -f2)
      src_fullpath=$(echo $dir | cut -d/ -f1-3)
      src_fullpath=$(realpath "$src_fullpath")
      if [[ -d "$src_folder" && -d "$src_fullpath" ]]; then
        build_one "$src_folder" "$src_fullpath"
     make_index
      fi
    )
      done
    ) || true
    sleep 1
  done
  )
}

start_nginx &
start_code_server &

# build examples
build src
make_index

code_watch &
bash
