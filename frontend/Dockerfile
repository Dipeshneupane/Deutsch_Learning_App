FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    ca-certificates \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

RUN git clone https://github.com/flutter/flutter.git "${FLUTTER_HOME}" --branch stable --depth 1

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter config --enable-web && flutter pub get

COPY . .
RUN flutter build web --release --dart-define=FIREBASE_ENABLED=false

FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY docker-entrypoint.sh /usr/local/bin/frontend-entrypoint.sh
RUN chmod +x /usr/local/bin/frontend-entrypoint.sh

COPY --from=build /app/build/web /srv

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/frontend-entrypoint.sh"]
