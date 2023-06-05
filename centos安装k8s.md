# centos安装kubernetes

### 关闭防火墙

```shell
systemctl stop firewalld
systemctl disable firewalld
```

### 禁用SELINUX

```shell
# 临时禁用
setenforce 0

# 永久禁用 
vim /etc/selinux/config    # 或者修改/etc/sysconfig/selinux
SELINUX=disabled
```

### 修改k8s.conf文件

```shell
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
```

### 关闭swap

```shell
# 临时关闭
swapoff -a

# 永久关闭
vim /etc/fstab
# 注释以下一行
/dev/mapper/cl-swap     swap                    swap    defaults        0 0
```

### 安装最新的docker

```shell
# 删除老版本的docker
sudo yum remove docker \
           docker-common \
           docker-selinux \
           docker-engine

# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装 Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce docker-ce-selinux
# Step 4: 开启Docker服务
sudo systemctl enable docker && sudo systemctl start docker
```

### 校验docker安装

```shell
docker version
# 出现如下表示正确
Client:
 Version:      17.03.2-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   f5ec1e2
 Built:        Tue Jun 27 02:21:36 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.03.2-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   f5ec1e2
 Built:        Tue Jun 27 02:21:36 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

### 修改yum安装源

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

### 安装flannel、kubeadm、kubectl、kubelet

```shell
sudo yum install -y flannel kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

### 初始化kubernetes

```shell
sudo kubeadm init --apiserver-advertise-address 0.0.0.0 --pod-network-cidr 10.244.0.0/16  --kubernetes-version v1.20.4 
### 安装结束后，会给你一些提示命令，直接按照结果中给出的复制粘贴执行就行，大致是如下命令：
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 新加入一个节点

在主节点上运行命令`kubeadm token list`获取token，然后在从机上运行如下命令：

```shell
kubeadm join –token <token> <主服务器ip或域名>:6443
```

### 安装flannel

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 错误异常处理

如果出现codedns或flannel的错误，导致kubernetes无法正常运行，则依次删除codedns和flannel对应的pod，再次查看状态，大部分情况下会恢复正常，如果未恢复正常，则运行`kubeadm reset`，然后重新使用`kubeadm init`进行安装。


--------------------------------


### kubernetes 在pod内无法ping通servicename和ClusterIP的问题解决

需要使用 ipvs 替换iptables，操作是在所有节点上，开启内核支持：

```shell
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
 
sysctl -p
```

开启ipvs支持：

```shell
yum -y install ipvsadm  ipset
 
# 临时生效
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
 
# 永久生效
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
```

配置kube-proxy，在master上操作，因使用kubeadmin安装，所以操作方式如下：

```shell
kubectl edit cm kube-proxy -n kube-system

# 找到如下配置片段
...
    ipvs:
      excludeCIDRs: null
      minSyncPeriod: 0s
      scheduler: ""
      syncPeriod: 30s
    kind: KubeProxyConfiguration
    metricsBindAddress: 127.0.0.1:10249
    mode: "ipvs"                  #修改
...
```

在master重启kube-proxy：

```shell
kubectl  get pod -n kube-system | grep kube-proxy | awk '{print $1}' | xargs kubectl delete pod -n kube-system
```

