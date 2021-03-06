#!/bin/sh
set -e

# 创建 所需文件目录环境
workdir="/scp"
# 1. 工作目录 /scp
if [[ ! -e ${workdir} ]]; then
    echo -e "\"${workdir}\" is not exist!  文件(夹) \"${workdir}\" 不存在！"
    exit 1
fi
# 2. ~/.ssh 目录
if [[ ! -e ${HOME}/.ssh ]]; then
    echo -e "\"${HOME}/.ssh\" is not exist!  文件(夹) \"${HOME}/.ssh\" 不存在！"
    exit 1  
fi
# 检查 环境变量完备性: 主机名host 端口port 用户名username 密码password 源文件source 目标文件target
if [[ ! ${PLUGIN_HOST} ]] || [[ ! ${PLUGIN_PORT} ]]  || [[ ! ${PLUGIN_USERNAME} ]] || [[ ! ${PLUGIN_PASSWORD} ]] || [[ ! ${PLUGIN_SOURCE} ]] || [[ ! ${PLUGIN_TARGET} ]]; then
    echo "\"host\" or \"port\" or \"username\" or \"password\" or \"source\" or \"target\" is not exist!"
    echo "\"host\" 或 \"port\" 或 \"username\" 或 \"password\" 或 \"source\" 或 \"target\" 未定义！"
    exit 1
fi
# 从环境变量读取 host 列表，导入 hosts 文件中备用
echo ${PLUGIN_HOST} | sed "s/,/\n/g" > ${workdir}/hosts 

# 从环境变量读取 源文件 列表，导入 sources 文件
echo ${PLUGIN_SOURCE} | sed "s/,/\n/g"  > ${workdir}/source 

# 从环境变量读取 目标文件 列表，导入 targets 文件 
echo ${PLUGIN_TARGET} | sed "s/,/\n/g"  > ${workdir}/target 

# 将源文件列表 和 目标文件列表合并
paste ${workdir}/source ${workdir}/target > ${workdir}/src_dst

# 获取 PLUGIN_ 其他环境变量，并转换为本地变量格式
port=${PLUGIN_PORT}
username=${PLUGIN_USERNAME}
password=${PLUGIN_PASSWORD}
is_rm=${PLUGIN_RM}

# 添加目标主机 hash 指纹，防止接下来 scp 命令提示是否接受目标主机 HASH 公钥指纹
ssh-keyscan -f ${workdir}/hosts -p ${port}  >> ${HOME}/.ssh/known_hosts
# 循环处理 scp 列表
## 外循环，主机列表 集群分发
cat ${workdir}/hosts | while read line
do
    host=`echo $line | awk '{print $1}'`
    echo  "================ Host: ${host} start ================"
   ## 内循环，源文件列表 和 目标文件列表，逐一进行匹配
    cat ${workdir}/src_dst | while read line
    do
        src=`echo $line | awk '{print $1}'`
        dst=`echo $line | awk '{print $2}'`
        echo -e "======== ${src} --> ${dst} ========"
       ## is_rm 判定，如果为 true ，递归删除目标文件（文件夹）
        if [[ $is_rm = "true" ]]; then
            sshpass -p ${password} ssh -p ${port} ${username}@${host} rm -rf ${dst}
            echo -e "remove \"${dst}\"  删除 \"${dst}\""
        fi
       ## 判断 源文件 或 文件夹 是否存在
        if [[ ! -e ${src} ]]; then
            echo -e "\"${src}\" is not exist!  文件(夹) \"${src}\" 不存在！"
            exit 1
        fi
        # sshpass -p ${password} scp -C -v -r -P ${port} ${src} ${username}@${host}:${dst}
        sshpass -p ${password} scp -C -r -P ${port} ${src} ${username}@${host}:${dst}
       ## 根据 scp 执行结果进行反馈
        if [[ $? != 0 ]]; then
            echo "======== ${src} --> ${dst}  ❌  failed!  失败！========"
            exit 1
        else
            echo "======== ${src} --> ${dst}  ✅  successed!  完成！========"
        fi
    done
    echo "================ Host: ${host} successed ================"
done

echo "================================"
printf "   All completed！ 全部完成！\n"
echo "================================"
