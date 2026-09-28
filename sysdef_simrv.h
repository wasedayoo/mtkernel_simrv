#ifndef MTKERNEL_SYSDEF_SIMRV_H
#define MTKERNEL_SYSDEF_SIMRV_H

/*
 * This file is force-included by the SimRV Makefile.  Defining the same
 * include guard as the existing RISC-V core sysdef prevents the CFU-PG RAM
 * map from replacing these target-specific definitions later.
 */
#ifndef __SYS_SYSDEF_DEPEND_CORE_H__
#define __SYS_SYSDEF_DEPEND_CORE_H__

#define MIN_SYS_STACK_SIZE  256
#define DEFAULT_SYS_STKSZ   MIN_SYS_STACK_SIZE

/* Must match the MEMORY region in link.ld. */
#define INTERNAL_RAM_START  0x80010000
#define INTERNAL_RAM_SIZE   0x00ff0000
#define INTERNAL_RAM_END    (INTERNAL_RAM_START + INTERNAL_RAM_SIZE)

#define MIN_TIMER_PERIOD    1
#define MAX_TIMER_PERIOD    50

#define CPU_HAS_PTMR        1
#define CPU_HAS_FPU         0
#define CPU_HAS_DSP         0
#define NUM_COPROCESSOR     0

#define INTPRI_BITWIDTH     3

#define N_INTVEC            32
#define N_SYSVEC            0

#endif /* __SYS_SYSDEF_DEPEND_CORE_H__ */
#endif /* MTKERNEL_SYSDEF_SIMRV_H */
