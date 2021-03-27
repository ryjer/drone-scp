# drone-scp
Copy files using Drone CI.

![buildx](https://github.com/ryjer/drone-scp/workflows/buildx-latest/badge.svg)
[![Docker Pulls](https://img.shields.io/docker/pulls/ryjer/drone-scp.svg)](https://hub.docker.com/r/ryjer/drone-scp/)
[![micro badger](https://images.microbadger.com/badges/image/ryjer/drone-scp.svg)](https://microbadger.com/images/ryjer/drone-scp "Get your own image badge on microbadger.com")

## Usage
```bash
  - name: scp files
    image: ryjer/drone-scp
    settings:
      host:
        - example.com
        - 10.0.0.1
      username: root
      password:
        from_secret: ssh_password
      port: 22
      rm: true
      source:
        - ./hello.txt
        - hi
        - src/t*
      target: 
        - /home/me/hello
        - /var/hhi
        - /root/src/
```
It is same as
```bash
scp -r -P 22 ./hello.txt  root@example.com:/home/me/hello
scp -r -P 22 hello  root@example:/var/hhi
scp -r -P 22 src/t*  root@example:/root/src/

scp -r -P 22 ./hello.txt root@10.0.0.1:/home/me/hello
scp -r -P 22 hello root@10.0.0.1:/var/hhi
scp -r -P 22 src/t* root@10.0.0.1:/root/src/
```

## 用法
```bash
  - name: scp 文件传输
    image: ryjer/drone-scp
    settings:
      host:
        - example.com
        - 10.0.0.1
      port: 22
      username: root
      password:
        from_secret: ssh_password
      rm: true
      source:
        - ./hello.txt
        - hi
        - src/t*
      target: 
        - /home/me/hello
        - /var/hhi
        - /root/src/
```
以上 drone step 对应的scp命令如下
```bash
scp -r -P 22 ./hello.txt  root@example.com:/home/me/hello
scp -r -P 22 hello  root@example:/var/hhi
scp -r -P 22 src/t*  root@example:/root/src/

scp -r -P 22 ./hello.txt  root@10.0.0.1:/home/me/hello
scp -r -P 22 hello  root@10.0.0.1:/var/hhi
scp -r -P 22 src/t*  root@10.0.0.1:/root/src/
```
### 参数说明
**host 主机列表**：  用于表示传输的目标主机，支持多个主机，单这些主机的端口号(port)、用户名(username)、密码(password)必须相同

**port 端口号**：  scp 连接的目标主机的端口号，通常与 ssh 的端口号相同

**username 用户名**：  目标主机的用户名，与ssh登录用户名相同

**password 登录密码**：  目标主机的登录密码，与ssh登录的密码相同。暂不支持密钥等其他方式登录

**rm 目标文件删除标记**：  用于指示是否在 scp 传输前将目标主机上的目标目录（target 列表）删除清空

**source 源文件列表**：  要传输到目标主机的文件或文件夹列表，与目标路径列表target一一对应。

**target 目标文件列表**：  源文件列表传输到目标主机上的对应路径，与源文件列表一一对应。

### 使用提示
本工具是对 scp 命令的封装，scp的源目标文件列表支持相对路径，单目标文件列表只支持**绝对路径**；

本工具只支持从本地向远处主机传送文件，暂不支持从远程主机下载文件

以上host source target 参数中不得存在逗号","。否则会因 drone 的传参机制和解析机制导致异常截断
