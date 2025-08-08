FROM registry.access.redhat.com/ubi9/ubi-minimal:latest
RUN mkdir -p /releases
COPY ./releases/ /releases/

