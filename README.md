# 启动WSL服务计划任务(ubuntu)

本文使用开启开发者模式的`Windows 20H2`版本，基于`WSL2`, 支持在`Windows`启动时启动`WSL`中的`Linux`服务或者执行命令. 没仔细测试, 可能存在bug.
1. [安装wsl](https://docs.microsoft.com/en-us/windows/wsl/)
2. 设置默认`wsl`发行版: `wsl -s ubuntu`.
3. 设置默认`root`用户: `ubuntu config --default-user root`.

## 为什么要折腾WSL？

首先, 对新鲜事物的好奇心驱使.
其次, 一直在关注`wsl`, 想尝试一下能否替代的`VMware Workstation Pro`.
如果, 以上对你没啥吸引力, 那么可以关闭页面了, `VMware Workstation Pro`除了资源占用多以外, 真的挺好用的.

## 特性

1. 可定制开机启动, 通过修改`wsl.sh`实现. 同时, 可以作为初始化`wsl`使用.
2. 支持安装软件, 通过配置文件`config.yml`中`pkgs`变量.(yaml格式支持不完整,慎用复杂yaml语法. 详细查看[引用与参考](引用与参考))
3. 添加`ssh-key`到`root`用户.
4. 增加`wslip`环境变量,方便`windows`下登录`wsl`:
   - powershell
     ```powershell
     ssh -i \path\to\id_rsa root@$Env:wslip
     ```
   - cmd
     ```batch
     ssh -i \path\to\id_rsa root@%wslip%
     ```

*DOING*
~~1. 通过`ansible-galaxy`部署软件.~~

*TODO*
~~1. 针对中国环境,修改一些访问慢的源(例如: apt, pip).~~

## 安装及使用

1. `git clone https://github.com/opszhou/wsl-scheduled-task`
2. 修改在`config.yml`文件`pkgs`变量, 定义要安装的软件包, 中写要开机启动的`WSL`服务或者执行的命令即可.
3. 进到`C:\wsl-scheduled-task`双击`main.bat`运行脚本添加任务计划.
4. 启动后，通过`powershell`命令`$Env:wslip`获取`wsl2 ip`地址.
5. 通过`ssh`或者`bash`登录`wsl`.

## 配置文件说明

```
is_cn: # 用来判断是否中国境内,改为国内源.
ssh_keys: # `sshkey`只支持一个(毕竟定位是个人的开发环境).
pkgs: # ubuntu软件包名.
services: # ubuntu软件包对应的服务名.
galaxy: # ansible-galaxy.
```

## 引用与参考

1. [yaml.sh](https://raw.githubusercontent.com/jasperes/bash-yaml/master/script/yaml.sh)
