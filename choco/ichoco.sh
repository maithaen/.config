# choco install vscode.install -y
# choco install Wget -y
# choco install WhatsApp -y
# choco install winrar -y
# choco install neovim -y
# choco install powershell-core -y
# choco install office365proplus -y
# choco install vmwareworkstation -y
# choco install git.install -y
# choco install GoogleChrome -y
# choco install foxitreader -y
# choco install freecommander-xe.install -y
# choco install Firefox -y
# choco install dropbox -y

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
    start)
        # calculate the column where spinner and status msg will be displayed
        column=${2}
        # display message and position the cursor in $column column
        # echo -ne "${2}"
        echo "${column}"

        # start spinner
        i=1
        sp='\|/-'
        delay=${SPINNER_DELAY:-0.15}

        while :; do
            printf "\b${sp:i++%${#sp}:1}"
            sleep "$delay"
        done
        ;;
    stop)
        if [[ -z ${3} ]]; then
            echo "spinner is not running.."
            exit 1
        fi

        kill "$3" >/dev/null 2>&1

        # inform the user uppon success or failure
        echo -en "\b["
        if [[ $2 -eq 0 ]]; then
            echo -en "${green}${on_success}${nc}"
        else
            echo -en "${red}${on_fail}${nc}"
        fi
        echo -e "]"
        ;;
    *)
        echo "invalid argument, try {start/stop}"
        exit 1
        ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" "$1" "$_sp_pid"
    unset _sp_pid
}

url="https://chocolatey.org/install"

function install {
    echo "[!] This install by chocolatey"
    echo -n "Press [ENTER] to proceed or [CTRL+C] to cancel."
    sleep 3s
    read 
    echo
    if choco --version &>/dev/null; then
        echo "Chocolatey Install"
        
        echo -e "[CTRL+C] To keep install "

        for p in $(< choco_packages.txt); do
            start_spinner "~~ Installing ${p}"
            # echo "install ${p}" &>/dev/null
            choco install "${p}" -y
            stop_spinner $?
        done
    else 
        echo "Chocolatey not install ${url}"
        exit 1
    fi
    echo
    echo "Installation finished."
    echo -e "If Install Fail Don't Forget Run Powershell Admin Mode"
}
install
