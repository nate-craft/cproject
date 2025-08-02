#!/bin/sh

BOLD=$(printf '\033[1m')
ITALIC=$(printf '\033[3m')
RESET=$(printf '\033[0m')

PROJECT=${PWD##*/}
LIB="ctk"
RELEASE=false
CACHED=false
SYSTEM_INSTALL=false
RUN_TYPE=""

HELP_MESSAGE="
${BOLD}$(basename "$PWD")${RESET} - built via cproject

${BOLD}Flags:${RESET}
  [ ${ITALIC}--clean${RESET}  | ${ITALIC}-C${RESET} ]:   removes build directories
  [ ${ITALIC}--cached${RESET} | ${ITALIC}-c${RESET} ]:   builds without downloading the ${LIB} library
  [ ${ITALIC}--run${RESET}    | ${ITALIC}-r${RESET} ]:   runs the built file
  [ ${ITALIC}--debug${RESET}  | ${ITALIC}-d${RESET} ]:   runs the built file with valgrind
  [ ${ITALIC}--release${RESET}| ${ITALIC}-R${RESET} ]:   builds with O3 compiler flags
  [ ${ITALIC}--system${RESET} | ${ITALIC}-s${RESET} ]:   installs executable system-wide
  [ ${ITALIC}--delete${RESET} | ${ITALIC}-D${RESET} ]:   uninstalls executable system-wide

${BOLD}Examples:${RESET}
  ./build.sh --clean                   (clean build directories)
  ./build.sh --cached                  (build without library install)
  ./build.sh --release                 (build without library install with O3 option)
  ./build.sh --cached --run            (build and run without library install)
  ./build.sh --cached --run --release  (build and run without library install with O3 option)
  ./build.sh --cached --debug          (build and debug without library install)
  ./build.sh --system                  (build and install system-wide)
  ./build.sh --delete                  (uninstall executable system-wide)
  ./build.sh                           (build without running)

"

build() {
    rm -rf build
    rm -rf out
    mkdir build
    mkdir out
	(
		cd build || exit 1

		if [ "$RELEASE" = "true" ]; then
			cmake -DCMAKE_BUILD_TYPE=Release ..
		else
			cmake -DCMAKE_BUILD_TYPE=Debug ..
		fi
		if [ "$SYSTEM_INSTALL" = "true" ]; then
			sudo make install
		else
			make
			cp "$PROJECT" ../out/
		fi
	)    
}

libs() {
    git clone "https://github.com/nate-craft/${LIB}.git"
	(
		cd "$LIB" || exit 1
		chmod +x build.sh
		./build.sh --local
		cp -r out/* ../
	)
	rm -rf "$LIB"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            printf "%s" "$HELP_MESSAGE"
            exit 0
            ;;
        -C|--clean)
            rm -rf build
            rm -rf out
            rm -rf include
            rm -rf lib
            printf 'Directories have been cleared!\n'
            exit 0
            ;;
        -c|--cached)
            CACHED=true
            shift
            ;;
        -d|--debug)
            RUN_TYPE="debug"
            RELEASE=false
            shift
            ;;
        -r|--run)
            RUN_TYPE="run"
            shift
            ;;
        -R|--release)
            RELEASE=true
            shift
            ;;
        -S|--system)
            SYSTEM_INSTALL=true
            shift
            ;;
        -D|--delete)
            sudo rm -I /usr/local/bin/"$PROJECT"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if ! "$CACHED" || [ ! -d lib ]; then
    libs
fi

build

if [ "$RUN_TYPE" = "run" ]; then
    "${PWD}/out/${PROJECT}" "$@"
elif [ "$RUN_TYPE" = "debug" ]; then
    valgrind -s --leak-check=full --track-origins=yes "${PWD}/out/${PROJECT}" "$@"
fi

