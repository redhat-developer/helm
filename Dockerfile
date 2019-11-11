FROM centos:7 as build-tools
ENV LANG=en_US.utf8
ENV GOPATH /tmp/go
ARG GO_PACKAGE_PATH=github.com/redhat-developer/helm

ENV GIT_COMMITTER_NAME devtools
ENV GIT_COMMITTER_EMAIL devtools@redhat.com
ENV PATH=:$GOPATH/bin:/tmp/goroot/go/bin:$PATH

WORKDIR /tmp

RUN mkdir -p $GOPATH/bin
RUN mkdir -p /tmp/goroot

RUN curl -Lo go1.12.6.linux-amd64.tar.gz https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz && tar -C /tmp/goroot -xzf go1.12.6.linux-amd64.tar.gz

RUN mkdir -p ${GOPATH}/src/${GO_PACKAGE_PATH}/

WORKDIR ${GOPATH}/src/${GO_PACKAGE_PATH}

ENTRYPOINT [ "/bin/bash" ]

