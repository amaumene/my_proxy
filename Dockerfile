FROM golang:alpine AS builder

RUN apk add --no-cache git

RUN git clone https://github.com/d0rc/goproxy.git /app

WORKDIR /app

RUN rm -rf vendor go.mod go.sum

RUN sed -ie 's/:https"/:8443"/g' src/goproxy.go
RUN sed -ie 's/:http"/:8080"/g' src/goproxy.go
RUN sed -ie 's/mainRouter.Use(compressionMiddleware)/\/\/mainRouter.Use(compressionMiddleware)/g' src/goproxy.go

RUN go mod init github.com/d0rc/goproxy && go mod tidy

RUN CGO_ENABLED=0 go build -o proxy src/goproxy.go

FROM scratch

COPY --chown=65532 --from=builder /app/proxy /app/proxy
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

VOLUME /config
VOLUME /certs

EXPOSE 8080/tcp
EXPOSE 8443/tcp

CMD [ "/app/proxy", "-config", "/config/config.txt" ]
