###############################################################################
# Makefile - build script 
#
###############################################################################

###
# build environment
###

# Replace with the path to your yagarto install directory.
# Note: Any paths with spaces in it must have quotes around them, like below:
#PREFIX ?= "/C/yagarto-20121222"
PREFIX ?= "/C/Users/Owner/Documents/2016-2017/Spring/CMPE240/linaro"
ARMGNU ?= $(PREFIX)/bin/arm-eabi

# Uncomment to create a C assembler listing
CASM_LIST = -Wa,-adhln	> $(BUILD)$*.lst

# The intermediate directory for compiled object files.
BUILD = build/

OUTPUT = bin/

# The directory in which source files are stored.
SOURCE = source/

###
# Targets
###

# The name of the output file to generate.
TARGET = $(OUTPUT)kernel7.img

# The name of the assembler listing file to generate.
LIST = $(OUTPUT)kernel7.list

# The name of the map file to generate.
MAP = $(OUTPUT)kernel7.map

###
# Sources
###

# The name of the linker script to use.
LINKER = kernel_c.ld

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS := $(patsubst $(SOURCE)%.s,$(BUILD)%.o,$(wildcard $(SOURCE)*.s))
OBJECTS += $(patsubst $(SOURCE)%.c,$(BUILD)%.o,$(wildcard $(SOURCE)*.c))
OBJECTS += $(patsubst $(SOURCE)%.cpp,$(BUILD)%.o,$(wildcard $(SOURCE)*.cpp))

###
# Build flags
###

DEPENDFLAGS := -MD -MP
INCLUDES    := -I include

BASEFLAGS   := -pedantic -pedantic-errors -nostdlib
BASEFLAGS   += -nostartfiles -ffreestanding -nodefaultlibs

# Pi 1 compile flags
#BASEFLAGS   += -O2 -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s

# A+ compile flags
# BASEFLAGS   += -O2 -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s -DPI2

# Pi 2 compile flags
#BASEFLAGS += -O2 -mfpu=neon-vfpv4 -mfloat-abi=hard -march=armv7-a -mtune=cortex-a7  -DPI2

# Pi 3 compile flags
BASEFLAGS   += -O2 -march=armv8-a -mtune=cortex-a53 -DPI2

### Warnings ###

# -Wall turns on the following flags ( from https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html ):
# -Waddress   
# -Warray-bounds=1 (only with -O2)  
# -Wbool-compare  
# -Wc++11-compat  -Wc++14-compat
# -Wchar-subscripts  
# -Wcomment  
# -Wduplicate-decl-specifier (C and Objective-C only) 
# -Wenum-compare (in C/ObjC; this is on by default in C++) 
# -Wformat   
# -Wimplicit (C and Objective-C only) 
# -Wimplicit-int (C and Objective-C only) 
# -Wimplicit-function-declaration (C and Objective-C only) 
# -Winit-self (only for C++) 
# -Wlogical-not-parentheses
# -Wmain (only for C/ObjC and unless -ffreestanding)  
# -Wmaybe-uninitialized 
# -Wmemset-elt-size 
# -Wmemset-transposed-args 
# -Wmisleading-indentation (only for C/C++) 
# -Wmissing-braces (only for C/ObjC) 
# -Wnarrowing (only for C++)  
# -Wnonnull  
# -Wnonnull-compare  
# -Wopenmp-simd 
# -Wparentheses  
# -Wpointer-sign  
# -Wreorder   
# -Wreturn-type  
# -Wsequence-point  
# -Wsign-compare (only in C++)  
# -Wsizeof-pointer-memaccess 
# -Wstrict-aliasing  
# -Wstrict-overflow=1  
# -Wswitch  
# -Wtautological-compare  
# -Wtrigraphs  
# -Wuninitialized  
# -Wunknown-pragmas  
# -Wunused-function  
# -Wunused-label     
# -Wunused-value     
# -Wunused-variable  
# -Wvolatile-register-var

