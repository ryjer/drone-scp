#!/bin/sh

set -e
# 从环境变量读取 host 列表，导入 hosts 文件中备用
echo ${PLUGIN_HOST} | sed "s/,/\n/g" > /scp/hosts

# 从环境变量读取 源文件 列表，导入 sources 文件
echo ${PLUGIN_SOURCE} | sed "s/,/\n/g"  > /scp/source

# 从环境变量读取 目标文件 列表，导入 targets 文件 
echo ${PLUGIN_TARGET} | sed "s/,/\n/g"  > /scp/target

# 将源文件列表 和 目标文件列表合并
paste /scp/source /scp/target > /scp/src_dst

# 获取 PLUGIN_ 其他环境变量，并转换为本地变量格式
port=${PLUGIN_PORT}
username=${PLUGIN_USERNAME}
password=${PLUGIN_PASSWORD}
is_rm=${PLUGIN_RM}

echo "======== 变量列表 ========"
echo "pwd: $PWD"
echo "ls:"
ls
echo "port: $port"
echo "username: $username"
echo "password: $password"
echo "is_rm: $is_rm"
echo "host: ${PLUGIN_HOST}"
echo "source: ${PLUGIN_SOURCE}"
echo "target: ${PLUGIN_TARGET}"
echo "======== 文件列表 ========"
echo "/scp/hosts"
cat /scp/hosts
echo "/scp/source"
cat /scp/source
echo "/scp/target"
cat /scp/target
echo "src_dst"
cat /scp/src_dst
echo "=========================="

# 循环处理 scp 列表
## 外循环，主机列表 集群分发
cat /scp/hosts | while read line
do
    host=`echo $line | awk '{print $1}'`
    # 添加目标主机 hash 指纹，防止接下来 scp 命令提示是否接受目标主机 HASH 公钥指纹
    ssh-keyscan -H $host >> ~/.ssh/known_hosts
    echo -e "================ Host: ${host} start ================"
   ## 内循环，源文件列表 和 目标文件列表，逐一进行匹配
    cat /scp/src_dst | while read line
    do
        src=`echo $line | awk '{print $1}'`
        dst=`echo $line | awk '{print $2}'`
        echo -e "======== ${src} --> ${dst} ========"
       ## is_rm 判定，如果为 true ，递归删除目标文件（文件夹）
        if [ $is_rm = "true" ]; then
            sshpass -p ${password} ssh -p ${port} ${username}@${host} rm -rf ${dst}
            echo -e "remove \"${dst}\"  删除 \"${dst}\""
        fi
       ## 判断 源文件 或 文件夹 是否存在
        if [ ! -e ${src} ]; then
            echo -e "\"${src}\" is not exist!  文件(夹) \"${src}\" 不存在！"
            exit 1
        fi
        # sshpass -p ${password} scp -C -v -r -P ${port} ${src} ${username}@${host}:${dst}
        sshpass -p ${password} scp -C -r -P ${port} ${src} ${username}@${host}:${dst}
       ## 根据 scp 执行结果进行反馈
        if [ $? != 0 ]; then
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
