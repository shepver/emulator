#!/bin/bash

erl -sname emulator -pa ./ebin ./deps/*/ebin -s emulator start -s observer start
