FROM golang AS builder

WORKDIR /app

COPY ./src/proxy.go ./proxy.go

RUN go mod init github.com/amaumene/my_proxy && go mod tidy

RUN CGO_ENABLED=0 go build proxy.go

FROM scratch

COPY --chown=65532 --from=builder /app/proxy /app/proxy

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

VOLUME /config
VOLUME /certs

EXPOSE 8080/tcp
EXPOSE 8443/tcp

CMD [ "/app/proxy", "-config", "/config/config.txt" ]
