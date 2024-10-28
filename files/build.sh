project=${PWD##*/}

build() {
    rm -rf build
    rm -rf out
    mkdir build
    mkdir out
    cd build
    cmake ..
    make 
    cp $project ../out/
    cd ..

    if [[ $1 == "--run" ]] || [[ $2 == "--run" ]]; then
        "out/${project}"
    elif [[ $1 == "--debug" ]] || [[ $2 == "--debug" ]]; then
        valgrind -s --leak-check=full --track-origins=yes "out/${project}"
    fi
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

if [[ $1 == "--help" ]]; then
    printf "
Built via CProject
    
Flags:
    
    --clean:   removes build directories
    --cached:  builds without downloading the normalc library
    --run:     runs the built file
    --debug:   runs the built file with valgrind

Examples:

    ./build.sh --clean            (clean build directories)
    ./build.sh --cached           (build without library install)
    ./build.sh --cached --run     (build and run without library install)
    ./build.sh --cached --debug   (build and debug without library install)
    ./build.sh                    (build without running)    

";
elif [[ $1 == "--clean" ]]; then
    rm -rf build
    rm -rf out
    rm -rf include
    rm -rf lib
elif [[ $1 == "--cached" ]]; then
    if [[ -d lib ]]; then
        build $1 $2
    else
        printf "Library has not been downloaded yet. Run without the '--cached' argument\n"
    fi
else 
    libs
    build $1 $2
fi
