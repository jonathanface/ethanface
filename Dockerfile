# -------- Frontend build --------
FROM node:22-alpine AS frontend-builder

WORKDIR /app/ui
# Only copy manifest first for better caching
COPY ui/package*.json ./
RUN npm ci

# Copy the rest of the UI
COPY ui/ ./

RUN npm run build

# -------- Backend build --------
FROM golang:1.24-alpine AS backend-builder

WORKDIR /src

# Enable modules & static build
ENV CGO_ENABLED=0 GOOS=linux

# Cache deps
COPY go.mod go.sum ./
RUN go mod download

# Copy backend source
COPY cmd/main.go ./main.go

# Bring in built UI assets
COPY --from=frontend-builder /app/ui/dist ./ui

# Build optimized binary
RUN go build -ldflags="-s -w" -o /out/app ./main.go

# -------- Minimal runtime --------
FROM gcr.io/distroless/base-debian12 

WORKDIR /app
# Copy binary and UI
COPY --from=backend-builder /out/app ./app
COPY --from=backend-builder /src/ui ./ui

# Runtime env
ENV PORT=80 \
    GIN_MODE=release

EXPOSE 80

CMD ["./app"]
