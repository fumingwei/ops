#!/bin/bash

# 检查是否以 root 用户身份运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 提示输入要删除的用户名
read -p "请输入要删除的用户名: " username

# 检查用户名是否为空
if [ -z "$username" ]; then
    echo "用户名不能为空。"
    exit 1
fi

# 检查用户是否存在
if id "$username" &>/dev/null; then
    echo "用户 $username 存在，准备删除..."
else
    echo "用户 $username 不存在。"
    exit 1
fi

# 删除用户及其主目录
userdel -r "$username"

# 检查用户删除是否成功
if [ $? -eq 0 ]; then
    echo "用户 $username 已成功删除。"
else
    echo "删除用户 $username 失败。"
    exit 1
fi

# 清理用户的 sudo 权限信息
# 从 /etc/sudoers 文件中删除用户的 sudo 权限
sed -i "/^$username/d" /etc/sudoers

# 清理用户的邮件信息
# 删除用户的邮件文件
maildir="/var/mail/$username"
if [ -f "$maildir" ]; then
    rm -f "$maildir"
    echo "用户 $username 的邮件信息已删除。"
fi

# 清理用户的 cron 任务
crontab -u "$username" -r 2>/dev/null

# 清理用户的其他痕迹
# 例如，删除用户的 bash 历史记录
history_file="/home/$username/.bash_history"
if [ -f "$history_file" ]; then
    rm -f "$history_file"
    echo "用户 $username 的 bash 历史记录已删除。"
fi

# 提示完成
echo "用户 $username 的个人空间及系统内遗留信息已清理完成。"

