#main functions

#show some messages
function showMessage(){
    _sMessage=`/bin/date +"%Y-%m-%d %H:%M:%S"`'('"$1"'): '"$2"
    case $1 in
        error)
        /bin/echo -e "\033[31m$_sMessage\033[0m"
        ;;
        warn)
        /bin/echo -e "\033[33m$_sMessage\033[0m"
        ;;
        debug)
        /bin/echo -e "\033[37m$_sMessage\033[0m"
        ;;
        *)
        /bin/echo "$_sMessage"
        ;;
    esac
}

#show info message
function showInfo(){
    showMessage 'info' "$1"
}

#show warning message
function showWarning(){
    showMessage 'warn' "$1"
}

#show error message
function showError(){
    showMessage 'error' "$1"
    exit 1
}

#show debug message
function showDebug(){
    if [ $iDebug -eq 1 ]; then
        showMessage 'debug' "$1"
    elif [ $iDebug -eq 2 ]; then
        showMessage 'debug' "$1"
        read -t 10 -p 'press enter to continue...'
    fi
}

#create dir
function createDir(){
    showDebug 'create dir: '"$1"' start.'
    if [ -d $1 ]; then
        showDebug 'dir '"$1"' is exists.'
        if [ ! -z $2 ]; then
            showDebug "$1"' will be cleaned.'
            /bin/rm -rf "$1"
            /bin/mkdir -p "$1"
        fi
    else
        /bin/mkdir -p "$1"
    fi
    showDebug 'create dir: '"$1"' successfully.'
}

#load repo file
function loadRepoFile(){
    _sExecRepoFile=$sExecRepoDir'/'$1
    if [ -f $_sExecRepoFile ];then
        showDebug 'load repo '"$1"' file: '"$_sExecRepoFile"'.'
        source $_sExecRepoFile
    else
        showError "$_sExecRepoFile"' does not exist.'
    fi
}

#get repo
function getRepo(){
    _sRepoType=$1
    _sRepoUrl=$2
    _sCodeDir=$3
    showInfo 'get repo from remote.'
    case "$_sRepoType" in
        git)
            showDebug 'git clone from '"$_sRepoUrl"' to '"$_sCodeDir"'.'
            $sExecLocalGit clone -q $_sRepoUrl $_sCodeDir
            ;;
        ?) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not get repo from remote.'
    fi
}

#check repo whether its right repo
function checkRepo(){
    _sRepoType=$1
    _sRepoUrl=$2
    showInfo 'check repo whether its right repo.'
    case "$_sRepoType" in
        git)
            showDebug 'git remote get-url origin.'
            _sCurrentUrl=`$sExecLocalGit remote get-url origin`
            if [ $_sCurrentUrl = $_sRepoUrl ]; then
                return 1
            else
                return 0
            fi
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac 
}

#fetch repo
function fetchRepo(){
    _sRepoType=$1
    showInfo 'fetch repo from remote.'
    case "$_sRepoType" in
        git)
            showDebug 'git fetch origin.'
            $sExecLocalGit fetch -q origin
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not fetch repo from remote.'
    fi
}

#check branch
function _checkBranch(){
    _sRepoType=$1
    _sBranch=$2
    showDebug 'check branch status.'
    case "$_sRepoType" in
        git)
            $sExecLocalGit branch | /bin/grep "$_sBranch" > /dev/null
            if [ 0 -eq $? ]; then
                showDebug 'we got local branch('"$_sBranch"').'
                $sExecLocalGit branch | /bin/grep "* $_sBranch" > /dev/null
                if [ 0 -eq $? ]; then
                    showDebug 'we got current branch.'
                    return 2
                else
                    showDebug 'we have local branch, but not current branch.'
                    return 1
                fi
            else #we dont get local branch
                showDebug 'we dont get local branch('"$_sBranch"').'
                return 0
            fi
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
}

