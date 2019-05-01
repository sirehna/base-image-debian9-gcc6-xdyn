FROM sirehna/base-image-debian9-gcc6:latest

RUN apt-get update -yq && \
    apt-get install --no-install-recommends -y \
        cmake \
        make \
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
        libssl-dev  \
        pkg-config \
        autoconf \
        automake \
        libtool \
        curl \
        unzip \
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

RUN git clone https://github.com/google/protobuf.git && \
    cd protobuf \
    git checkout 3.0.x && \
    ./autogen.sh && \
    ./configure "CFLAGS=-fPIC" "CXXFLAGS=-fPIC" && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf protobuf

RUN git clone https://github.com/zeromq/libzmq.git && \
    cd libzmq && \
    git checkout v4.2.2 && \
    mkdir build && \
    cd build && \
    cmake \
        -DWITH_PERF_TOOL=OFF \
        -DZMQ_BUILD_TESTS=OFF \
        -DENABLE_CPACK=OFF \
        -DCMAKE_C_FLAGS="-fPIC" \
        -DCMAKE_CXX_FLAGS="-fPIC" \
        -DCMAKE_BUILD_TYPE=Release \
        .. \
    && \
    make && \
    echo "if(NOT TARGET libzmq) # in case find_package is called multiple times" >> ZeroMQConfig.cmake && \
    echo "  add_library(libzmq SHARED IMPORTED)" >> ZeroMQConfig.cmake && \
    echo "  set_target_properties(libzmq PROPERTIES IMPORTED_LOCATION \${\${PN}_LIBRARY})" >> ZeroMQConfig.cmake && \
    echo "endif(NOT TARGET libzmq)" >> ZeroMQConfig.cmake && \
    echo "" >> ZeroMQConfig.cmake && \
    echo "if(NOT TARGET libzmq-static) # in case find_package is called multiple times" >> ZeroMQConfig.cmake && \
    echo "  add_library(libzmq-static STATIC IMPORTED)" >> ZeroMQConfig.cmake && \
    echo "  set_target_properties(libzmq-static PROPERTIES IMPORTED_LOCATION \${\${PN}_STATIC_LIBRARY})" >> ZeroMQConfig.cmake && \
    echo "endif(NOT TARGET libzmq-static)" >> ZeroMQConfig.cmake && \
    make install && \
    ldconfig && \
    rm -rf libzmq

RUN git clone https://github.com/zeromq/cppzmq.git && \
    cd cppzmq && \
    git checkout v4.2.2 && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_C_FLAGS="-fPIC" \
        -DCMAKE_CXX_FLAGS="-fPIC" \
        .. && \
    make install && \
    cd .. && \
    rm -rf cppzmq


RUN wget https://github.com/sirehna/ssc/releases/download/v8.0.2/ssc_binary_debian9_amd64.deb -O ssc.deb && \
    dpkg -r ssc || true && \
    dpkg -i ssc.deb && \
    rm ssc.deb
