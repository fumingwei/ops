#!/bin/bash

# 检查是否以 root 用户身份运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 提示输入用户名
read -p "请输入要添加的用户名: " username

# 检查用户名是否为空
if [ -z "$username" ]; then
    echo "用户名不能为空。"
    exit 1
fi

# 添加用户并指定默认 shell 为 /bin/bash
useradd -m -s /bin/bash "$username"

# 检查用户添加是否成功
if [ $? -eq 0 ]; then
    echo "用户 $username 添加成功。"
else
    echo "添加用户 $username 失败。"
    exit 1
fi

# 设置用户密码
read -sp "请输入用户 $username 的密码: " password
echo
read -sp "请再次输入密码以确认: " password_confirm
echo

# 检查两次输入的密码是否一致
if [ "$password" != "$password_confirm" ]; then
    echo "两次输入的密码不一致，请重试。"
    exit 1
fi

# 设置用户密码
echo "$username:$password" | chpasswd

# 创建基本的 .bashrc 文件
cat <<EOL > /home/$username/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.

# 如果存在，加载用户的 .bash_aliases 文件
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# 设置命令提示符
PS1='[\u@\h \W]\$ '

# 设置环境变量
export EDITOR=nano
EOL

# 设置 .bashrc 文件的权限
chown "$username:$username" /home/$username/.bashrc
chmod 644 /home/$username/.bashrc

# 提示是否给予 sudo 权限
read -p "是否给予用户 $username sudo 权限？(y/n): " sudo_choice

if [[ "$sudo_choice" == "y" || "$sudo_choice" == "Y" ]]; then
    # 提示是否需要输入密码
    read -p "是否需要输入密码才能使用 sudo？(y/n): " password_choice

    if [[ "$password_choice" == "n" || "$password_choice" == "N" ]]; then
        # 给予 sudo 权限并设置免密
        echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        echo "用户 $username 已被赋予 sudo 权限，无需输入密码。"
    else
        # 给予 sudo 权限
        usermod -aG sudo "$username"
        echo "用户 $username 已被赋予 sudo 权限。"
    fi
else
    echo "用户 $username 未被赋予 sudo 权限。"
fi

# 输出设置的密码
echo "用户 $username 的密码已设置为: $password"

# 提示完成
echo "操作完成。"

