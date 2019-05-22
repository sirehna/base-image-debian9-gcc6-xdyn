FROM sirehna/base-image-debian9-gcc6:latest

RUN echo "deb http://deb.debian.org/debian stretch-backports main" >>  /etc/apt/sources.list && \
    apt-get update -yq && \
    apt-get install --no-install-recommends -y \
        ninja-build \
        git \
        wget \
        python3-pandas \
        python3-pip \
        python3-matplotlib \
        python3-tornado \
        pandoc \
        texlive-fonts-recommended \
        texlive-latex-extra \
        lmodern \
        inkscape \
        doxygen \
        dvipng \
        libssl-dev \
        pkg-config \
        autoconf \
        automake \
        libtool \
        curl \
        unzip \        
        libc-ares-dev \
        libssl-dev  && \    
    apt-get -t stretch-backports install --yes --no-install-recommends \
        libgrpc++-dev \
        libgrpc++1 \
        libgrpc-dev \
        libgrpc6 \
        libprotobuf-dev \
        libprotoc-dev \
        protobuf-compiler-grpc \
        && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists

WORKDIR /opt

ENV HDF5_INSTALL=/usr/local/hdf5
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.12/src/hdf5-1.8.12.tar.gz -O hdf5_source.tar.gz && \
    mkdir -p HDF5_SRC && \
    tar -xf hdf5_source.tar.gz --strip 1 -C HDF5_SRC && \
    mkdir -p HDF5_build && \
    cd HDF5_build && \
    cmake -G"Unix Makefiles" \
         -DCMAKE_BUILD_TYPE:STRING=Release \
         -DCMAKE_INSTALL_PREFIX:PATH=${HDF5_INSTALL} \
         -DBUILD_SHARED_LIBS:BOOL=OFF \
         -DBUILD_TESTING:BOOL=OFF \
         -DHDF5_BUILD_TOOLS:BOOL=OFF \
         -DHDF5_BUILD_EXAMPLES:BOOL=OFF \
         -DHDF5_BUILD_HL_LIB:BOOL=ON \
         -DHDF5_BUILD_CPP_LIB:BOOL=ON \
         -DHDF5_BUILD_FORTRAN:BOOL=OFF \
         -DCMAKE_C_FLAGS="-fPIC" \
         -DCMAKE_CXX_FLAGS="-fPIC" \
         ../HDF5_SRC && \
    make install && \
    cd .. && \
    rm -rf hdf5_source.tar.gz HDF5_SRC HDF5_build

RUN cd /opt && \
    git clone https://github.com/garrison/eigen3-hdf5 && \
    cd eigen3-hdf5 && \
    git checkout 2c782414251e75a2de9b0441c349f5f18fe929a2

RUN wget https://github.com/sirehna/ssc/releases/download/v8.0.3/ssc_binary_debian9_amd64.deb -O ssc.deb && \
    dpkg -r ssc || true && \
    dpkg -i ssc.deb && \
    rm ssc.deb
