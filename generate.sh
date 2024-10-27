if [[ ! -z "$2" ]]; then
    if [[ ! -z "$1" ]]; then
        if [[ ! -d "${1}/files" ]]; then
            printf "Given script directory path is invalid\n"
        else
            mkdir $2
            cp -r "${1}/files/." $2
            cd $2
            printf "Project ${2} has been generated\n"
        fi
    else
        printf "Provide the path for this script's directory\n"        
    fi
else
    printf "No project name was provided\n"
fi
