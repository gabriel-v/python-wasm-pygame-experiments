#!/bin/bash -e

export PATH_EXPORT=/mount/.build/www
export PATH_TEMP_BUILD=/mount/.build/apps
export PATH_NGINX=/mount/.build/nginx
rm -rf $PATH_EXPORT
mkdir -p $PATH_EXPORT
rm -rf $PATH_TEMP_BUILD
mkdir -p $PATH_TEMP_BUILD
rm -rf $PATH_NGINX
mkdir -p $PATH_NGINX

export CODE_EXTENSION_DIR=/mount/.build/code/server-ext
export CODE_DATA_DIR=/mount/.build/code/server-data
mkdir -p "$CODE_EXTENSION_DIR"
mkdir -p "$CODE_DATA_DIR"


make_index() {
  (
  echo "making index..."

    echo '<body>' > $PATH_EXPORT/index.html
    for full_path in $(find $PATH_EXPORT/ -maxdepth 1 -mindepth 1 -type d   | sort); do
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
  cp /usr/local/lib/python3.11/pdb.py $1/hmac.py
  # cp -a /usr/local/lib/python3.11/http $1/http
  # cp /usr/local/lib/python3.11/asyncio/coroutines.py $1/asyncio/coroutines.py
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
      python3 -c "import time; print(time.time())" > "$versionpath"
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
    for full_path in $(find "/mount/$1/" -maxdepth 1 -mindepth 1 -type d  | sort); do
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

    cp code-server.yaml $CODE_DATA_DIR/code-server.yaml
    cd $CODE_DATA_DIR

    # export SERVICE_URL=https://open-vsx.org/vscode/gallery
    # export   ITEM_URL=https://open-vsx.org/vscode/item
    # code-server \
    #   --extensions-dir "$EXTENSION_DIR" \
    #   --install-extension gitduck.code-streaming  \
    #   --install-extension genuitecllc.codetogether \
    #   --install-extension ms-python.python  \
    #   --install-extension ms-python.black-formatter \
    #   --install-extension mads-hartmann.bash-ide-vscode

    code-server \
      --config $CODE_DATA_DIR/code-server.yaml
      --bind-addr=0.0.0.0:8081 \
      --auth=none \
      --cert=false \
      --disable-telemetry \
      --disable-update-check \
      --disable-file-downloads \
      --disable-workspace-trust \
      --disable-getting-started-override \
      --disable-file-downloads \
      --disable-workspace-trust \
      --user-data-dir="$CODE_DATA_DIR" \
      --proxy-domain="localhost" \
      /mount
      # --extensions-dir "$EXTENSION_DIR" \
      # --enable-proposed-api genuitecllc.codetogethe \
  # ) 2>&1 > /dev/null
  )
}


start_api() {
  (
    gunicorn -b 0.0.0.0:8082 --worker-class gevent --workers 4 --threads 100 api_autoreloader:app
  # gunicorn -b 0.0.0.0:8082 --worker-class sync api_autoreloader:app
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

start_api &
start_nginx &
start_code_server &

# build examples
build src
make_index
code_watch &
bash

