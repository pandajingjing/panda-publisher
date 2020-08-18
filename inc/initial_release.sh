source $sExecRootDir'/inc/functions.sh'
source $sExecRootDir'/inc/functions_release.sh'
source $sExecRootDir'/config'

parseBin "$@"

loadRepoFile 'config'

sExecRepoCodeDir=$sExecTempDir'/'$sRepoSubDir
sExecCodeTarDir=$sExecTarDir'/'$sRepoSubDir

createDir $sExecTarDir
createDir $sExecTempDir
createDir $sExecCodeTarDir

#create bin configure variables
sRepoConfigFrameVars='sDeployUser sDeployGroup sDeployServer iDebug sFixDataInstallDir sDynamicDataInstallDir sLogInstallRootDir sAppRootDir sBinRootDir
sExecCurrentDir sExecRootDir sExecTarDir sExecTempDir sExecRepoRootDir sExecVersionDir sExecLocalGit sExecAnsiblePlaybook sExecRemotePhp sExecLocalPhp sExecLocalNpm
sRepoName sReverse sReverseVersion sExecRepoDir sExecVersionFile sExecRepoCodeDir sExecCodeTarDir
sRepoType sRepoUrl sRepoSubDir sRepoMaster sRepoMerge sCustomCodeTar sAnsibleFiles sDestDir'