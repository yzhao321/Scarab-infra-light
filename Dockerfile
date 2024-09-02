# Use the Ubuntu 20.04 base image
FROM ubuntu:20.04

# Avoid interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install basic packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python2 \
    git \
    sudo \
    wget \
    cmake \
    binutils \
    libunwind-dev \
    libboost-dev \
    zlib1g-dev \
    libsnappy-dev \
    liblz4-dev \
    g++-9 \
    g++-9-multilib \
    doxygen \
    libconfig++-dev \
    vim \
    bc \
    unzip \
    jq \
    gosu && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 1

# Set the enviroment dependency directory
ENV env_dir="/env_dir"
RUN mkdir -p $env_dir && chmod -R 755 $env_dir
WORKDIR $env_dir

# Build DynamoRIO from source
RUN cd $env_dir && \
    git clone --recursive https://github.com/DynamoRIO/dynamorio.git && \
    cd dynamorio && \
    git reset --hard release_10.0.0 && \
    mkdir build && cd build && \
    cmake .. && make -j 40 && \
    mkdir $env_dir/dynamorio/package && \
    cd $env_dir/dynamorio/package && \
    ctest -V -S ../make/package.cmake,build=1\;no32
ENV DYNAMORIO_HOME=$env_dir/dynamorio/package/build_release-64/

# Install Pin
RUN cd $env_dir && \
    wget -nc https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz && \
    tar -xzvf pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz
ENV PIN_ROOT=$env_dir/pin-3.15-98253-gb56e429b1-gcc-linux
ENV LD_LIBRARY_PATH=$env_dir/pin-3.15-98253-gb56e429b1-gcc-linux/extras/xed-intel64/lib
ENV LD_LIBRARY_PATH=$env_dir/pin-3.15-98253-gb56e429b1-gcc-linux/intel64/runtime/pincrt:$LD_LIBRARY_PATH

# Set environment variables for Scarab
ENV SCARAB_ENABLE_PT_MEMTRACE=1

# Enable Docker BuildKit for better build performance
ENV DOCKER_BUILDKIT=1
ENV COMPOSE_DOCKER_CLI_BUILD=1

# Copy config.json into the container
COPY config.json /tmp/config.json

# Read the username from config.json and create a new user with a home directory
RUN USER_NAME=$(jq -r '.USER_NAME' /tmp/config.json) && \
    useradd -m -s /bin/bash "$USER_NAME"

# Specify the command to run when the container starts
CMD ["bash"]
