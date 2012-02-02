#
# Makefile for the vibrator driver ICs with vibrator driver
#

obj-$(CONFIG_VIBETONZ) += vibrator.o

ifeq ($(CONFIG_MACH_VIPER),y)
vibrator-objs +=motor.o 
else
vibrator-objs +=tspdrv.o 
endif

all:
	@echo "$(MAKE) --no-print-directory -C $(KDIR) SUBDIRS=$(CURDIR) modules"
	@$(MAKE) --no-print-directory -C $(KDIR) \
		SUBDIRS=$(CURDIR) modules

clean:
	rm -f *.o *.ko *.mod.c *.mod.o *~ .*.cmd .*.o.cmd Module.symvers modules.order 

install:
	@$(MAKE) --no-print-directory -C $(KDIR) \
		SUBDIRS=$(CURDIR) modules_install

