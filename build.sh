#!/bin/bash
set -eo pipefail
nasm stage1.asm -f bin -o bootloader.flp
qemu-system-x86_64 bootloader.flp
