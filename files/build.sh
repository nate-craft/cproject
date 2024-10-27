project=${PWD##*/}

build() {
    rm -rf build
    mkdir build
    mkdir out
    cd build
    cmake ..
    make 
    cp $project ../out/
    cd ..
}

libs() {
    git clone "https://github.com/higgsbi/normalc.git"
    cd normalc
    chmod +x install.sh
    ./install.sh --local
    cp -r out/* ../
    cd ..
    rm -rf normalc
}

if [[ $1 == "--clean" ]]; then
    rm -rf build
    rm -rf out
    rm -rf include
    rm -rf lib
elif [[ $1 == "--cached" ]]; then
    if [[ -d lib ]]; then
        build
    else
        printf "Library has not been downloaded yet. Run without the '--cached' argument\n"
    fi
else 
    libs
    build
fi
