#!/usr/bin/env bash

exim -bp | exiqgrep -i | xargs exim -Mrm
