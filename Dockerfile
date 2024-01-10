FROM hub.tal.com/standard/golang:1.19-alpine as build

WORKDIR /src

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod tidy

COPY . .

RUN CGO_ENABLED=0 GOPROXY=https://goproxy.cn  GOOS=linux GOARCH=amd64 go build -o /src/csi-plugin ./cmd

FROM ubuntu:16.04
LABEL maintainers="Kubernetes Authors"
LABEL description="Baidu Cloud CSI Plugin"

RUN apt-get update && apt-get install -y parted && apt-get install -y xfsprogs
COPY --from=build /src/csi-plugin /usr/bin/csi-plugin
RUN chmod +x /usr/bin/csi-plugin

ENTRYPOINT ["csi-plugin"]