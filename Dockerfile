FROM golang:1.19.5-alpine

# TODO: do we need all of these?
RUN apk --no-cache add bash git git-lfs &&\
    go install mvdan.cc/gofumpt@latest

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]