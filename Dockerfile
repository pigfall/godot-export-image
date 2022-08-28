FROM golang:1.18 as Builder

WORKDIR /app
RUN git clone https://github.com/pigfall/gd.git  && cd gd && CGO_ENABLED=0 go build -o gd ./cmd/gd

FROM androidsdk/android-30:latest

WORKDIR /tools
# copy exports cfg files
COPY exports /exports
# download godot
RUN curl -L https://downloads.tuxfamily.org/godotengine/3.5/mono/Godot_v3.5-stable_mono_linux_headless_64.zip -o godot.zip && unzip godot.zip -d godot && rm godot.zip
# link godot binary
RUN GODOT_BINARY_DIR="/tools/godot/$(ls godot)"; list_binary_path(){ find "${GODOT_BINARY_DIR}" -maxdepth 1 -type f -executable -print ; };  list_binary_path ;if [ $(list_binary_path | awk 'END{print NR}') -ne 1 ]; then echo "error: failed to find godot binary" && exit 1; else ln -s "$(list_binary_path)" /usr/bin/godot ; fi
COPY --from=Builder /app/gd/gd .
RUN ln -s /tools/gd /usr/bin/gd
# run gdoot once to generate editor config file
ENV GODOT_EDITOR_CFG_FILE=/root/.config/godot/editor_settings-3.tres
RUN godot --no-window --export-debug Android /tmp/outpu.apk 2> /dev/null || echo "verifying godot config file if generated"
RUN [ -f "${GODOT_EDITOR_CFG_FILE}" ] && echo "generate godot editor config file success" || (echo "generate godot editor config file failed" ;exit 1)
# set android-sdk-path of godot editor config
RUN sed -i "s/export\/android\/android_sdk_path.*/export\/android\/android_sdk_path = \"\/opt\/android-sdk-linux\"/g" "${GODOT_EDITOR_CFG_FILE}" && sed -i "s/export\/android\/debug_keystore = .*/export\/android\/debug_keystore = \"\/exports\/android\/debug.keystore\"/g" "${GODOT_EDITOR_CFG_FILE}"
