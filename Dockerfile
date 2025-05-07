# Stap 1: Gebruik een Go-alpine image voor de builder
FROM golang:1.21-alpine AS builder

# Stap 2: Installeer benodigde dependencies
RUN apk add --no-cache git sqlite

# Stap 3: Stel de werkdirectory in voor de buildfase
WORKDIR /go/src/app

# Stap 4: Kopieer go.mod en go.sum naar de container
COPY go.mod go.sum ./

# Stap 5: Haal de Go dependencies op
RUN go mod tidy

# Stap 6: Kopieer de hele projectmap naar de container
COPY cmd/ ./cmd/
COPY db/ ./db/
COPY handlers/ ./handlers/
COPY services/ ./services/

# Stap 7: Bouw de Go applicatie
RUN go build -o main .

# Stap 8: Maak een kleinere runtime image
FROM alpine:latest

# Stap 9: Installeer benodigde runtime dependencies
RUN apk add --no-cache sqlite

# Stap 10: Stel de werkdirectory in voor de runtime
WORKDIR /root/

# Stap 11: Kopieer de gebouwde binary van de builder naar de runtime image
COPY --from=builder /go/src/app/main /root/

# Stap 12: Stel de entrypoint in voor de applicatie
CMD ["./main"]
