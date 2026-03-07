# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 – Build
# ─────────────────────────────────────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy dependency manifests first for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy remaining source
COPY . .

# Build the Flutter web release
RUN flutter build web --release

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 – Serve
# ─────────────────────────────────────────────────────────────────────────────
FROM nginxinc/nginx-unprivileged:alpine AS server

# Copy compiled web output from the build stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy customised nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
