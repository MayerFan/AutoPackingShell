#!/bin/sh
# 该脚本使用方法
# 源码地址：https://github.com/stackhou
# step 1. 在工程根目录新建AutoPacking文件夹，在该文件夹中新建文件autopacking.sh，将该脚本复制到autopacking.sh文件并保存(或者直接复制该文件);
# step 2. 配置和你的项目相关的选项，尤其1.打包编译方式，默认是debug和release 2.你自己证书生成的plist文件;
# step 2. cd 该脚本目录，运行chmod +x autopacking.sh;
# step 3. 终端运行 sh autopacking.sh;
# step 4. 选择所需选项....
# step 5. Success  🎉 🎉 🎉!
# 注意：可以全文搜索“配置”，看相关注释选择配置，因为不同的项目配置不同，最好有相关的基础知识

# ***************************** 函数区 ********************************
# Log接收2个参数：参数1：具体的输出信息
# 参数2.整数类型，用于选择哪套首尾颜色。eg 1：分割线颜色。也是默认颜色 2：标题颜色 3：可选项颜色 4：错误输出颜色。其他待定
function Log() {
    message=$1
    enum=$2

    if [ -z $enum ]; then
        left=$__LINE_BREAK_LEFT
        right=$__LINE_BREAK_RIGHT
    else
        if [ $enum == 2 ]; then
            left=$__TITLE_LEFT_COLOR
            right=$__TITLE_RIGHT_COLOR
        elif [ $enum == 3 ]; then
            left=$__OPTION_LEFT_COLOR
            right=$__OPTION_RIGHT_COLOR
        elif [ $enum == 4 ]; then
            left=$__ERROR_MESSAGE_LEFT
            right=$__ERROR_MESSAGE_RIGHT
        else
            left=$__LINE_BREAK_LEFT
            right=$__LINE_BREAK_RIGHT
        fi
    fi

    echo "${left}${message}${right}"
}

# 函数接受2个参数：1.提示标题 2.选项数组。数组格式[1.option]
function Read_user_input() {
    title=$1
    options=$2

    Log $title 2

    for option in ${options[@]}; do
        Log $option 3
    done

    read input

#   判断用户输入是否在选项之内
    exist=0
    for option in ${options[@]}; do

        res=$(echo $option | grep $input)
        if [ $res ]; then
            exist=1
            value=${option:2}
            __RETURN_VALUE=$value
            break
        fi
    done

    if [ $exist == 0 ]; then
        Log "您输入内容无效，请重新输入。。。" 4
        exit 1
    fi
}

# ***************************** 通用区 ********************************
__TITLE_LEFT_COLOR="\033[36;1m==== "
__TITLE_RIGHT_COLOR=" ====\033[0m"

__OPTION_LEFT_COLOR="\033[33;1m"
__OPTION_RIGHT_COLOR="\033[0m"

__LINE_BREAK_LEFT="\033[32;1m"
__LINE_BREAK_RIGHT="\033[0m"

# 红底白字
__ERROR_MESSAGE_LEFT="\033[41m ! ! ! "
__ERROR_MESSAGE_RIGHT=" ! ! ! \033[0m"

# 函数返回值
__RETURN_VALUE=""

# ************************* 配置区 ********************************

# 1. 配置Target(如果没有多个target，建议忽略写死target)
options=("1.ZTExchange" "2.Test")
Read_user_input "请选择Target：" $options
__SCHEME_NAME=$__RETURN_VALUE
Log $__SCHEME_NAME


# 2. 配置项目名称 （用于导出ipa包名的前缀。如果不指定默认为SCHEME_NAME）
#    (如果不需要更改项目名称，建议忽略)
Log "是否更改项目名称（用于ipa包名的前缀。如果不指定默认为shcemeName）" 2
read parameter
__IPA_NEW_NAME=$parameter
if [[ "${__IPA_NEW_NAME}" == "" ]]; then
    __IPA_NEW_NAME=$__SCHEME_NAME
fi
Log "项目名称:$__IPA_NEW_NAME"


