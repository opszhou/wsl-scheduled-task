# 启动WSL服务计划任务

本文使用开启开发者模式的`Windows 20H2`版本，基于`WSL2`, 支持在`Windows`启动时启动`WSL`中的`Linux`服务或者执行命令. 没仔细测试, 可能存在bug.

## 为什么要折腾WSL？

首先, 对新鲜事物的好奇心驱使.
其次, 一直在关注`wsl`, 想尝试一下能否替代的`VMware Workstation Pro`.
如果, 以上对你没啥吸引力, 那么可以关闭页面了, `VMware Workstation Pro`除了资源占用多以外, 真的挺好用的.

## 特性

1. 可定制开机启动, 通过修改`wsl.sh`实现. 同时, 可以作为初始化`wsl`使用.
2. 支持安装软件, 通过配置文件`config.yml`中`pkgs`变量.(yaml格式支持不完整,慎用复杂yaml语法. 详细查看[引用与参考](引用与参考))
3. 添加`ssh-key`到`root`用户.
4. 增加`wslip`环境变量,方便`windows`下登录`wsl`: `ssh -i \path\to\id_rsa root@$Env:wslip`.


## 安装及使用


* 使用`git clone`到`C:\wsl-scheduled-task`
``` bash
git clone https://github.com/opszhou/wsl-scheduled-task
```

1. 进到`C:\wsl-scheduled-task`双击`main.bat`运行脚本添加任务计划.
2. 在`services.sh`写要开机启动的`WSL`服务或者执行的命令即可.
3. 启动后，通过`powershell`命令`$Env:wslip`获取`wsl2 ip`地址
4. `ssh -i \path\to\id_rsa <user>@$Env:wslip`登录`wsl`

## 引用与参考

1. [yaml.sh](https://raw.githubusercontent.com/jasperes/bash-yaml/master/script/yaml.sh)
