#!/bin/sh
CC=gcc
CFLAGS="-D__GRUB__ -DHAVE_CONFIG_H -I. -I..  -Wall -DGRUB_MACHINE_PCBIOS=1 -DGRUB_MACHINE=I386_PC -m32 -nostdinc -isystem /usr/lib/gcc/i486-linux-gnu/4.7/include -I../include -I../include -DGRUB_FILE=\"tcc/tcc.c\" -I. -I. -I.. -I.. -I../include -I../include -I../grub-core/lib/libgcrypt-grub/src/    -D_FILE_OFFSET_BITS=64 -Os -Wall -Wpointer-arith -Wundef -Wchar-subscripts -Wcomment -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wformat-extra-args -Wformat-security -Wformat-y2k -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Wmain -Wmissing-braces -Wmissing-format-attribute -Wmultichar -Wno-parentheses -Wreturn-type -Wsequence-point -Wno-sign-compare -Wswitch -Wtrigraphs -Wunknown-pragmas -Wno-unused-parameter -Wno-unused-function -Wunused-variable -Wwrite-strings -Wnested-externs -Wno-strict-prototypes -g -Wextra -Wattributes -Wendif-labels -Winit-self -Wint-to-pointer-cast -Winvalid-pch -Wno-missing-field-initializers -Wnonnull -Woverflow -Wvla -Wpointer-to-int-cast -Wno-strict-aliasing -Wvariadic-macros -Wvolatile-register-var -Wpointer-sign -Wmissing-include-dirs -Wformat=2 -march=i386 -m32 -mrtd -mregparm=3 -falign-jumps=1 -falign-loops=1 -falign-functions=1 -freg-struct-return -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow -fno-dwarf2-cfi-asm -mno-stack-arg-probe -fno-asynchronous-unwind-tables -fno-unwind-tables -Qn -fno-stack-protector -Wtrampolines -Wno-format-nonliteral -Werror   -ffreestanding"
LDFLAGS="-Wl,-melf_i386 -Wl,--build-id=none  -nostdlib -Wl,-N -Wl,-r,-d"

run_local_command() {
	local have_space
	[ $# -lt 1 ] && return 255
	for a in "$@"; do
		printf %s "$a" | grep -Fq \  && have_space=1 || have_space=
		[ "$have_space" = 1 ] && printf \"
		printf %s "$a"
		[ "$have_space" = 1 ] && printf \"
		printf \ 
	done
	echo
	"$@"
}

set -e
 
#for source in loader/i386/multiboot_mbi.c loader/multiboot.c solaris_patch/loader_command_line.c; do
#	run_local_command $CC $CFLAGS -c $source
#done
make loader/i386/multiboot_module-multiboot_mbi.o loader/multiboot_module-multiboot.o
run_local_command $CC $CFLAGS -c solaris_patch/loader_command_line.c -o solaris_patch/multiboot_module-loader_command_line.o
run_local_command $CC $LDFLAGS loader/i386/multiboot_module-multiboot_mbi.o loader/multiboot_module-multiboot.o solaris_patch/multiboot_module-loader_command_line.o -o multiboot_no_escape.module
#grep -q ^multiboot_solaris: moddep.lst || echo "multiboot_solaris: boot video net relocator mmap lsapm vbe" >> moddep.lst
grep -q ^multiboot_no_escape: moddep.lst || echo "multiboot_no_escape: boot video net relocator mmap lsapm vbe" >> moddep.lst
run_local_command sh genmod.sh moddep.lst multiboot_no_escape.module build-grub-module-verifier multiboot_no_escape.mod
ls -l multiboot_no_escape.mod
