# Use the official Golang 1.24.2 image as a base
FROM golang:1.24.2 as builder

WORKDIR /app

# Initialize Go module
RUN go mod init student-restapi

# Copy the source code
COPY . .

# Generate go.mod and go.sum
RUN go mod tidy

# Build the application with Linux architecture and static linking
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Use a minimal base image for the final build
FROM alpine:latest

WORKDIR /root/

ENV DB_HOST="" \ 
    DB_PORT="" \
    DB_USER="" \ 
    DB_PASS="" \
    DB_NAME="" \
    REDIS_ADDR="" \ 
    REDIS_TLS_INSECURE="" \
    AWS_REGION="" \ 
    AWS_ACCESS_KEY="" \
    AWS_SECRET_KEY="" \ 
    AWS_SESSION_TOKEN="" \
    AWS_BUCKET_NAME=""

# Install dependencies (optional but useful)
RUN apk add --no-cache ca-certificates

# Copy binary from builder
COPY --from=builder /app/main .

# Ensure the binary has execution permissions
RUN chmod +x main

# Expose application port
EXPOSE 8080

# Run the application
CMD ["./main"]