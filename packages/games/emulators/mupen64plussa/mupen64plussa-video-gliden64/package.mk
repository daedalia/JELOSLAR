# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plussa-video-gliden64"
PKG_VERSION="a2ecb92e954fdc1dd1130b331935f04381b29e28"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/gonetz/GLideN64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain boost libpng SDL2 SDL2_net zlib freetype nasm:host mupen64plussa-core"
PKG_SHORTDESC="mupen64plus-video-gliden64"
PKG_LONGDESC="Mupen64Plus Standalone GLide64 Video Driver"
PKG_TOOLCHAIN="manual"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

make_target() {
  case ${ARCH} in
    arm|aarch64)
      export HOST_CPU=aarch64
      export USE_GLES=1
      BINUTILS="$(get_build_dir binutils)/.aarch64-libreelec-linux-gnueabi"
      PKG_MAKE_OPTS_TARGET+="-DNOHQ=On -DCRC_ARMV8=On -DEGL=0n -DNEON_OPT=On"
    ;;
  esac
  export APIDIR=$(get_build_dir mupen64plussa-core)/.install_pkg/usr/local/include/mupen64plus
  export SDL_CFLAGS="-I${SYSROOT_PREFIX}/usr/include/SDL2 -D_REENTRANT"
  export SDL_LDLIBS="-lSDL2_net -lSDL2"
  export CROSS_COMPILE="${TARGET_PREFIX}"
  export V=1
  export VC=0
  ./src/getRevision.sh
  cmake ${PKG_MAKE_OPTS_TARGET} -DMUPENPLUSAPI=On -S src -B projects/cmake
  make clean -C projects/cmake
  make -Wno-unused-variable -C projects/cmake
}

makeinstall_target() {
  UPREFIX=${INSTALL}/usr/local
  ULIBDIR=${UPREFIX}/lib
  USHAREDIR=${UPREFIX}/share/mupen64plus
  UPLUGINDIR=${ULIBDIR}/mupen64plus
  mkdir -p ${UPLUGINDIR}
  cp ${PKG_BUILD}/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so ${UPLUGINDIR} 
  #$STRIP ${UPLUGINDIR}/mupen64plus-video-GLideN64.so
  chmod 0644 ${UPLUGINDIR}/mupen64plus-video-GLideN64.so
  mkdir -p ${USHAREDIR}
  cp ${PKG_BUILD}/ini/GLideN64.ini ${USHAREDIR}
  chmod 0644 ${USHAREDIR}/GLideN64.ini
}

