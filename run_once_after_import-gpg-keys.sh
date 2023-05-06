#!/bin/sh


gpg --recv-keys 22391b207dad6969
(echo trust &echo 5 &echo y &echo quit) | gpg --command-fd 0 --edit-key technat@technat.ch
