ARG PLATFORM=linux/amd64

FROM --platform=${PLATFORM} centos:centos7 AS baseimage

# set yum repo with aliyun mirror
ADD aliyun-mirror.repo /etc/yum.repos.d/CentOS-Base.repo
ADD aliyun-epel.repo /etc/yum.repos.d/epel.repo
ADD CentOS-SCLo-rh.repo /etc/yum.repos.d/CentOS-SCLo-rh.repo
RUN yum install -y epel-release

RUN yum clean all && \
    yum makecache

RUN yum upgrade -y

# Install dependencies and tool-kits
RUN yum install -y libpng-devel \
                glib2-devel \
                libjpeg-devel \
                libjpeg-turbo-devel \
                expat-devel \
                zlib-devel \
                giflib-devel \
                libtiff-devel \
                libexif-devel \
                libtool-ltdl-devel \
                libxml2-devel \
                openssl \
                openssl-devel

# Install compile tools
RUN yum install -y  python3 \
                    bzip2 \
                    make \
                    cmake \
                    cmake3 \
                    wget \
                    git \
                    automake \
                    gcc \
                    gcc-c++

RUN yum install -y centos-release-scl && \
    mv /etc/yum.repos.d/CentOS-SCLo-scl-rh.rep{o,o-bak} && \
    mv /etc/yum.repos.d/CentOS-SCLo-scl.rep{o,o-bak} && \
    yum install -y devtoolset-9-gcc \
                    devtoolset-9-gcc-c++ \
                    devtoolset-9-binutils

FROM baseimage AS baselibs
# Set PKG_CONFIG_PATH、LD_LIBRARY_PATH variables
ENV CC=/opt/rh/devtoolset-9/root/usr/bin/gcc
ENV CXX=/opt/rh/devtoolset-9/root/usr/bin/g++
ENV PATH=/usr/local/bin/:/opt/rh/devtoolset-9/root/usr/bin:$PATH
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH

    
# Install libde265
ARG DE265_VERSION=1.0.15
RUN wget https://github.com/strukturag/libde265/releases/download/v1.0.15/libde265-${DE265_VERSION}.tar.gz && \
    tar xzf libde265-${DE265_VERSION}.tar.gz && \
    cd libde265-${DE265_VERSION} && \
    ./configure && \
    make -j4 && \
    make install && \
    cd / && rm -rf libde265-${DE265_VERSION} libde265-${DE265_VERSION}.tar.gz

# Install libx265
ARG X265_VERSION=3.4
RUN wget https://github.com/videolan/x265/archive/refs/tags/${X265_VERSION}.tar.gz && \
    tar xzf ${X265_VERSION}.tar.gz && \
    cd x265-${X265_VERSION}/build/linux && \
    cmake -G "Unix Makefiles" ../../source && \
    make -j4 && \
    make install && \
    cd / && rm -rf x265-${X265_VERSION} ${X265_VERSION}.tar.gz
 
# Install libaom
RUN yum install -y ninja-build yasm
ARG AOM_VERSION=3.9.1
RUN git clone -b v${AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom
RUN cd aom && mkdir -pv build && cd build && cmake3 -G Ninja .. \
    -DCMAKE_INSTALL_PREFIX="/usr/local" \
    -DBUILD_SHARED_LIBS=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -DAOM_TARGET_CPU=generic \
    -DENABLE_DOCS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TESTDATA=0 \
    -DENABLE_TESTS=0 \
    -DENABLE_TOOLS=0 && \
    ninja install && \
    cd / && rm -rf aom

# Install libvccenc
ARG VVENC_VERSION=1.12.0
RUN wget https://github.com/fraunhoferhhi/vvenc/archive/refs/tags/v${VVENC_VERSION}.tar.gz && \
    tar xvf v${VVENC_VERSION}.tar.gz
RUN cd vvenc-${VVENC_VERSION} && \
    cmake3 -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=1 . && \
    make install && \
    cd / && rm -rf vvenc-${VVENC_VERSION} v${VVENC_VERSION}.tar.gz

# Install libvccdec
ARG VVDEC_VERSION=2.3.0
RUN wget https://github.com/fraunhoferhhi/vvdec/archive/refs/tags/v${VVDEC_VERSION}.tar.gz && \
    tar xvf v${VVDEC_VERSION}.tar.gz
RUN cd vvdec-${VVDEC_VERSION}  && \
    cmake3 -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=1 . && \
    make install && \
    cd / && rm -rf vvdec-${VVDEC_VERSION} v${VVDEC_VERSION}.tar.gz

# Install libwebp
RUN yum install -y libtool
ARG LIBWEBP_VERSION=1.4.0
RUN wget https://github.com/webmproject/libwebp/archive/refs/tags/v${LIBWEBP_VERSION}.tar.gz && \
    tar -xzf v${LIBWEBP_VERSION}.tar.gz
RUN cd libwebp-${LIBWEBP_VERSION} && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd / && rm -rf libwebp-${LIBWEBP_VERSION} v${LIBWEBP_VERSION}.tar.gz

FROM baselibs AS libheif
# Install libheif
ARG LIBHEIF_VERSION=1.18.2
RUN wget https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz && \
    tar xzf libheif-${LIBHEIF_VERSION}.tar.gz

RUN cd libheif-${LIBHEIF_VERSION} && \
    cmake3 --preset=release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DWITH_LIBDE265=on \
    -DWITH_X265=on \
    -DWITH_JPEG_ENCODER=on \
    -DWITH_JPEG_DECODER=on \
    -DWITH_AOM_ENCODER=on \
    -DWITH_AOM_DECODER=on \
    -DWITH_VVDEC=on \
    -DWITH_VVENC=on .  && \
    make -j4 && \
    make install && \
    cd / && rm -rf libheif-${LIBHEIF_VERSION} libheif-${LIBHEIF_VERSION}.tar.gz

FROM --platform=${PLATFORM} centos:centos7 AS heif-tool
COPY --from=libheif /usr/local/bin/ /usr/local/bin/
COPY --from=libheif /usr/local/lib/ /usr/local/lib/
COPY --from=libheif /usr/local/lib64/ /usr/local/lib64/
COPY --from=libheif /usr/local/include/ /usr/local/include/
COPY --from=libheif /usr/lib64/ /usr/lib64/

ENV PATH=/usr/local/bin/:$PATH
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH
ENTRYPOINT [ "heif-enc" ]


FROM libheif AS libvips
# Install libvips
ARG LIBVIPS_VERSION=8.15.5
RUN wget https://github.com/libvips/libvips/archive/refs/tags/v${LIBVIPS_VERSION}.tar.gz && \
    tar xzf v${LIBVIPS_VERSION}.tar.gz && \
    rm -rf v${LIBVIPS_VERSION}.tar.gz

# Do not use gcc-9，which will cause vips compile failed
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

RUN yum install -y meson ninja-build && \
    cd libvips-${LIBVIPS_VERSION} && \
    meson setup build --prefix /usr/local && \
    cd build && \
    meson compile && \
    meson test && \
    meson install && \
    /usr/local/bin/vips --vips-config

FROM --platform=${PLATFORM} centos:centos7 AS vips-tool
COPY --from=libvips /usr/local/bin/ /usr/local/bin/
COPY --from=libvips /usr/local/lib/ /usr/local/lib/
COPY --from=libvips /usr/local/lib64/ /usr/local/lib64/
COPY --from=libvips /usr/local/include/ /usr/local/include/
COPY --from=libvips /usr/lib64/ /usr/lib64/

ENV PATH=/usr/local/bin/:$PATH
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH
ENTRYPOINT [ "vips" ]
