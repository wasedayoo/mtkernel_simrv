
# micro T-Kernel本体
KERNEL_SOURCES := \
	$(wildcard ../mtkernel_cfu/kernel/tkernel/*.c) \
	$(wildcard ../mtkernel_cfu/kernel/tstdlib/*.c) \
	../mtkernel_cfu/kernel/sysinit/sysinit.c \
	../mtkernel_cfu/kernel/inittask/inittask.c

# 既存のRISC-V CPU依存部とボード初期化
RISCV_SOURCES := \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/startup.S \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/dispatch.S \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/reset_hdl.c \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/cpu_cntl.c \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/exc_hdr.c \
	../mtkernel_cfu/kernel/sysdepend/cpu/core/riscv/interrupt.c \
	$(wildcard ../mtkernel_cfu/kernel/sysdepend/iote_riscv/*.c)

# T-Monitorライブラリ
TMONITOR_SOURCES := \
	../mtkernel_cfu/lib/libtm/libtm.c \
	../mtkernel_cfu/lib/libtm/libtm_printf.c \
	../mtkernel_cfu/lib/libtm/sysdepend/iote_riscv/tm_com.c

# 今回使用するアプリケーション
APP_SOURCE := ../mtkernel_cfu/kernel/usermain/usermain_simrv.c

SOURCES := $(KERNEL_SOURCES) $(RISCV_SOURCES) $(TMONITOR_SOURCES) $(APP_SOURCE)

.PHONY: all run run-ca run-cli inspect clean

all: build/mtkernel-simrv.elf build/mtkernel-simrv.dump

# micro T-Kernelとusermain_simrv.cをまとめてRV32 ELFへリンクする。
build/mtkernel-simrv.elf: $(SOURCES) link.ld sysdef_simrv.h
	mkdir -p build
	riscv64-unknown-elf-gcc \
		-D_IOTE_RISCV_ \
		-DCFU_MTKERNEL \
		-DCFU_MTKERNEL_TIMER_HZ=10000000UL \
		-include sysdef_simrv.h \
		-I../mtkernel_cfu/include \
		-I../mtkernel_cfu/config \
		-I../mtkernel_cfu/kernel/knlinc \
		-I../mtkernel_cfu/kernel/sysdepend \
		-Os -g -std=gnu17 \
		-march=rv32im_zicsr -mabi=ilp32 \
		-ffreestanding -fno-builtin \
		-ffunction-sections -fdata-sections \
		-mno-relax -nostdlib \
		-Wl,--gc-sections \
		-Wl,--build-id=none \
		-Wl,-Map,build/mtkernel-simrv.map \
		-Tlink.ld \
		-o build/mtkernel-simrv.elf \
		$(SOURCES) \
		-lc -lgcc

build/mtkernel-simrv.dump: build/mtkernel-simrv.elf
	riscv64-unknown-elf-objdump -D -S \
		build/mtkernel-simrv.elf > build/mtkernel-simrv.dump

# 高速な命令精度モードでTUI実行
run: build/mtkernel-simrv.elf
	../SimRV/build/rv32-release/SimRV \
		-b -m build/mtkernel-simrv.elf \
		--misa rv32imac --ia --tui

# サイクル精度モードでTUI実行
run-ca: build/mtkernel-simrv.elf
	../SimRV/build/rv32-release/SimRV \
		-b -m build/mtkernel-simrv.elf \
		--misa rv32imac --ca --tui

# TUIなしで100万命令実行
run-cli: build/mtkernel-simrv.elf
	../SimRV/build/rv32-release/SimRV \
		-b -m build/mtkernel-simrv.elf \
		--misa rv32imac --ia --cli --steps 1000000

inspect: build/mtkernel-simrv.elf
	riscv64-unknown-elf-readelf -h -l -S build/mtkernel-simrv.elf

clean:
	rm -rf build
