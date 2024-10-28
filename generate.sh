if [[ $1 == "--help" ]] then
    printf "CProject: generate C projects quickly\n\nUsage: project project_name cproject_path\n"
    exit 1
fi

if [[ -z "$2" ]]; then
    printf "No project name was provided\n"
    exit 1
fi

if [[ -z "$1" ]]; then
    printf "Provide the path for this script's directory\n"        
    exit 1
fi 

if [[ ! -d "${1}/files" ]]; then
    printf "Given script directory path is invalid\n"
    exit 1
fi 

mkdir $2
cp -r "${1}/files/." $2
cd $2
printf "Project ${2} has been generated\n"
