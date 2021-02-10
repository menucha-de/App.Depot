#!/bin/bash

if [ "$REMOTE_ADDR" != "${REMOTE_ADDR%:0]}" ]; then
  echo Status: 401 Unauthorized
  echo
  exit 0
fi

ROOT=$(dirname $(realpath $0))/../../files
NAME=$(basename $PATH_INFO)

case "$REQUEST_METHOD" in
  POST)
    if [ -f $ROOT/$NAME ]; then
      DATE=$(stat -c "%y" $ROOT/$NAME)
    fi
    cat >$ROOT/$NAME
    if [[ ! -z "$DATE" ]]; then
      touch -d "${DATE::19}" $ROOT/$NAME
    fi
    echo Status: 200 OK
    echo Content-Type: text/plain; charset=utf-8
    echo
    echo File uploaded
    ;;
  GET)
    if [ -z "$NAME" ] && [ -z "$QUERY_STRING"]; then
       echo Status: 200 OK
       echo Content-Type: application/octet-stream
       echo
       tar chC $ROOT .
    else
      if [ -f $ROOT/$NAME ]; then
        case "$QUERY_STRING" in
          DELETE)
            echo Status: 200 OK
            echo Content-Type: text/plain; charset=utf-8
            echo
            rm $ROOT/$NAME
            echo File deleted
            ;;
          *)
            if [ -z "$QUERY_STRING"]; then
              echo Status: 200 OK
              echo Content-Type: application/octet-stream
              echo
              cat $ROOT/$NAME
            else
              echo Status: 400 Bad Request
              echo Content-Type: text/plain; charset=utf-8
              echo                                                                                                                                                  
              echo Unknown query
            fi
            ;;
        esac
      else                                                                                                                                                       
        echo Status: 404 OK
        echo Content-Type: text/plain; charset=utf-8
        echo
        echo File not found
      fi
    fi
    ;;
  *)
    echo Status: 400 Bad Request
    echo Content-Type: text/plain; charset=utf-8
    echo
    echo Unknown method
    ;;
esac
