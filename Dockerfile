# Build JKNetwork in a stock Go builder container
FROM golang:1.16-alpine as builder

RUN apk --no-cache add build-base git mercurial gcc linux-headers
ENV D=/jknetwork
WORKDIR $D
# cache dependencies
ADD go.mod $D
ADD go.sum $D
RUN go mod download
# build
ADD . $D
RUN cd $D && make all && mkdir -p /tmp/jknetwork && cp $D/bin/* /tmp/jknetwork/

# Pull all binaries into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /tmp/jknetwork/* /usr/local/bin/
EXPOSE 6060 8545 8546 30303 30303/udp 30304/udp
CMD [ "jknetwork" ]
