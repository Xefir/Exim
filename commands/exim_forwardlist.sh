#!/usr/bin/env bash

for file in /etc/exim4/forward/*
do
    echo "$(basename $file) -> $(cat $file)"
done
