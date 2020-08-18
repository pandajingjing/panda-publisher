#dev functions

#show help we need
function showHelp() {
    /bin/echo 'Usage: '`basename $1`' -b branch -r remote'
    /bin/echo `basename $1 .sh`' repo to remote on specific branch'
    /bin/echo 'we currently support git'
    /bin/echo '  -b branch'
    /bin/echo '  -r remote'
    /bin/echo '  -h show this help'
    exit 0
}

#parse what todo
function parseBin(){
    while getopts 'b:r:h' arg; do
        case $arg in
            b) sBranch=$OPTARG
                ;;
            r) sRemote=$OPTARG
                ;;
            h) showHelp $0
                ;;
            ?) showHelp $0
                ;;
        esac
    done
	
    showDebug 'branch we got was: '"$sBranch"'.'
    showDebug 'remote we got was: '"$sRemote"'.'

    if [ -z $sBranch ] || [ -z $sRemote ]; then
        showHelp $0
    fi
}