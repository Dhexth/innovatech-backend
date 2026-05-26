#!/bin/sh

java -jar despachos.jar --server.port=8080 &
java -jar ventas.jar --server.port=8081

wait