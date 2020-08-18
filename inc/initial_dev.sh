source $sExecRootDir'/inc/functions.sh'
source $sExecRootDir'/inc/functions_dev.sh'
source $sExecRootDir'/config'

parseBin "$@"

sExecRepoDir=$sExecRepoRootDir'/dev'
showDebug 'repo dir is: '"$sExecRepoDir"'.'

if [ ! -d $sExecRepoDir ]; then
    showError 'repo(dev) does not exist.'
fi

loadRepoFile 'config'

sExecRepoCodeDir=$sExecTempDir'/dev.'$sRemote
sExecCodeTarDir=$sExecTarDir'/dev'

createDir $sExecTarDir
createDir $sExecTempDir
createDir $sExecCodeTarDir

#create bin configure variables
sRepoConfigFrameVars='sDeployUser sDeployGroup sDeployServer iDebug sFixDataInstallDir sDynamicDataInstallDir sLogInstallRootDir sAppRootDir sBinRootDir
sExecCurrentDir sExecRootDir sExecTarDir sExecTempDir sExecRepoRootDir sExecVersionDir sExecLocalGit sExecAnsiblePlaybook sExecRemotePhp sExecLocalPhp sExecLocalNpm
sExecRepoDir sBranch sRemote sExecRepoCodeDir sExecCodeTarDir
sRepoType sRepoUrl sRepoMaster sRepoMerge sCustomCodeTar sAnsibleFiles sDestDir'