#!/bin/bash
#This is xcode project bash file
# Author:廖宇 黄龙锋
# Created on: 2012-10-26

#编译版本：0: release 1: debug 2: release,debug
buildType=2
#用来判断是否已经编译
iPhoneFile="iphone.txt"
#编译ID:release
Build_Identifier_release="com.autonavi.navigation299"
#编译ID:Debug
Build_Identifier_debug="com.autonavi.navigation"
#工程路径
projectPath="/Volumes/Document/6.0HMI9/iPhone"
#projectPath="/Volumes/WORK/SVNHLF/02.IMPLEMENT/iPhone"
#编译完成路径
buildFinishedPath="$projectPath/build-iphone-finished.txt"

#配置文件名
info_plist="$projectPath/AutoNavi-Info.plist"
#release编译产生的文件
iPhoneReleaseBuildResult="$projectPath/build/Distribution-iphoneos/ipa/AutoNavi-Release$releaseTime.ipa"
#debug编译产生的文件
iPhoneDebugBuildResult="$projectPath/build/Debug-iphoneos/ipa/AutoNavi-Debug$debugTime.ipa"
#release编译成功标志文件
iPhoneReleaseBuildSuccess="$projectPath/Iphone_Release_Successfully.txt"
#release编译失败标志文件
iPhoneReleaseBuildFailed="$projectPath/Iphone_Release_Failed.txt"
#debug编译成功标志文件
iPhoneDebugBuildSuccess="$projectPath/Iphone_Debug_Successfully.txt"
#debug编译失败标志文件
iPhoneDebugBuildFailed="$projectPath/Iphone_Debug_Failed.txt"

#***************** begin build **************************************
cd $projectPath      #工程目录

if [ -f "$iPhoneFile" ]; then                 #判断是否存在iphone.txt文件

rm -f $iPhoneFile

if [ $buildType = "1" ]; then                 #编译debug版本


#修改编译id
defaults write "$info_plist" CFBundleIdentifier $Build_Identifier_debug
#开始编译
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Debug clean
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Debug 
#压缩成ipa包
mkdir -p build/Debug-iphoneos/ipa/Payload
cp -r build/Debug-iphoneos/AutoNavi.app build/Debug-iphoneos/ipa/Payload
cd build/Debug-iphoneos/ipa
debugTime=`date "+-%Y%m%d%H%M"`
zip -r ./AutoNavi-Debug$debugTime.ipa ./*
iPhoneDebugBuildResult="$projectPath/build/Debug-iphoneos/ipa/AutoNavi-Debug$debugTime.ipa"


elif [ $buildType = "0" ]; then              #编译release版本


#修改编译id
defaults write "$info_plist" CFBundleIdentifier $Build_Identifier_release
#开始编译
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Distribution clean
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Distribution 
#压缩成ipa包
mkdir -p build/Distribution-iphoneos/ipa/Payload
cp -r build/Distribution-iphoneos/AutoNavi.app build/Distribution-iphoneos/ipa/Payload
cd build/Distribution-iphoneos/ipa
releaseTime=`date "+-%Y%m%d%H%M"`
zip -r ./AutoNavi-Release$releaseTime.ipa ./*
iPhoneReleaseBuildResult="$projectPath/build/Distribution-iphoneos/ipa/AutoNavi-Release$releaseTime.ipa"

else                                        #debug,release同时编译

#debug
#修改编译id
defaults write "$info_plist" CFBundleIdentifier $Build_Identifier_debug
#开始编译
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Debug clean
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Debug
#压缩成ipa包
mkdir -p build/Debug-iphoneos/ipa/Payload
cp -r build/Debug-iphoneos/AutoNavi.app build/Debug-iphoneos/ipa/Payload
cd build/Debug-iphoneos/ipa
debugTime=`date "+-%Y%m%d%H%M"`
zip -r ./AutoNavi-Debug$debugTime.ipa ./*
iPhoneDebugBuildResult="$projectPath/build/Debug-iphoneos/ipa/AutoNavi-Debug$debugTime.ipa"
#判断是否编译成功
if [ -e "$iPhoneDebugBuildResult" ]; then                      #判断debug版本是否编译成功
echo "*********************debug编译成功************************"
else
touch "$iPhoneDebugBuildFailed"                                #编译失败生成标志文件
echo "*********************debug编译失败************************"
exit 0
fi

#release
cd ../../..
#修改编译id
defaults write "$info_plist" CFBundleIdentifier $Build_Identifier_release
#开始编译
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Distribution clean
xcodebuild -project AutoNavi.xcodeproj -sdk iphoneos8.0 -configuration Distribution
#压缩成ipa包
mkdir -p build/Distribution-iphoneos/ipa/Payload
cp -r build/Distribution-iphoneos/AutoNavi.app build/Distribution-iphoneos/ipa/Payload
cd build/Distribution-iphoneos/ipa
releaseTime=`date "+-%Y%m%d%H%M"`
zip -r ./AutoNavi-Release$releaseTime.ipa ./*
iPhoneReleaseBuildResult="$projectPath/build/Distribution-iphoneos/ipa/AutoNavi-Release$releaseTime.ipa"

fi

else
echo "*************没有找到iphone.txt文件************************"
exit 0
fi

#***************** check the build is completed ***********************
touch "$buildFinishedPath"
if [ $buildType = "1" ]; then

if [ -e "$iPhoneDebugBuildResult" ]; then                      #判断debug版本是否编译成功
touch "$iPhoneDebugBuildSuccess"                               #编译成功生成标志文件
echo "*********************debug编译成功************************"
else
touch "$iPhoneDebugBuildFailed"                                #编译失败生成标志文件
echo "*********************debug编译失败************************"
fi

elif [ $buildType = "0" ]; then

if [ -e "$iPhoneReleaseBuildResult" ]; then                    #判断release版本是否编译成功
touch "$iPhoneReleaseBuildSuccess"                             #编译成功生成标志文件
echo "*********************release编译成功************************"
else
touch "$iPhoneReleaseBuildFailed"                              #编译失败生成标志文件
echo "*********************release编译失败************************"
fi

else

if [ -e "$iPhoneReleaseBuildResult" ]; then                    #判断release版本是否编译成功
touch "$iPhoneReleaseBuildSuccess"                             #编译成功生成标志文件
echo "*********************release编译成功************************"
else
touch "$iPhoneReleaseBuildFailed"                              #编译失败生成标志文件
echo "*********************release编译失败************************"
fi

fi
