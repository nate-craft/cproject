PROJECT=${PWD##*/}
LIB="ctk"
CACHED=false
RUN_TYPE=""
HELP_MESSAGE="
Built via CProject

Flags:
    
    --clean:   removes build directories
    --cached:  builds without downloading the $LIB library
    --run:     runs the built file
    --debug:   runs the built file with valgrind

Examples:

    ./build.sh --clean            (clean build directories)
    ./build.sh --cached           (build without library install)
    ./build.sh --cached --run     (build and run without library install)
    ./build.sh --cached --debug   (build and debug without library install)
    ./build.sh                    (build without running)    

"

build() {
    rm -rf build
    rm -rf out
    mkdir build
    mkdir out
    cd build
    cmake ..
    make 
    cp $PROJECT ../out/
    cd ..
}

libs() {
    git clone "https://github.com/higgsbi/${LIB}.git"
    cd $LIB
    chmod +x build.sh
    ./build.sh --local
    cp -r out/* ../
    cd ..
    rm -rf $LIB
}

for i in "$@"; do
    case $i in
        -h|--help)
            printf "%s" "$HELP_MESSAGE"
            exit 0
            ;;
        -C|--clean)
            rm -rf build
            rm -rf out
            rm -rf include
            rm -rf lib
            printf "Directories have been cleared!\n"
            exit 0
            ;;
        -c|--cached)
            CACHED=true
            shift
            ;;
        -d|--debug)
            RUN_TYPE="debug"
            shift
            ;;
        -r|--run)
            RUN_TYPE="run"
            shift
            ;;
    esac
done

if ! $CACHED || [ ! -d lib ]; then
    libs
fi

build

if [[ $RUN_TYPE == "run" ]]; then
    "${PWD}/out/${PROJECT}" "$@" 
elif [[ $RUN_TYPE == "debug" ]]; then
    valgrind -s --leak-check=full --track-origins=yes "${PWD}/out/${PROJECT}" "$@"
fi
