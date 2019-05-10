#!/bin/bash

#test all repo configure

sExecCurrentDir=$(cd "$(dirname "$0")"; /bin/pwd)
sExecRootDir=`/bin/readlink -f $sExecCurrentDir/`

source $sExecRootDir'/inc/initial.sh'

showInfo 'show all variables start.'
    for sExecConfigName in $sRepoConfigFrameVars
    do
        eval sExecConfigValue="\$$sExecConfigName"
        showMessage "$sExecConfigName" "$sExecConfigValue"
    done
    for sExecConfigName in $sRepoConfigVars
    do
        eval sExecConfigValue="\$$sExecConfigName"
        showMessage "$sExecConfigName" "$sExecConfigValue"
    done
showInfo 'show all variables successfully.'

showInfo 'test '"$sRepoName"' successfully.'