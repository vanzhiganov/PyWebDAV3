FROM rockylinux:9 as BUILD
COPY . /app
WORKDIR /app
RUN make dist

FROM rockylinux:9
RUN dnf update -y && \
    dnf install -y python3-six python3-cryptography python3-PyMySQL crudini && \
    dnf clean all && \
    mkdir /tmp
COPY --from=BUILD /app/dist/PyWebDAV3-*.tar.gz /tmp
RUN python -m pip install --no-cache-dir /tmp/PyWebDAV3-*.tar.gz && \
    rm -f /tmp/PyWebDAV3-*.tar.gz

ENV CONFIG /etc/webdav/config.ini

# INT
ENV MYSQL_ENABLED 0
ENV MYSQL_HOST localhost
# INT
ENV MYSQL_PORT 3306
ENV MYSQL_USER root
ENV MYSQL_PASS password
ENV MYSQL_BASE webdav

# INT
ENV DAV_VERBOSE 1
ENV DAV_LOGLEVEL DEBUG
ENV DAV_PORT 8080
ENV DAV_HOST 0.0.0.0
ENV DAV_NOAUTH 1
ENV DAV_USERNAME webdav
ENV DAV_PASSWORD webdav

ENV DAV_BASEURL http://localhost
ENV DAV_STORAGE /data

ENV DAV_FEATURE_HTTP_CHUNKED_RESPONSE 0
ENV DAV_FEATURE_HTTP_REQUEST_USE_ITERATOR 0
ENV DAV_FEATURE_HTTP_RESPONSE_USE_ITERATOR 0

EXPOSE 8080

ENTRYPOINT ["davserver"]
CMD ["-D", "${DAV_STORAGE}"]