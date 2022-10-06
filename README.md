## Gon2n ##

**gon2n** 是一款基于 **n2n** 并使用go语言进行封装的点对点快速组网的开源软件工具，由超级节点和边缘节点来构建虚拟局域网，其中包含守护进程组件和实例管理程序，以及额外的用于控制点对网访问的转发程序/脚本。

下载链接: [latest](https://github.com/Droid-MAX/gon2n-deb/releases/latest)

### Gon2n for Windows ###

### 安装与使用 ###

1. 安装虚拟网卡驱动

    下载并解压驱动包 `tap-windows-9.24.6.zip` 后，运行 `install.bat` ，提示安装成功后按回车退出

2. 开始安装

    下载 `gon2n-0.2.1-setup.exe` 安装程序，并双击执行，根据提示选择安装路径并选择下一步直至安装完成(注意: 该安装包使用第三方工具 `nssm` 来实现进程守护及开机自启，且在安装和卸载的过程中会修改部分注册表项目以实现点对网访问)

3. 管理服务

    按下 `Win + R` 组合键，在运行框中输入 `services.msc` 并回车，找到对应的服务名(Edged为边缘节点进程守护服务，Supernoded为超级节点进程守护服务)，点击 `启动` 选项，启动后将会显示其余的控制选项

4. 管理edge实例(边缘节点)

    - 查看当前正在运行的所有edge边缘节点实例

        在cmd终端命令行窗口中执行 `edgectl get` 或 `edgectl g` 命令，若成功执行将会返回如下内容(没有实例运行时)

        ```
        ID      COMMUNITY NAME  LOCAL PORT      SUPERNODE HOST:PORT     ENCRYPTION METHOD       DEVICE NAME
        ```

    - 创建/启动一个edge边缘节点运行实例

        因子命令参数较多，这里可以使用 `edgectl apply -h` 或 `edgectl a -h` 命令，查看帮助参数

        ```
        Flags:
          -u, --edge.MTU int                    The MTU to use. (default 1500)
          -z, --edge.addressMode string         Mode of IP address assignment. "static" is a static assignment, "dhcp" uses the DHCP server at --device-ip (see --dynamic-ip-node). If the edge is running the network's DHCP server, this must be "static". (default "static")
          -p, --edge.allowP2P                   Whether to allow peer-to-peer connections. If false, all traffic will be routed through the supernode. (default true)
          -r, --edge.allowRouting               Whether to allow the node to route traffic to other nodes. (default true)
          -c, --edge.communityName string       The name of the n2n community to join. (default "mynetwork")
          -f, --edge.configFile string          Configuration file to use.
          -i, --edge.deviceIP string            IP address to set. Set to "0.0.0.0" if you are using "dhcp" as --address-mode. If the edge is running the network's DHCP server this must be set explicitly; i.e. to "192.168.1.0" if the DHCP server should give out addresses from "192.168.1.10" to "192.168.1.100". (default "192.168.1.1")
          -x, --edge.deviceMACAddress string    The MAC address to use. Must be unique per edge. (default "DE:AD:BE:EF:01:10")
          -v, --edge.deviceName string          Name of the TUN/TAP device to create. (default "edge0")
          -q, --edge.deviceNetmask string       The netmask to use. (default "255.255.255.0")
          -m, --edge.disableMulticast           Whether to disable multicast.
          -d, --edge.disablePMTUDiscovery       Whether to disable path MTU discovery.
          -y, --edge.dynamicIPMode              Whether the IP address is set dynamically (see --address-mode). If the edge is running the network's DHCP server, this must be false.
          -k, --edge.encryptionKey string       The key to use for encryption. (default "mysecretkey")
          -e, --edge.encryptionMethod int       Method of encryption to use. 1 is no encryption, 2 is Twofish encryption, 3 is AES-CBC encryption. Twofish encryption is the n2n default, but only due to legacy compatibility reasons; AES-CBC is up to ten times faster. (default 2)
          -l, --edge.localPort int              The local port to use. 0 uses any available port.
          -a, --edge.managementPort int         UDP management port. 5644 is the n2n default. (default 5644)
          -n, --edge.registerInterval int       Interval in seconds for both UDP NAT hole punching and registration of the edge on the supernode. (default 1)
          -t, --edge.registerTTL int            Interval in seconds for UDP NAT hole punching through the supernode. (default 1)
          -s, --edge.serverHostPort string      Host:port of the server to use. (default "localhost:10600")
          -w, --edge.supernodeHostPort string   Host:port of the supernode to connect to. (default "localhost:1234")
          -o, --edge.typeOfService int          Type of service to use. (default 16)
          -h, --help                            help for apply
        ```
    
        除了可以逐一指定参数之外还可以使用配置文件来创建边缘节点实例，以下为默认配置

        ```
        edge:
          allowP2P: true
          allowRouting: true
          communityName: mynetwork
          disablePMTUDiscovery: false
          disableMulticast: false
          dynamicIPMode: false
          encryptionKey: mysecretkey
          localPort: 0
          managementPort: 5644
          registerInterval: 1
          registerTTL: 1
          supernodeHostPort: localhost:1234
          typeOfService: 16
          encryptionMethod: 2
          deviceName: edge0
          addressMode: static
          deviceIP: 192.168.1.1
          deviceNetmask: 255.255.255.0
          deviceMACAddress: DE:AD:BE:EF:01:10
          MTU: 1500
        ```

    创建成功后将会提示并返回一个UUID格式的edge边缘节点实例ID，另外需要注意的是在Windows系统中使用时需要将对应网卡设备名的参数改为 `""` ，否则将会出现报错

    - 删除/停止一个edge边缘节点实例

        首先查看当前正在运行的所有edge边缘节点实例以获取 `ID` 号，再使用 `edgectl delete <ID>` 或 `edgectl d <ID>` ，若成功执行将会提示对应ID实例已删除

5. 管理supernode实例(超级节点)

    - 查看当前正在运行的所有supernode超级节点实例

        在cmd终端命令行窗口中执行 `supernodectl get` 或 `supernodectl g` 命令，若成功执行将会返回如下内容(没有实例运行时)

        ```
        ID      LISTEN PORT
        ```

    - 创建/启动一个supernode超级节点运行实例

        因子命令参数较多，这里可以使用 `supernodectl apply -h` 或 `supernodectl a -h` 命令，查看帮助参数

        ```
        Flags:
          -h, --help                              help for apply
          -f, --supernode.configFile string       Configuration file to use.
          -l, --supernode.listenPort int          UDP listen port. (default 1234)
          -m, --supernode.managementPort int      UDP management port. (default 5645)
          -s, --supernode.serverHostPort string   Host:port of the server to use. (default "localhost:10500")
        ```
    
        除了可以逐一指定参数之外还可以使用配置文件来创建超级节点实例，以下为默认配置

        ```
        supernode:
          listenPort: 1234
          managementPort: 5645
        ```

    创建成功后将会提示并返回一个UUID格式的supernode超级节点实例ID，如需开放外网访问请自行调整防火墙策略

    - 删除/停止一个supernode超级节点实例

        首先查看当前正在运行的所有supernode超级节点实例以获取 `ID` 号，再使用 `supernodectl delete <ID>` 或 `supernodectl d <ID>` ，若成功执行将会提示对应ID实例已删除

6. 查看运行日志

    - 日志路径
    
        默认日志保存路径为软件安装目录的 `logs` 文件夹中，默认每隔24小时或每增长1MB会自动轮转保存(注意:请勿删除或修改 `logs` 文件夹，否则将会影响正常的日志记录功能)

### 点对网配置 ###

1. 配置edge点对网访问(被访问端)

    - 创建edge实例

    - 配置网络共享
    
        使用管理员身份启动 `cmd` 命令提示符窗口，执行 `ipconfig /all` 查找并确定edge实例所使用的虚拟网卡名称及本地物理网卡名称，然后执行 `netshare "本地物理网卡名称" "edge实例所使用的虚拟网卡名称"`

        如需关闭网络共享则需手动关闭，按下 `Win + R` 组合键，在运行框中输入 `ncpa.cpl` 并回车，右键本地的物理网卡，在属性的共享选项卡中取消勾选相关选项

2. 配置edge点对网访问(访问端)

    - 创建edge实例

    - 添加路由规则(推荐)

        使用管理员身份启动 `cmd` 命令提示符窗口，执行 `route add "目标网络IP" mask "目标网络掩码" "网关地址"` ，若想添加永久路由规则，附加 `-p` 参数

        网关地址为被访问端的IP地址
    
    - 删除路由规则

        使用管理员身份启动 `cmd` 命令提示符窗口，执行 `route delete "目标网络IP" mask "目标网络掩码" "网关地址"`

    - 指定虚拟网卡网关地址为被访问端IP(不推荐)

        按下 `Win + R` 组合键，在运行框中输入 `ncpa.cpl` 并回车，右键edge实例所使用的虚拟网卡，在属性的IPv4选项中手动指定 `默认网关` 的地址为被访问端的IP地址

### Gon2n for Linux ###

### 安装与使用 ###

1. 下载及安装

    选择并下载合适的系统版本的软件包，例如 `gon2n-0.2.1-x86_64.deb` ，使用 `sudo dpkg -i gon2n-0.2.1-x86_64.deb` 命令进行安装(注意：该软件包依赖 `uml-utilities` 软件包)

2. 管理服务

    安装完毕后，默认将守护进程服务设为开机自启，也可以手动启动守护进程服务 `sudo systemctl start edged.service` ，超级节点同理 `sudo systemctl start supernoded.service`

    重启服务 `sudo systemctl restart edged.service`

    停止服务 `sudo systemctl stop edged.service`

    查看运行状态 `sudo systemctl status edged.service`
    
    此外控制程序也有对应的 `Oneshot` 类型服务，可以按需手动将控制程序服务设为开机自启 `sudo systemctl enable edge.service` ，控制程序将会在守护进程服务启动或重启后执行一次

    禁用开机自启 `sudo systemctl disable edge.service`

3. 管理edge实例(边缘节点)

    - 查看当前正在运行的所有edge边缘节点实例

        在cmd终端命令行窗口中执行 `edgectl get` 或 `edgectl g` 命令，若成功执行将会返回如下内容(没有实例运行时)

        ```
        ID      COMMUNITY NAME  LOCAL PORT      SUPERNODE HOST:PORT     ENCRYPTION METHOD       DEVICE NAME
        ```

    - 创建/启动一个edge边缘节点运行实例

        因子命令参数较多，这里可以使用 `edgectl apply -h` 或 `edgectl a -h` 命令，查看帮助参数

        ```
        Flags:
          -u, --edge.MTU int                    The MTU to use. (default 1500)
          -z, --edge.addressMode string         Mode of IP address assignment. "static" is a static assignment, "dhcp" uses the DHCP server at --device-ip (see --dynamic-ip-node). If the edge is running the network's DHCP server, this must be "static". (default "static")
          -p, --edge.allowP2P                   Whether to allow peer-to-peer connections. If false, all traffic will be routed through the supernode. (default true)
          -r, --edge.allowRouting               Whether to allow the node to route traffic to other nodes. (default true)
          -c, --edge.communityName string       The name of the n2n community to join. (default "mynetwork")
          -f, --edge.configFile string          Configuration file to use.
          -i, --edge.deviceIP string            IP address to set. Set to "0.0.0.0" if you are using "dhcp" as --address-mode. If the edge is running the network's DHCP server this must be set explicitly; i.e. to "192.168.1.0" if the DHCP server should give out addresses from "192.168.1.10" to "192.168.1.100". (default "192.168.1.1")
          -x, --edge.deviceMACAddress string    The MAC address to use. Must be unique per edge. (default "DE:AD:BE:EF:01:10")
          -v, --edge.deviceName string          Name of the TUN/TAP device to create. (default "edge0")
          -q, --edge.deviceNetmask string       The netmask to use. (default "255.255.255.0")
          -m, --edge.disableMulticast           Whether to disable multicast.
          -d, --edge.disablePMTUDiscovery       Whether to disable path MTU discovery.
          -y, --edge.dynamicIPMode              Whether the IP address is set dynamically (see --address-mode). If the edge is running the network's DHCP server, this must be false.
          -k, --edge.encryptionKey string       The key to use for encryption. (default "mysecretkey")
          -e, --edge.encryptionMethod int       Method of encryption to use. 1 is no encryption, 2 is Twofish encryption, 3 is AES-CBC encryption. Twofish encryption is the n2n default, but only due to legacy compatibility reasons; AES-CBC is up to ten times faster. (default 2)
          -l, --edge.localPort int              The local port to use. 0 uses any available port.
          -a, --edge.managementPort int         UDP management port. 5644 is the n2n default. (default 5644)
          -n, --edge.registerInterval int       Interval in seconds for both UDP NAT hole punching and registration of the edge on the supernode. (default 1)
          -t, --edge.registerTTL int            Interval in seconds for UDP NAT hole punching through the supernode. (default 1)
          -s, --edge.serverHostPort string      Host:port of the server to use. (default "localhost:1060")
          -w, --edge.supernodeHostPort string   Host:port of the supernode to connect to. (default "localhost:1234")
          -o, --edge.typeOfService int          Type of service to use. (default 16)
          -h, --help                            help for apply
        ```
    
        除了可以逐一指定参数之外还可以使用配置文件来创建边缘节点实例，以下为默认配置

        ```
        edge:
          allowP2P: true
          allowRouting: true
          communityName: mynetwork
          disablePMTUDiscovery: false
          disableMulticast: false
          dynamicIPMode: false
          encryptionKey: mysecretkey
          localPort: 0
          managementPort: 5644
          registerInterval: 1
          registerTTL: 1
          supernodeHostPort: localhost:1234
          typeOfService: 16
          encryptionMethod: 2
          deviceName: edge0
          addressMode: static
          deviceIP: 192.168.1.1
          deviceNetmask: 255.255.255.0
          deviceMACAddress: DE:AD:BE:EF:01:10
          MTU: 1500
        ```

    创建成功后将会提示并返回一个UUID格式的edge边缘节点实例ID

    - 删除/停止一个edge边缘节点实例

        首先查看当前正在运行的所有edge边缘节点实例以获取 `ID` 号，再使用 `edgectl delete <ID>` 或 `edgectl d <ID>` ，若成功执行将会提示对应ID实例已删除

4. 管理supernode实例(超级节点)

    - 查看当前正在运行的所有supernode超级节点实例

        在cmd终端命令行窗口中执行 `supernodectl get` 或 `supernodectl g` 命令，若成功执行将会返回如下内容(没有实例运行时)

        ```
        ID      LISTEN PORT
        ```

    - 创建/启动一个supernode超级节点运行实例

        因子命令参数较多，这里可以使用 `supernodectl apply -h` 或 `supernodectl a -h` 命令，查看帮助参数

        ```
        Flags:
          -h, --help                              help for apply
          -f, --supernode.configFile string       Configuration file to use.
          -l, --supernode.listenPort int          UDP listen port. (default 1234)
          -m, --supernode.managementPort int      UDP management port. (default 5645)
          -s, --supernode.serverHostPort string   Host:port of the server to use. (default "localhost:1050")
        ```
    
        除了可以逐一指定参数之外还可以使用配置文件来创建超级节点实例，以下为默认配置

        ```
        supernode:
          listenPort: 1234
          managementPort: 5645
        ```

    创建成功后将会提示并返回一个UUID格式的supernode超级节点实例ID，如需开放外网访问请自行调整防火墙策略

    - 删除/停止一个supernode超级节点实例

        首先查看当前正在运行的所有supernode超级节点实例以获取 `ID` 号，再使用 `supernodectl delete <ID>` 或 `supernodectl d <ID>` ，若成功执行将会提示对应ID实例已删除

5. 查看运行日志

    - edged

        查看edged守护进程实时日志记录 `journalctl -u edged -f`

    - supernoded

        查看supernoded守护进程实时日志记录 `journalctl -u supernoded -f`

### 点对网配置 ###

1. 配置edge点对网访问(被访问端)

    - 创建edge实例

    - 配置流量转发
    
        使用 `ifconfig` 命令查找并确定edge实例所使用的虚拟网卡名称及本地物理网卡名称，然后执行 `forward.sh enable "本地物理网卡名称" "edge实例所使用的虚拟网卡名称"`

        如需禁用流量转发可以执行 `forward.sh disable "本地物理网卡名称" "edge实例所使用的虚拟网卡名称"` 命令

2. 配置edge点对网访问(访问端)

    - 创建edge实例

    - 添加路由规则(推荐)

        执行 `sudo route add -net "目标网络IP" netmask "目标网络掩码" gw "网关地址"`

        网关地址为被访问端的IP地址
    
    - 删除路由规则

        执行 `sudo route del -net "目标网络IP" netmask "目标网络掩码"`

    - 修改默认网关(不推荐)

        执行 `sudo route add default gw "网关地址"`

        网关地址为被访问端的IP地址
