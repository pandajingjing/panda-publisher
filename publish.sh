#!/bin/bash

#publish repo

sExecCurrentDir=$(cd "$(dirname "$0")"; /bin/pwd)
sExecRootDir=`/bin/readlink -f $sExecCurrentDir/`

source $sExecRootDir'/inc/initial.sh'

if [ 'yesx' = "$sList"'x' ]; then
    showInfo 'show repo version list.'
    /bin/cat $sExecVersionFile
elif [ 'yesx' = "$sReverse"'x' ]; then #
    echo 'reverse'
    echo $sReverseVersion
    if [ 'lastx' = "$sReverseVersion"'x' ]; then
        _sReverseVersion=`/usr/bin/head -2 $sExecVersionFile | /usr/bin/tail -1` #查找最新一个版本
    else
        /bin/grep "$sReverseVersion" $sExecVersionFile > /dev/null
        if [ $? -ne 0 ]; then #没有找到
            showError 'we cant find version '"$sReverseVersion"'.'
        else #找到了
            showDebug 'we find version '"sReverseVersion"'.'
            _sReverseVersion=$sReverseVersion
        fi
    fi
    showInfo 'reverse version to '$_sReverseVersion'.'
    callAnsible 'switch_version' $_sReverseVersion $_sCodeTarFilePath
else
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
        showDebug $sRepoName' does not exist, we will get it from remote.'
        getRepo $sRepoType $sRepoUrl $sExecRepoCodeDir
    fi
    cd $sExecRepoCodeDir
    _sVersion=`/bin/date +%Y%m%d%H%M%S`
    # 根据是否有$sRepoMerge, 将对应分支merge到$sRepoMaster分支
    if [ -z $sRepoMerge ]; then
        switchBranch $sRepoType $sRepoMaster
        rebaseBranch $sRepoType $sRepoMaster
    else
        switchBranch $sRepoType $sRepoMerge
        rebaseBranch $sRepoType $sRepoMerge
        #rebaseBranch $sRepoType $sRepoMaster
        switchBranch $sRepoType $sRepoMaster
        rebaseBranch $sRepoType $sRepoMaster
        _sComment=$sRepoName' merge from '"$sRepoMerge"' at '$_sVersion
        mergeBranch $sRepoType $sRepoMerge "$_sComment"
        # 确保$sRepoMerge是最新的版本
    fi
    pushBranch $sRepoType "$sRepoMaster"
    
    # 打标签
    _sTag="$sRepoName"'_'"$_sVersion"
    switchBranch $sRepoType $sRepoMaster
    tagBranch $sRepoType "$_sTag" "$sRepoMaster"
    
    # 从仓库导出上线代码包
    _sCodeTarFilePath="$sExecCodeTarDir"'/'"$sRepoName"'_'"$_sVersion"'.tar.gz'
    exportCodeTar $sRepoType $sRepoMaster $_sCodeTarFilePath
    # 根据$sAnsibleFiles, 执行对应的发布操作
    if [ -n "$sAnsibleFiles" ]; then
        callAnsible "$sAnsibleFiles" $_sVersion $_sCodeTarFilePath
    fi
    # 记录仓库版本号日志, 用于回滚判定, 只记录50个版本
    showDebug 'record version('$_sVersion') into '$sExecVersionFile'.'
    _sExecVersionFileTmp=$sExecVersionFile'.tmp'
    /usr/bin/head -49 $sExecVersionFile > $_sExecVersionFileTmp
    /bin/echo $_sVersion > $sExecVersionFile
    /bin/cat $_sExecVersionFileTmp >> $sExecVersionFile
    /bin/rm -rf $_sExecVersionFileTmp
    showInfo 'our job here is done.'
fi