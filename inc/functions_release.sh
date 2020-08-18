#release functions

#show help we need
function showHelp() {
    /bin/echo 'Usage: '`basename $1`' -p repo [-r [-v version]] [-l]'
    /bin/echo `basename $1 .sh`' repo in the newest or reverse last version or specific version'
    /bin/echo 'we currently support git'
    /bin/echo '  -p repo'
    /bin/echo '  -r reverse'
    /bin/echo '  -v specific version'
    /bin/echo '  -l list old version'
    /bin/echo '  -h show this help'
    exit 0
}

#parse what todo
function parseBin(){
    sReverse='no'
    sReverseVersion='last'
    while getopts 'p:v:hlr' arg; do
        case $arg in
            v) sReverseVersion=$OPTARG
                ;;
            p) sRepoName=$OPTARG
                ;;
            l) sList='yes'
                ;;
            r) sReverse='yes'
                ;;
            h) showHelp $0
                ;;
            ?) showHelp $0
                ;;
        esac
    done
	
    showDebug 'repo name we got was: '"$sRepoName"'.'
    showDebug 'whether reverse we got was: '"$sReverse"'.'
    showDebug 'version we got was: '"$sReverseVersion"'.'

    if [ -z $sRepoName ]; then
        showHelp $0
    fi
    
    sExecRepoDir=$sExecRepoRootDir'/'$sRepoName
    showDebug 'repo dir is: '"$sExecRepoDir"'.'
    sExecVersionFile=$sExecVersionDir'/'$sRepoName'.ver'
    showDebug 'version file is: '"$sExecVersionFile"'.'
        	
    if [ ! -d $sExecRepoDir ]; then
        showError 'repo('"$sRepoName"') does not exist.'
    fi
    if [ ! -f $sExecVersionFile ]; then
        touch $sExecVersionFile
    fi
}