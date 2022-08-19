FROM golang:1.18 as Builder

WORKDIR /app
RUN git clone git@github.com:pigfall/gd.git && CGO_ENABLED=0 go build -o gd ./cmd/gd

FROM androidsdk/android-30:latest

WORKDIR /tools
# download godot
RUN curl -L https://downloads.tuxfamily.org/godotengine/3.5/mono/Godot_v3.5-stable_mono_linux_headless_64.zip -o godot.zip && unzip godot.zip -d godot && GODOT_BINARY_DIR="/tools/godot/$(ls godot)"; list_binary_path(){ $(find ${GODOT_BINARY_DIR} -maxdepth 1 -type f -executable -print) ; }; [ list_binary_path -ne 1 ] && echo "failed to find godot binary path "; exit 1  || GODOT_BINARY_PATH="$(list_binary_path)" ;ln -s "$GODOT_BINARY_PATH" /bin/godot