#switch branch
function switchBranch(){
    _sRepoType=$1
    _sBranch=$2
    showInfo 'switch branch to '"$_sBranch"'.'
    case "$_sRepoType" in
        git)
            _checkBranch $_sRepoType $_sBranch
            _iReturn=$?
            if [ 2 -eq $_iReturn ]; then
                showDebug 'we do nothing.'
            elif [ 1 -eq $_iReturn ]; then
                showDebug 'git checkout '"$_sBranch"' from local.'
                $sExecLocalGit checkout -q "$_sBranch"
            else
                showDebug 'git checkout '"$_sBranch"' from origin.'
                $sExecLocalGit checkout -q "$_sBranch"
            fi
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not switch branch to '"$_sBranch"'.'
    fi
}

#rebase branch
function rebaseBranch(){
    _sRepoType=$1
    _sBranch=$2
    showInfo 'rebase branch from '"$_sBranch"'.'
    case "$_sRepoType" in
        git)
            showDebug 'git rebase origin/'"$_sBranch"'.'
            $sExecLocalGit rebase -q "origin/$_sBranch"
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not rebase branch from '"$_sBranch"'.'
    fi
}

#merge branch
function mergeBranch(){
    _sRepoType=$1
    _sBranch=$2
    _sComment=$3
    showInfo 'merge branch from '"$_sBranch"'.'
    case "$_sRepoType" in
        git)
            showDebug 'git merge '"$_sBranch"' with comment: '"$_sComment"'.'
            $sExecLocalGit merge -q --no-ff $_sBranch -m "$_sComment"
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not merge branch from '"$_sBranch"'.'
    fi
}

#push branch
function pushBranch(){
    _sRepoType=$1
    _sBranch=$2
    showInfo 'push branch('"$_sBranch"') to remote.'
    case "$_sRepoType" in
        git)
            showDebug 'git push origin '"$_sBranch:$_sBranch"'.'
            $sExecLocalGit push -q origin "$_sBranch:$_sBranch"
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not push branch('"$_sBranch"') to remote.'
    fi
}

#tag branch
function tagBranch(){
    _sRepoType=$1
    _sTag=$2
    _sBranch=$3
    showInfo 'make tag('"$_sTag"') on '"$_sBranch"'.'
    case "$_sRepoType" in
        git)
            showDebug 'git tag '"$_sTag"'.'
            $sExecLocalGit tag "$_sTag"
            $sExecLocalGit push -q origin "$_sBranch:$_sBranch" --tags
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not make tag ('"$_sTag"') on '"$_sBranch"'.'
    fi
}

#export code tar
function exportCodeTar(){
    _sRepoType=$1
    _sBranch=$2
    _sCodeTarFilePath=$3
    showInfo 'export '"$_sBranch"' into '"$_sCodeTarFilePath"'.'
    case "$_sRepoType" in
        git)
            showDebug 'git archive '"$_sBranch"' into '"$_sCodeTarFilePath"'.'
            $sExecLocalGit archive --format 'tar.gz' --output "$_sCodeTarFilePath" $_sBranch
            ;;
        *) showError 'unsupport repo type: '"$_sRepoType"'.'
            ;;
    esac
    if [ 0 -ne $? ]; then
        showError 'can not export '"$_sBranch"' into '"$_sCodeTarFilePath"'.'
    fi
}

#call ansible
function callAnsible(){
    _sAnsibleFiles=$1
    _sVersion=$2
    _sCodeTarFilePath=$3
    _sYamlParam="sDeployServer=$sDeployServer sDeployUser=$sDeployUser sDeployGroup=$sDeployGroup sDestDir=$sDestDir sVersion=$_sVersion sCodeTarFilePath=$_sCodeTarFilePath sLoader=$sLoader sExecRemotePhp=$sExecRemotePhp"
    for _sExecConfigName in $sRepoConfigVars
    do
        eval _sExecConfigValue="\$$_sExecConfigName"
        _sYamlParam=$_sYamlParam' '$_sExecConfigName'='$_sExecConfigValue
    done
    for _sAnsibleFile in $_sAnsibleFiles
    do
        #echo 'a'
        if [ $iDebug -eq 0 ]; then
            $sExecAnsiblePlaybook -i "$sExecRootDir"/hosts -e "$_sYamlParam" "$sExecRootDir"/yaml/"$_sAnsibleFile".yaml
        else
            $sExecAnsiblePlaybook -v -i "$sExecRootDir"/hosts -e "$_sYamlParam" "$sExecRootDir"/yaml/"$_sAnsibleFile".yaml
        fi
    done
}