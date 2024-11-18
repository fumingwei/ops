#!/bin/bash

# 定义容器目录路径
CONTAINER_DIR="/var/lib/docker/containers"

# 检查目录是否存在
if [ ! -d "$CONTAINER_DIR" ]; then
    echo "目录 $CONTAINER_DIR 不存在"
    exit 1
fi

# 遍历目录下的所有子目录
for dir in "$CONTAINER_DIR"/*/; do
    # 获取容器ID，即目录名称
    container_id=$(basename "$dir")

    # 构建日志文件的完整路径
    log_file="${dir}${container_id}-json.log"

    # 检查日志文件是否存在
    if [ -f "$log_file" ]; then
        # 如果文件存在，打印文件路径
        echo "发现日志文件：$log_file"
    else
        echo "日志文件不存在：$log_file"
    fi
done

# 询问用户是否要清理
read -p "是否要清理所有标记的日志文件？(Y/y): " confirm
if [[ $confirm == [Yy] || $confirm == [Yy][Ee][Ss] ]]; then
    # 再次遍历目录下的所有子目录
    for dir in "$CONTAINER_DIR"/*/; do
        # 获取容器ID，即目录名称
        container_id=$(basename "$dir")

        # 构建日志文件的完整路径
        log_file="${dir}${container_id}-json.log"

        # 检查日志文件是否存在
        if [ -f "$log_file" ]; then
            # 如果文件存在，执行echo 0覆盖文件内容
            echo 0 > "$log_file"
            echo "已清空文件：$log_file"
        fi
    done
    echo "所有容器日志文件处理完成。"
else
    echo "清理操作已取消。"
fi
