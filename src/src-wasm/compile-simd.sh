#!/bin/bash
set -x
source ./version.sh

NOWPATH=`pwd`
#FFMPEG_DIR="${NOWPATH}/../ffmpeg-3.4.6"
FFMPEG_DIR="${NOWPATH}/../FFmpeg-n4.2.3"
#FFMPEG_DIR="${NOWPATH}/../FFmpeg-n4.3.1"
LIB_PATH="${FFMPEG_DIR}/lib"
MEM_SIZE=`expr 1024 \* 1024 \* 1024`
#MEM_SIZE=`expr 128 \* 1024 \* 1024`
OUTPUT="${NOWPATH}/output"

ENTRY_PATH="${NOWPATH}/../../VideoMissilePlayer"
ENTRY_TS_PATH="${NOWPATH}/../../VideoMissileTsDemuxer"
FNAME_PRE="missile-simd128"
FNAME="${FNAME_PRE}-${VERSION}"

rm $OUTPUT/*

#
# build
#
# emcc web.c process.c about.c \
# ${LIB_PATH}/libavformat.bc \
# ${LIB_PATH}/libavutil.bc \
#${LIB_PATH}/libswresample.bc \

#${LIB_PATH}/libswscale.bc \
#${LIB_PATH}/libswresample.bc \
#
# ${LIB_PATH}/libswscale.bc \
emcc web_wasm.c \
about.c \
seek_desc.c \
sniff_stream.c \
sniff_httpflv.c \
vcodec.c \
ts_parser.c \
utils/ts_utils.c \
utils/secret.c \
utils/tools.c \
utils/md5.c \
utils/common_string.c \
utils/av_err_code.c \
utils/common_av.c \
decoder/avc.c \
decoder/hevc.c \
decoder/aac.c \
${LIB_PATH}/libavformat.bc \
${LIB_PATH}/libswscale.bc \
${LIB_PATH}/libavcodec.bc \
${LIB_PATH}/libavutil.bc \
-I${FFMPEG_DIR} \
-msimd128 -Os -s WASM=1 \
-s FETCH=1 \
-o ${OUTPUT}/${FNAME}.html \
-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap", "addFunction", "removeFunction"]' \
-s ALLOW_MEMORY_GROWTH=1 \
-s RESERVED_FUNCTION_POINTERS=35 \
-s ALLOW_TABLE_GROWTH \
-s PTHREAD_POOL_SIZE=5 \
-s TOTAL_MEMORY=${MEM_SIZE} \
-s MEMFS_APPEND_TO_TYPED_ARRAYS=1 \
-s ASSERTIONS=3
#-Werror

# -s PTHREAD_POOL_SIZE=10 \
# -s RESERVED_FUNCTION_POINTERS=14 \

# https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#interacting-with-code-call-function-pointers-from-c

#-s SAFE_HEAP=1
#-s FORCE_FILESYSTEM=1

MISSILE_JS=${OUTPUT}/${FNAME}.js

#echo -e "module.exports = Module" >> $MISSILE_JS
echo -e "var ENVIRONMENT_IS_PTHREAD = true;" > "${MISSILE_JS}.head"
cat $MISSILE_JS >>  "${MISSILE_JS}.head"
mv "${MISSILE_JS}.head" $MISSILE_JS

MISSILE_WASM=${OUTPUT}/${FNAME}.wasm

#rm $ENTRY_PATH/*
cp $MISSILE_WASM ${ENTRY_PATH}/src/decoder
cp $MISSILE_JS ${ENTRY_PATH}/src/decoder

cd ${ENTRY_PATH}/src/decoder
rm ${FNAME_PRE}.js
ln -s ${MISSILE_JS} ${FNAME_PRE}.js

#cp $MISSILE_WASM ${ENTRY_TS_PATH}/demuxer
#cp $MISSILE_JS ${ENTRY_TS_PATH}/demuxer

