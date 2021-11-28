FROM golang:apline

# TODO: do we need all of these?
RUN apk --no-cache add bash git git-lfs
RUN go get mvdan.cc/gofumpt

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]