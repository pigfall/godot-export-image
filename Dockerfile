FROM golang:1.18 as Builder

WORKDIR /app
RUN CGO_ENABLED=0 go build -o gd ./cmd/gd

FROM androidsdk/android-30:latest

WORKDIR /tools
# download godot
RUN curl -L https://downloads.tuxfamily.org/godotengine/3.5/mono/Godot_v3.5-stable_mono_linux_headless_64.zip -o godot.zip && unzip godot.zip -d godot && GODOT_BINARY_DIR="/tools/godot/$(ls godot)"; GODOT_BINARY_PATH="$(find ${GODOT_BINARY_DIR} -maxdepth 1 -type f -executable -print)" && ln -s "$GODOT_BINARY_PATH" /bin/godot