# 3. 配置构建模式。如：Release, Debug... 。
#    当前项目中所定义的模式为：TestDebug(测试环境_debug模式), TestRelease(测试环境_release模式), DistributionDebug(发布环境_debug模式), DistributionRelease(发布环境_release模式)
options=("1.TestDebug" "2.TestRelease" "3.DistributionDebug" "4.DistributionRelease")
Read_user_input "请选择BUILD_CONFIGURATION：" $options
__BUILD_CONFIGURATION=$__RETURN_VALUE
Log $__BUILD_CONFIGURATION


# 4. 配置工程类型。（.xcworkspace项目,赋值true; .xcodeproj项目, 赋值false）
#    (几乎所有工程都是.xcworkspace项目，建议忽略写死项目类型)
options=("1.true" "2.false")
Read_user_input "请选择是否是.xcworkspace项目：" $options
__IS_WORKSPACE=$__RETURN_VALUE
Log $__IS_WORKSPACE


# 5. 配置打包方式（AdHoc, AppStore, Enterprise, Development）
options=("1.AdHoc" "2.AppStore" "3.Enterprise" "4.Development")
Read_user_input "请选择BUILD_CONFIGURATION：" $options
__BUILD_METHOD=$__RETURN_VALUE
Log $__BUILD_METHOD

# 5.1 由打包方式读取plist信息
if [[ "${__BUILD_METHOD}" == "AdHoc" ]]; then
    ExportOptionsPlistPath="./AutoPacking/Plist/AdHocExportOptionsPlist.plist"
elif [[ "${__BUILD_METHOD}" == "AppStore" ]]; then
    ExportOptionsPlistPath="./AutoPacking/Plist/AppStoreExportOptionsPlist.plist"
elif [[ "${__BUILD_METHOD}" == "Enterprise" ]]; then
    ExportOptionsPlistPath="./AutoPacking/Plist/EnterpriseExportOptionsPlist.plist"
elif [[ "${__BUILD_METHOD}" == "Development" ]]; then
    ExportOptionsPlistPath="./AutoPacking/Plist/DevelopmentExportOptionsPlist.plist"
fi
Log $ExportOptionsPlistPath


# 6. 配置是否上传到内测平台（此处为自定义平台）
#    如果有多个其他分发平台，此处可以列表展开
options=("1.NO" "2.YES")
Read_user_input "请选择ipa是否发布到内测平台：" $options
__UPLOAD_TYPE_SELECTED=$__RETURN_VALUE
Log $__UPLOAD_TYPE_SELECTED

# 6.1 配置上传日志（当前ipa包的变更信息）
if [[ "${__UPLOAD_TYPE_SELECTED}" == "YES" ]]; then
    Log "请输入当前ipa包的变更信息（新增功能）"
    read parameter
    __UPLOAD_INFO="${parameter}"
    Log "输入的内容为：$parameter"
fi


# 7. 默认打包完成自动打开文件夹且配置完成立即开始打包
Log "配置完成，开始打包===😁😁😁"
sleep 0.5

# =============================== 自动打包区 =============================

Log "使用打包文件plist路径=${ExportOptionsPlistPath}"

# 打包计时
__CONSUME_TIME=0
# 回退到工程目录
cd ../
__PROGECT_PATH=`pwd`

Log "进入工程目录=${__PROGECT_PATH}"

