### example multistage build - in this case, a simple package blacklist 
### will NOT stop this, since curl only is installed in the intermediate
### "builder" image and doesn't exist in the final image.  To stop this,
### we can look for curl in the RUN commands in the Dockerfile.

### STAGE 1
FROM alpine:latest as builder
WORKDIR /solunar_cmdline-master
RUN apk update && apk add --no-cache build-base curl
 
### Clone private repository
### NOTE: we could do something more conventional like:
### RUN git clone https://github.com/kevinboone/solunar_cmdline.git /solunar_cmdline
### and avoid the curl rule, but we can just as easily add similar
### rules for wget, git, etc
RUN curl -o - https://codeload.github.com/kevinboone/solunar_cmdline/zip/master | unzip -d / -
RUN make clean && make

### STAGE 2
FROM alpine:latest
MAINTAINER Paul Novarese pvn@novarese.net
LABEL name="solunar-demo"
LABEL maintainer="pvn@novarese.net"

HEALTHCHECK NONE
WORKDIR /usr/local/bin
COPY --from=builder /solunar_cmdline-master/solunar /usr/local/bin/solunar

# if you want to use a particular localtime,
# uncomment this and set zoneinfo appropriately
#RUN apk add --no-cache tzdata bash && cp /usr/share/zoneinfo/America/Chicago /etc/localtime

USER 65534:65534
CMD ["-c", "London"]
ENTRYPOINT ["/usr/local/bin/solunar"]
