#!/usr/bin/env bash

DIR=/etc/exim4/forward
for file in $DIR/*
do
    echo "$file: $(cat $DIR/$file)"
done
