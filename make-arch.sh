#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

make clean
mkdir -p cmake
for arch in "$@"; do
	cat > config.mak <<- EOF
		TARGET = $arch-linux-musl
		BINUTILS_VER = 2.44
		GCC_VER = 14.2.0
		MUSL_VER = 1.2.5
		GMP_VER = 6.3.0
		MPC_VER = 1.3.1
		MPFR_VER = 4.2.2
		ISL_VER = 0.27
		LINUX_VER = 6.12.48
	EOF
	make -j$(nproc)
	make install
	cat > cmake/toolchain-$arch-musl-clang.cmake <<- EOF
		set(CMAKE_SYSTEM_NAME Linux)
		set(CMAKE_SYSTEM_PROCESSOR $arch)

		set(CMAKE_C_COMPILER   "clang")
		set(CMAKE_CXX_COMPILER "clang++")

		set(CMAKE_SYSROOT "/opt/musl-cross-make/$arch-linux-musl")

		set(CMAKE_C_FLAGS   "--target=$arch-linux-musl --gcc-toolchain=/opt/musl-cross-make -v")
		set(CMAKE_CXX_FLAGS "--target=$arch-linux-musl --gcc-toolchain=/opt/musl-cross-make -v")

		set(CMAKE_EXE_LINKER_FLAGS "-fuse-ld=lld")
	EOF
done
