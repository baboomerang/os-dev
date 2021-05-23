#!/bin/bash
nasm bootloader.asm -f bin -o bootloader.flp
qemu-system-x86_64 bootloader.flp
