# Servidor de partidas de El Líder Secreto (Godot 4.7 headless).
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates unzip wget \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip -O /tmp/godot.zip \
 && unzip -q /tmp/godot.zip -d /tmp/godot \
 && mv /tmp/godot/Godot_v4.7-stable_linux.x86_64 /usr/local/bin/godot \
 && chmod +x /usr/local/bin/godot \
 && rm -rf /tmp/godot /tmp/godot.zip

WORKDIR /app
COPY . .

# Importa el proyecto para que Godot registre las clases globales (class_name) y genere .godot.
RUN godot --headless --path /app --import || true

# Render asigna el puerto en la variable PORT. net.gd lo lee al arrancar con --server.
CMD ["godot", "--headless", "--path", "/app", "--", "--server"]
