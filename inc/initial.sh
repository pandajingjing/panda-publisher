source $sExecRootDir'/inc/functions.sh'
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
sExecCurrentDir sExecRootDir sExecTarDir sExecTempDir sExecRepoRootDir sExecGit sExecAnsiblePlaybook sExecRemotePhp
sRepoName sReverse sReverseVersion sExecRepoDir sExecRepoCodeDir sExecCodeTarDir
sRepoType sRepoUrl sRepoSubDir sRepoMaster sRepoMerge sAnsibleFiles sDestDir sLoader'