# 获取项目名称
__PROJECT_NAME=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`

# 已经指定Target的Info.plist文件路径 【配置Info.plist的名称】
__CURRENT_INFO_PLIST_NAME="Info.plist"
# 获取 Info.plist 路径  【配置Info.plist的路径】
__CURRENT_INFO_PLIST_PATH="${__PROJECT_NAME}/${__CURRENT_INFO_PLIST_NAME}"
# 当前的plist文件路径
Log "当前Info.plist路径= ${__CURRENT_INFO_PLIST_PATH}"

# 获取版本号
__BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${__CURRENT_INFO_PLIST_PATH}`
# 获取编译版本号
__BUNDLE_BUILD_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${__CURRENT_INFO_PLIST_PATH}`

# 打印版本信息
Log "打包版本=${__BUNDLE_VERSION} 编译版本=${__BUNDLE_BUILD_VERSION}"

# 编译生成文件目录
__EXPORT_PATH="./build"

# 指定输出文件目录不存在则创建
if test -d "${__EXPORT_PATH}" ; then
    Log "保存归档文件和ipa的路径=${__EXPORT_PATH}"
    rm -rf ${__EXPORT_PATH}
else
    mkdir -pv ${__EXPORT_PATH}
fi

# 归档文件路径
__EXPORT_ARCHIVE_PATH="${__EXPORT_PATH}/${__SCHEME_NAME}.xcarchive"
# ipa 导出路径
__EXPORT_IPA_PATH="${__EXPORT_PATH}"
# 获取时间 如:201706011145
__CURRENT_DATE="$(date +%Y%m%d%H%M%S)"
# ipa 名字
__IPA_NAME="${__IPA_NEW_NAME}_V${__BUNDLE_BUILD_VERSION}_${__CURRENT_DATE}"

Log "打包APP名字=${__IPA_NAME}"

# 修改编辑版本
#__SET_BUNDLE_BUILD_VERSION="${__BUNDLE_BUILD_VERSION}.${__CURRENT_DATE}"
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${__SET_BUNDLE_BUILD_VERSION}" "${__CURRENT_INFO_PLIST_PATH}"

Log "开始构建项目"

if ${__IS_WORKSPACE} ; then
    Log "您选择了以 xcworkspace-${__BUILD_CONFIGURATION} 模式打包"

    # step 1. Clean
    xcodebuild clean  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION}

    # step 2. Archive
    xcodebuild archive  -workspace ${__PROJECT_NAME}.xcworkspace \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DEVELOPMENT}"

else
    Log "您选择了以 xcodeproj-${__BUILD_CONFIGURATION} 模式打包"

    # step 1. Clean
    xcodebuild clean  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    #-alltargets

    # step 2. Archive
    xcodebuild archive  -project ${__PROJECT_NAME}.xcodeproj \
    -scheme ${__SCHEME_NAME} \
    -configuration ${__BUILD_CONFIGURATION} \
    -archivePath ${__EXPORT_ARCHIVE_PATH} \
    CFBundleVersion=${__BUNDLE_BUILD_VERSION} \
    -destination generic/platform=ios \
    #CODE_SIGN_IDENTITY="${__CODE_SIGN_DEVELOPMENT}"
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "${__EXPORT_ARCHIVE_PATH}" ; then
    Log "项目构建成功 🚀 🚀 🚀"
else
    Log "项目构建失败 😢 😢 😢"
    exit 1
fi

Log "开始导出ipa文件"

xcodebuild -exportArchive -archivePath ${__EXPORT_ARCHIVE_PATH} \
-exportPath ${__EXPORT_IPA_PATH} \
-destination generic/platform=ios \
-exportOptionsPlist ${ExportOptionsPlistPath} \
-allowProvisioningUpdates

# 修改ipa文件名称
mv ${__EXPORT_IPA_PATH}/${__SCHEME_NAME}.ipa ${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa

# 检查文件是否存在
if test -f "${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa" ; then
    Log "导出 ${__IPA_NAME}.ipa 包成功 🎉 🎉 🎉"

    if test -n "${__UPLOAD_TYPE_SELECTED}"; then

        if [[ "${__UPLOAD_TYPE_SELECTED}" == "NO" ]] ; then
            Log "您选择了不上传到内测网站"
        elif [[ "${__UPLOAD_TYPE_SELECTED}" == "YES" ]]; then

            curl -F "file=@${__EXPORT_IPA_PATH}/${__IPA_NAME}.ipa" \
            -F "info=${__UPLOAD_INFO}" \
            "http://192.168.200.108:8001/upload"

            Log "上传 ${__IPA_NAME}.ipa成功 🎉 🎉 🎉"
#        else
#            Log ""
#            echo "${__LINE_BREAK_LEFT} 您输入 上传内测网站 参数无效!!! ${__LINE_BREAK_RIGHT}"
#            exit 1
        fi

    fi

    #  自动打开文件夹
    __IS_AUTO_OPENT_FILE=true
    if ${__IS_AUTO_OPENT_FILE} ; then
        open ${__EXPORT_IPA_PATH}
    fi

else
    Log "导出 ${__IPA_NAME}.ipa 包失败 😢 😢 😢"
    exit 1
fi

# 输出打包总用时
Log "脚本打包总耗时: ${SECONDS}s"
