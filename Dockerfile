# syntax=docker/dockerfile:1

# --- BUILD STAGE ---
FROM golang:1.20 AS build-stage

# Set destination for COPY
WORKDIR /app

# Download Go modules
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/reference/dockerfile/#copy
COPY . ./

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /kvs

# --- DEPLOY STAGE ---
# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /kvs /kvs

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/kvs"]