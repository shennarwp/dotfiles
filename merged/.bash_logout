#!/bin/bash

# clean terminal on logout; `reset` needs ncurses, which Alpine ships without
command -v reset >/dev/null && reset || clear
