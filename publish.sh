#!/bin/bash

#publish repo

sExecCurrentDir=$(cd "$(dirname "$0")"; /bin/pwd)
sExecRootDir=`/bin/readlink -f $sExecCurrentDir/`

source $sExecRootDir'/inc/initial.sh'

if [ 'yesx' = "$sList"'x' ]; then
    showInfo 'show repo version list.'
    /bin/cat $sExecVersionFile
elif [ 'yesx' = "$sReverse"'x' ]; then #
    if [ 'lastx' = "$sReverseVersion"'x' ]; then
        sReverseVersion=`/usr/bin/head -2 $sExecVersionFile | /usr/bin/tail -1` #查找最新一个版本
    else
        /bin/grep "$sReverseVersion" $sExecVersionFile > /dev/null
        if [ $? -ne 0 ]; then #没有找到
            showError 'we cant find version '"$sReverseVersion"'.'
        else #找到了
            showDebug 'we find version '"sReverseVersion"'.'
        fi
    fi
    showInfo 'reverse version to '$sReverseVersion'.'
    callAnsible 'switch_version' $sReverseVersion
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
    sVersion=`/bin/date +%Y%m%d%H%M%S`
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
        sGitCommentTime=`/bin/date +%Y%m%d%H%M`
        sComment=$sGitCommentTime'_merge_'$sRepoMerge''
        mergeBranch $sRepoType $sRepoMerge "$sComment"
        # 确保$sRepoMerge是最新的版本
    fi
    pushBranch $sRepoType "$sRepoMaster"
    
    # 打标签
    sTag="$sRepoName"'_'"$sVersion"
    switchBranch $sRepoType $sRepoMaster
    tagBranch $sRepoType "$sTag" "$sRepoMaster"
    
    # 从仓库导出上线代码包
    sCodeTarFilePath="$sExecCodeTarDir"'/'"$sRepoName"'_'"$sVersion"'.tar.gz'
    if [ 'nox' = "$sCustomCodeTar"'x' ]; then
        exportCodeTar $sRepoType $sRepoMaster $sCodeTarFilePath
    else
        loadRepoFile 'createCodeTar'
        createCodeTar $sExecRepoCodeDir $sCodeTarFilePath
        if [ 0 -ne $? ]; then
            showError 'can not create code tar.'
        fi
    fi
    # 根据$sAnsibleFiles, 执行对应的发布操作
    if [ -n "$sAnsibleFiles" ]; then
        callAnsible "$sAnsibleFiles" $sVersion $sCodeTarFilePath
    fi
    # 记录仓库版本号日志, 用于回滚判定, 只记录50个版本
    showDebug 'record version('$sVersion') into '$sExecVersionFile'.'
    sExecVersionFileTmp=$sExecVersionFile'.tmp'
    /usr/bin/head -49 $sExecVersionFile > $sExecVersionFileTmp
    /bin/echo $sVersion > $sExecVersionFile
    /bin/cat $sExecVersionFileTmp >> $sExecVersionFile
    /bin/rm -rf $sExecVersionFileTmp
    showInfo 'our job here is done.'
fi