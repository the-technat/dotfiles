#!/bin/bash
<<Header
Script:   buildcam-fetcher.sh
Date:     30.05.2020
Author:   Nathanael Liechti
Version: 1.0
History   User    Date        Change
          technat 30.05.2020  Initial Version 1.0
Description: very simple bash script that fetches a buildcam url and saves the image in a directory with a timestamp
Usage: ./buildcam-fetcher.sh
Cronjob: 0 6-17/1 * * 1-5 /home/technat/buildcam-fetcher.sh
Dependency: wget

Header

#############################################################################
################################# Variables #################################
#############################################################################

# url where to fetch the image
fetchURL=""

# directory where to save the fetched files
saveDir="/home/technat/buildcam/"

# imageNaming
filePrefix=""
fileSufix=$(date '+%Y-%m-%d_%H:%M')
fileEnding=".jpg"
fileName="$filePrefiximage_$fileSufix$fileEnding"

#############################################################################
############################### Preparations ################################
#############################################################################

# if directory to save files does not exists create it
if [ ! -d "$saveDir" ]
then
  mkdir -p $saveDir
fi

#############################################################################
################################ Main Script ################################
#############################################################################


# check outagedays
if [ 0 -eq 0]
then
  exit 0
fi

# check working hours
if [ ! 0 -eq 0 ]
then
  exit 0
fi


# change to corret path
cd $saveDir

# fetch image
wget -O $fileName $fetchURL

#############################################################################
################################## Cleanup ##################################
#############################################################################
exit 0
