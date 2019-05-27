# panda-publisher

当前最新版本 V1.0

最初写这个的目的是为了与panda-envshell环境以及对应的积木块框架搭配使用, 用于发布代码.

## 文件及对应功能

文件名|功能
----|----
config|整个脚本的配置文件
publish.sh|发布代码
test.sh|加载所有配置文件并输出所有配置变量和值
repo|所有仓库的配置文件及插件脚本等
inc|通用文件, 包括函数和脚本初始化文件等
tar|仓库导出的 tar 包存放在这里
temp|仓库迁出的代码

所有参数, 都在 repo 对应的文件夹中, 目前添加的都是我自己需要的内容, 如果你有自己的需要, 可以增加内容或者修改对应的文件.

## 使用过程介绍
- 请确保当前用户能够ssh到远端机器, 且程序所在目录可写(用于导出 tar 包和仓库的相关操作).
- 0.基本准备工作.
    - 安装git.
    - 运行 git clone https://github.com/pandajingjing/panda-publisher.git 获取本代码.
- 1.检查相关配置.
    - 检查 ./hosts 文件, 检查远端机器配置(参考 ansible ).
    - 检查 ./config 文件,查看sEnvUser, sEnvGroup 作为运行环境的用户名和用户组, sDeployServer 作为部署的机器分组.
    - 确认相关环境目录.
    - 找到 repo 里面对应仓库, 就能查看具体的配置, 如果没什么特别需求, 就不要改了吧.
- 2.运行 test.sh, 检查你发布的代码的各项配置是否符合你的需要.
- 3.运行 publish.sh 发布对应的代码, 或者回滚.

可以根据你自己的需要发布不同的代码仓库, 发布前都运行一下 test.sh, 确认配置符合你的要求.

注意:

- 我们使用 ansible 应用, 通过 ssh key 的方式控制远程的机器, 所以使用脚本前, 请务必确认环境连同并具备简单的 ansible 知识

## 关于作者

```php
date_default_timezone_set('Asia/Shanghai');

class me extends 码畜
{

    public $_sNickName = 'pandajingjing';

    public $_sWebSite = 'http://www.jxulife.com';

    protected $_iQQ = 18073848;
}
```

## change log
- 20190527 V1.0
    - 1.增加版本回滚功能, 可以回归到上一个版本或者指定版本, 并检查版本是否存在
    - 2.可查看版本号
- 20190524 V0.9.1
    - 1.完善相关功能
    - 2.下一个版本应该增加回滚的功能啦
- 20190510 V0.9
    - 1.封装了代码仓库的操作流程
    - 2.封装了git的具体操作命令
    - 3.可以发布区分版本和唯一版本的代码