# -Wextra turns on the following errors:
# -Wclobbered  
# -Wempty-body  
# -Wignored-qualifiers 
# -Wmissing-field-initializers  
# -Wmissing-parameter-type (C only)  
# -Wold-style-declaration (C only)  
# -Woverride-init  
# -Wsign-compare (C only) 
# -Wtype-limits  
# -Wuninitialized  
# -Wshift-negative-value (in C++03 and in C99 and newer)  
# -Wunused-parameter (only with -Wunused or -Wall).  Removed below with -Wno-unused-parameter
# -Wunused-but-set-parameter (only with -Wunused or -Wall).  Removed below with -Wno-unused-but-set-parameter

WARNFLAGS   := -Wall -Wextra -Wshadow -Wcast-align -Wwrite-strings
WARNFLAGS   += -Wredundant-decls -Winline
WARNFLAGS   += -Wno-attributes -Wno-deprecated-declarations
WARNFLAGS   += -Wno-div-by-zero -Wno-endif-labels -Wfloat-equal
WARNFLAGS   += -Wformat=2 -Wno-format-extra-args -Winit-self
WARNFLAGS   += -Winvalid-pch -Wmissing-format-attribute
WARNFLAGS   += -Wmissing-include-dirs -Wno-multichar
WARNFLAGS   += -Wredundant-decls -Wshadow
WARNFLAGS   += -Wno-sign-compare -Wsystem-headers -Wundef
WARNFLAGS   += -Wno-pragmas -Wno-unused-but-set-parameter
WARNFLAGS   += -Wno-unused-but-set-variable -Wno-unused-result -Wno-unused-parameter
WARNFLAGS   += -Wwrite-strings -Wdisabled-optimization -Wpointer-arith
WARNFLAGS   += -Wno-unused-function -Wno-unused-variable

#Warnings are errors.
WARNFLAGS   += -Werror

### Assembly Flags ###

ASFLAGS     := $(INCLUDES) $(DEPENDFLAGS) -D__ASSEMBLY__

### C Flags ###
CFLAGS      := $(INCLUDES) $(DEPENDFLAGS) $(BASEFLAGS) $(WARNFLAGS)
CFLAGS      += -std=c11

### C++ Flags ###
CXXFLAGS    := $(INCLUDES) $(DEPENDFLAGS) $(BASEFLAGS) $(WARNFLAGS)
CXXFLAGS    += -std=c++14

###
# Rules
###

# Rule to make everything.
all: $(TARGET) $(LIST)

# Rule to remake everything. Does not include clean.
rebuild: all

# Our tools are dumb and won't create directories for us,
# need to create them ourselfs >_>


# Rule to make the listing file.
$(LIST) : $(BUILD)output.elf
	$(ARMGNU)-objdump -d $(BUILD)output.elf > $(LIST)

# Rule to make the image file.
$(TARGET) : $(BUILD)output.elf
	$(ARMGNU)-objcopy $(BUILD)output.elf -O binary $(TARGET) 

# Rule to make the elf file.
$(BUILD)output.elf : $(OBJECTS) $(LINKER)
	$(ARMGNU)-ld --no-undefined $(OBJECTS) -Map $(MAP) -o $(BUILD)output.elf -T $(LINKER)

# Rule to make the assembler object files.
$(BUILD)%.o: $(SOURCE)%.s
	$(ARMGNU)-as -I $(SOURCE) $< -o $@

# C.
$(BUILD)%.o: $(SOURCE)%.c
	$(ARMGNU)-gcc $(CFLAGS) -c $< -o $@  $(CASM_LIST)

# CPP.
$(BUILD)%.o: $(SOURCE)%.cpp
	$(ARMGNU)-g++ $(CXXFLAGS) -c $< -o $@  $(CASM_LIST)
    
# Rule to clean files.
clean : 
	-rm -f $(BUILD)*.o
	-rm -f $(BUILD)*.d
	-rm -f $(BUILD)*.lst
	-rm -f $(BUILD)output.elf
	-rm -f $(TARGET)
	-rm -f $(LIST)
	-rm -f $(MAP)
