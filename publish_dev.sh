#!/bin/bash

#publish_dev branch remote

sExecCurrentDir=$(cd "$(dirname "$0")"; /bin/pwd)
sExecRootDir=`/bin/readlink -f $sExecCurrentDir/`

source $sExecRootDir'/inc/initial_dev.sh'

# 确保$CodeDir中是正确的代码库
if [ -d $sExecRepoCodeDir ]; then #代码文件夹存在, 查看代码库是否正确
    showDebug $sExecRepoCodeDir' exists, we will check repo.'
    cd $sExecRepoCodeDir
    checkRepo $sRepoType $sRepoUrl
    if [ 0 -eq $? ]; then
        showError 'we get a wrong repo.';
    fi
    fetchRepo $sRepoType
else #代码文件夹不存在, 签出代码
    showDebug $sRemote' does not exist, we will get it from remote.'
    getRepo $sRepoType $sRepoUrl $sExecRepoCodeDir
fi
cd $sExecRepoCodeDir

#切换到对应的branch
switchBranch $sRepoType $sBranch
rebaseBranch $sRepoType $sBranch

# 从仓库导出上线代码包
sCodeTarFilePath="$sExecCodeTarDir"'/'"$sRemote"'.tar.gz'
exportCodeTar $sRepoType $sRepoMaster $sCodeTarFilePath
sDestDir=$sDestDir'/'$sRemote

# 根据$sAnsibleFiles, 执行对应的发布操作
if [ -n "$sAnsibleFiles" ]; then
    callAnsible "$sAnsibleFiles" $sRemote $sCodeTarFilePath
fi
showInfo 'our job here is done.'