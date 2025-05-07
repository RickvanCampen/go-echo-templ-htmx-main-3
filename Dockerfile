# Stap 1: Kies een lichte base image
FROM golang:1.21-alpine AS builder

# Stap 2: Installeer benodigde dependencies voor Go build
RUN apk add --no-cache git

# Stap 3: Maak de werkdirectory
WORKDIR /app

# Stap 4: Kopieer de Go module en dependencies
COPY go.mod go.sum ./
RUN go mod tidy

# Stap 5: Kopieer de volledige applicatiecode naar de container
COPY . .

# Stap 6: Bouw de Go applicatie
RUN go build -o main .

# Stap 7: Maak een nieuwe, schone image voor de runtime
FROM alpine:latest  

# Stap 8: Installeer benodigde libraries voor SQLite (indien nodig)
RUN apk add --no-cache sqlite

# Stap 9: Maak de werkdirectory
WORKDIR /root/

# Stap 10: Kopieer de gebouwde Go-binaire van de builder image
COPY --from=builder /app/main .

# Stap 11: Kopieer alle andere benodigde bestanden zoals templates en assets
COPY ./assets ./assets

# Stap 12: Expose de poort die de app gebruikt
EXPOSE 8080

# Stap 13: Start de applicatie
CMD ["./main"]
