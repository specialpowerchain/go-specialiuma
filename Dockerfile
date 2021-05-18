# Build Gsp in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-specialiuma
RUN cd /go-specialiuma && make gsp

# Pull Gsp into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-specialiuma/build/bin/gsp /usr/local/bin/

EXPOSE 7234 7235 33990 33990/udp
ENTRYPOINT ["gsp"]
