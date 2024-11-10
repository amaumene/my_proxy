FROM registry.access.redhat.com/ubi9/go-toolset AS builder

COPY ./src/goproxy.go ./goproxy.go

RUN go mod init github.com/d0rc/goproxy && go mod tidy && go build goproxy.go

FROM registry.access.redhat.com/ubi9/ubi-minimal

COPY --from=builder /opt/app-root/src/goproxy /app/goproxy

USER 1001

VOLUME /config
VOLUME /certs

EXPOSE 8080/tcp
EXPOSE 8443/tcp

CMD [ "/app/goproxy", "-config", "/config/config.txt" ]
