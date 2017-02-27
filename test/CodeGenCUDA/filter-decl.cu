// RUN: %clang_cc1 -triple %itanium_abi_triple -emit-llvm %s -o - | FileCheck -check-prefix=CHECK-HOST %s
// RUN: %clang_cc1 -triple %itanium_abi_triple -emit-llvm %s -o - -fcuda-is-device | FileCheck -check-prefixes=CHECK-DEVICE,ITANIUM %s
// RUN: %clang_cc1 -triple amdgcn -emit-llvm %s -o - -fcuda-is-device | FileCheck -check-prefixes=CHECK-DEVICE,AMDGCN %s

#include "Inputs/cuda.h"

// This has to be at the top of the file as that's where file-scope
// asm ends up.
// CHECK-HOST: module asm "file scope asm is host only"
// CHECK-DEVICE-NOT: module asm "file scope asm is host only"
__asm__("file scope asm is host only");

// CHECK-HOST: constantdata = internal global
// ITANIUM: constantdata = externally_initialized global
// AMDGCN: constantdata = addrspace(2) externally_initialized global
__constant__ char constantdata[256];

// CHECK-HOST: devicedata = internal global
// ITANIUM: devicedata = externally_initialized global
// AMDGCN: devicedata = addrspace(1) externally_initialized global
__device__ char devicedata[256];

// CHECK-HOST: shareddata = internal global
// ITANIUM: shareddata = global
// AMDGCN: shareddata = addrspace(3) global
__shared__ char shareddata[256];

// CHECK-HOST: hostdata = global
// CHECK-DEVICE-NOT: hostdata = global
char hostdata[256];

// CHECK-HOST: define{{.*}}implicithostonlyfunc
// CHECK-DEVICE-NOT: define{{.*}}implicithostonlyfunc
void implicithostonlyfunc(void) {}

// CHECK-HOST: define{{.*}}explicithostonlyfunc
// CHECK-DEVICE-NOT: define{{.*}}explicithostonlyfunc
__host__ void explicithostonlyfunc(void) {}

// CHECK-HOST-NOT: define{{.*}}deviceonlyfunc
// CHECK-DEVICE: define{{.*}}deviceonlyfunc
__device__ void deviceonlyfunc(void) {}

// CHECK-HOST: define{{.*}}hostdevicefunc
// CHECK-DEVICE: define{{.*}}hostdevicefunc
__host__  __device__ void hostdevicefunc(void) {}

// CHECK-HOST: define{{.*}}globalfunc
// CHECK-DEVICE: define{{.*}}globalfunc
__global__ void globalfunc(void) {}
