#!/usr/bin/env sh

CONFIG="${CONFIG:-config.ini}"

M=""
if [ -z "${MYSQL_ENABLED}" ]; then
  logger -s "Env MYSQL_ENABLED not defined."
else
  crudini --set "${CONFIG}" MySQL enabled "${MYSQL_ENABLED}"
  crudini --set "${CONFIG}" DAV mysql_auth "${MYSQL_ENABLED}"
  M="-m"
fi


if [ -z "${MYSQL_HOST}" ]; then
  logger -s "Env MYSQL_HOST not defined."
else
  crudini --set "${CONFIG}" MySQL host "${MYSQL_HOST}"
fi

if [ -z "${MYSQL_PORT}" ]; then
  logger -s "Env MYSQL_PORT not defined."
else
  crudini --set "${CONFIG}" MySQL port "${MYSQL_PORT}"
fi

if [ -z "${MYSQL_USER}" ]; then
  logger -s "Env MYSQL_PORT not defined."
else
  crudini --set "${CONFIG}" MySQL user "${MYSQL_USER}"
fi

if [ -z "${MYSQL_PASS}" ]; then
  logger -s "Env MYSQL_PASS not defined."
else
  crudini --set "${CONFIG}" MySQL passwd "${MYSQL_PASS}"
fi

if [ -z "${MYSQL_BASE}" ]; then
  logger -s "Env MYSQL_BASE not defined."
else
  crudini --set "${CONFIG}" MySQL dbtable "${MYSQL_BASE}"
fi

# Create User Database Table and Insert system user
# Disable after the Table is created; for performance reasons
crudini --set "${CONFIG}" MySQL firstrun "0"

#[DAV]

# Verbose?
# verbose enabled is like loglevel = INFO
crudini --set "${CONFIG}" DAV verbose "${DAV_VERBOSE:-0}"

# log level : DEBUG, INFO, WARNING, ERROR, CRITICAL (Default is WARNING)
crudini --set "${CONFIG}" DAV loglevel "${DAV_LOGLEVEL:-DEBUG}"

# main directory
crudini --set "${CONFIG}" DAV directory "${DAV_STORAGE:-/data}"

# Server address
crudini --set "${CONFIG}" DAV port "${DAV_PORT:-8080}"
crudini --set "${CONFIG}" DAV host "${DAV_HOST:-localhost}"

# disable auth
crudini --set "${CONFIG}" DAV noauth "${DAV_NOAUTH:-1}"

# admin user
crudini --set "${CONFIG}" DAV user "${DAV_USERNAME}"
crudini --set "${CONFIG}" DAV password "${DAV_PASSWORD}"

# daemonize?
crudini --set "${CONFIG}" DAV daemonize "0"
crudini --set "${CONFIG}" DAV daemonaction "start"

# instance counter
crudini --set "${CONFIG}" DAV counter "0"

# mimetypes support
crudini --set "${CONFIG}" DAV mimecheck "1"

# webdav level (1 = webdav level 2)
crudini --set "${CONFIG}" DAV lockemulation "1"

# dav server base url
crudini --set "${CONFIG}" DAV baseurl "${DAV_BASEURL:-localhost}"

# Internal features
crudini --set "${CONFIG}" DAV chunked_http_response "${DAV_FEATURE_HTTP_CHUNKED_RESPONSE:-0}"
crudini --set "${CONFIG}" DAV http_request_use_iterator "${DAV_FEATURE_HTTP_REQUEST_USE_ITERATOR:-0}"
crudini --set "${CONFIG}" DAV http_response_use_iterator "${DAV_FEATURE_HTTP_RESPONSE_USE_ITERATOR:-0}"

davserver -c ${CONFIG} ${M}