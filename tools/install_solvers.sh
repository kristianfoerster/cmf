#!/usr/bin/env bash

CWD=$PWD

CMFDIR=$CWD/$(dirname $0)/..

# Gets and makes the dependencies for the new sparese CVodeIntegrator
export CFLAGS="-fPIC"
KLU_LIB_DIR=$CMFDIR/lib
SND_LIB_DIR=$CMFDIR/lib

function klu {
    KLU_SRC="$KLU_LIB_DIR/src/klu"
    KLU_URL="https://github.com/philippkraft/suitesparse-metis-for-windows"
    mkdir -p $KLU_SRC
    git clone $KLU_URL $KLU_SRC
    rm -rf $KLU_SRC/.git
    mkdir -p $KLU_SRC/build
    cd $KLU_SRC/build
    cmake .. -DCMAKE_INSTALL_PREFIX=$KLU_LIB_DIR -DBUILD_METIS=OFF
    cd $CWD

}
function klu_alt {
    # Get KLU
    git clone https://github.com/PetterS/SuiteSparse ~/suitesparse

    # Make KLU

    mkdir -p ${KLUINSTALL_DIR}/lib
    mkdir -p ${KLUINSTALL_DIR}/include
    mkdir -p ${KLUINSTALL_DIR}/doc

    cd $TOOLSDIR/suitesparse


    make $MAKE_OPTIONS
    make install \
        INSTALL_LIB=${KLUINSTALL_DIR}/lib \
        INSTALL_INCLUDE=${KLUINSTALL_DIR}/include \
        INSTALL_DOC=${KLUINSTALL_DIR}/doc

    cd $TOOLSDIR
}

function sundials {
    # Get sundials
    SND_SRC="$SND_LIB_DIR/src/sundials"
    SND_URL="https://github.com/philippkraft/sundials"
    mkdir -p $SND_SRC
    echo "Create $SND_SRC directory"
    git clone $SND_URL $SND_SRC
    rm -rf $SND_SRC/.git
    mkdir -p $SND_SRC/build
    cd $SND_SRC/build

    cmake .. \
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true \
        -DBLAS_ENABLE=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_INSTALL_PREFIX=${SND_LIB_DIR} \
        -DEXAMPLES_INSTALL=ON \
        -DKLU_ENABLE=ON \
        -DKLU_LIBRARY_DIR=${KLU_LIB_DIR}/lib \
        -DKLU_INCLUDE_DIR=${KLU_LIB_DIR}/include \
        -DOPENMP_ENABLE=ON \
        -DBUILD_ARKODE=OFF -DBUILD_CVODES=OFF -DBUILD_IDA=OFF -DBUILD_IDAS=OFF -DBUILD_KINSOL=OFF


    make $MAKE_OPTIONS
    make install
    
    cd $CWD
}

echo "Calling from: " $CWD
echo "Running in: " $TOOLSDIR
echo "Installing KLU into: " $KLUINSTALL_DIR
echo "Installing SUNDIALS into: " $SUNDIALS_DIR

if [[ "$1" == "help" ]]; then
    exit 0
fi
    
if [[ "$1" != "sundials" ]]; then
    klu
fi

if [[ "$1" != "klu" ]]; then
    sundials
fi
    