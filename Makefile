#
# libn64c/Makefile: Makefile for libn64c.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014-16 Tyler J. Stachecki <stachecki.tyler@gmail.com>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

ifdef SystemRoot
FIXPATH = $(subst /,\,$1)
RM = del /Q
CP = copy
else
FIXPATH = $1
RM = rm -f
CP = cp
endif

LIB_NAME = $(notdir $(CURDIR))

AS = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-as)
AR = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-gcc-ar)
CC = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-gcc)
CPP = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-cpp)
LD = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-ld)
OC = $(call FIXPATH,$(CURDIR)/../tools/bin/mips64-elf-objcopy)

RSPASM = $(call FIXPATH,$(CURDIR)/../tools/bin/rspasm)

CFLAGS = -Wall -Wextra -pedantic -std=c99 \
	-I../include -I./include
#-save-temps
OPTFLAGS = -Os -march=vr4300 -mtune=vr4300 -mabi=eabi -mgp64 -mfp64 -mlong64 \
	-flto -ffat-lto-objects -ffunction-sections -fdata-sections \
	-G4 -mno-extern-sdata -mgpopt -mfix4300 -mbranch-likely \
	-mno-check-zero-division

ASMFILES = $(call FIXPATH,\
	src/entry.S \
)
#	src/stage3.s \

CFILES = $(call FIXPATH,\
)
#	src/nus64.c \

UCODES = $(call FIXPATH,\
)

BINARYFILES = $(call FIXPATH,\
)
#	data/ExceptionHandler.bin \

OBJFILES = \
	$(CFILES:.c=.o) \
#	$(ASMFILES:.s=.o) \
	$(ASMFILES:.S=.o) \
	$(UCODES:.rsp=.o) \
	$(BINARYFILES:.bin=.o)

DEPFILES = $(OBJFILES:.o=.d)

#
# Primary targets.
#
$(LIB_NAME).a: $(OBJFILES)
	@echo $(call FIXPATH,"Building: $(LIB_NAME)/$@")	
	@$(AR) rcs $@ $^
	@$(CP) $(call FIXPATH, $(LIB_NAME).a) $(call FIXPATH, ../lib)
	@$(CP) $(call FIXPATH, ./include/n64c.h) $(call FIXPATH, ../include)
#
# Generic compilation/assembly targets.
#
%.o: %.bin
	@echo $(call FIXPATH,"Objectifying: $(LIB_NAME)/$<")
	@$(OC) -I binary -O elf64-bigmips -B mips:4000 $< $@

%.o: %.S	
	@echo $(call FIXPATH,"Assembling: $(LIB_NAME)/$<")
	@$(CC) -x assembler-with-cpp $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.o: %.c	
	@echo $(call FIXPATH,"Compiling: $(LIB_NAME)/$<")
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.o: %.rsp %.rsps
	@echo $(call FIXPATH,"Assembling: $(ROM_NAME)/$@")
	@$(CPP) -E -Iucodes $< > $(<:.rsp=.rsppch)
	@$(RSPASM) $(<:.rsp=.rsppch) -o $(<:.rsp=.bin)
	@$(CC) -x assembler-with-cpp $(CFLAGS) $(OPTFLAGS) -MMD -c $(<:.rsp=.rsps) -o $@

#
# Clean project target.
#
.PHONY: clean
clean:
	@echo "Cleaning $(LIB_NAME)..."
	@$(RM) $(LIB_NAME).a 
# $(OBJFILES) $(DEPFILES)

