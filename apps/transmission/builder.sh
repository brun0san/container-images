#!/bin/bash

#-------------------------------------------------------------------------------
# Variable definitions.
#-------------------------------------------------------------------------------
BUILDROOT=${1}
UTILS=${2}

#-------------------------------------------------------------------------------
# Begin logic.
#-------------------------------------------------------------------------------
for UTIL in ${UTILS}; do
  # Get full path from utility requested.
  UTIL=`which ${UTIL}`
  # Get directory path from utility.
  DIR=${UTIL%/*}
  # Check if destination path exists, else create it.
  DST_PATH=${BUILDROOT}/${DIR}
  [ ! -d ${DST_PATH} ] && mkdir -p ${DST_PATH}
  # Copy utility to destination path.
  rsync -avz ${UTIL} ${DST_PATH}/
  # If utility path is a symbolic link, resolve the link and copy to destination.
  if [ -L ${UTIL} ]; then
    UTIL=$(which $(readlink ${UTIL}))
    DIR=${UTIL%/*}
    # We need to set this again as the link could point to anywhere.
    DST_PATH=${BUILDROOT}/${DIR}
    [ ! -d ${DST_PATH} ] && mkdir -p ${DST_PATH}
    rsync -avz ${UTIL} ${DST_PATH}/
  fi
  # Check if utility is a Linux binary.
  if [ "$(grep -q ELF < <(file ${UTIL}) && echo ELF)" = "ELF" ]; then
    # Copy library dependencies to destination path.
    while read LIB; do
      FPATH=${LIB%/*}
      # Check if library path is a link, if so resolve it.
      [ -L ${FPATH} ] && FPATH=`realpath ${FPATH}`
      # Check if destination path exists, else create it.
      DST_PATH=${BUILDROOT}/${FPATH}
      [ ! -d ${DST_PATH} ] && mkdir -p ${DST_PATH}
      # Copy library to destination.
      rsync -avz ${LIB} ${DST_PATH}/
      # Check if library is a link, if so copy the resolved library.
      if [ -L ${LIB} ]; then
        FNAME=`readlink ${LIB}`
        case ${FNAME} in
          "/"*) true;;
          *) FNAME=`realpath ${LIB%/*}/${FNAME}`
        esac
        FPATH=${FNAME%/*}
        # We need to set this again as the link could point to anywhere.
        DST_PATH=${BUILDROOT}/${FPATH}
        [ ! -d ${DST_PATH} ] && mkdir -p ${DST_PATH}
        rsync -avz ${FNAME} ${DST_PATH}/
      fi
      # This is a second-level symlink check, that's as far as we'll go.
      if [ -L ${FNAME} ]; then
        FLINK=`readlink ${FNAME}`
        FPATH=${FLINK%/*}
        # We need to set this again as the link could point to anywhere.
        DST_PATH=${BUILDROOT}/${FPATH}
        [ ! -d ${DST_PATH} ] && mkdir -p ${DST_PATH}
        rsync -avz ${FLINK} ${DST_PATH}/
      fi
    done < <(ldd ${UTIL} | awk '/=>/ {print $3}' | sort -u)
  else
    continue
  fi
done