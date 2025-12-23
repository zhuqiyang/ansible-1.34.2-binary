# Kubernetes 二进制安装 Ansible Playbook

本项目用于通过 Ansible 自动化安装二进制版本的 Kubernetes 集群，高可用（HA）部署。


## 目录结构

```
.
├── ansible.cfg              # Ansible 配置文件
├── inventory/               # 主机清单目录
│   └── hosts.yml           # 主机清单文件（YAML 格式）
├── playbooks/              # Playbook 目录
│   ├── generate-config.yml # 生成配置文件（证书和 kubeconfig）
│   ├── install-master.yml  # 安装 Master 节点
│   └── install-worker.yml  # 安装 Worker 节点
├── roles/                  # 角色目录
│   ├── configure/         # 配置生成角色（证书和 kubeconfig）
│   ├── init-system/       # 系统初始化角色
│   ├── docker/            # Docker 安装和配置
│   ├── containerd/        # Containerd 安装和配置
│   ├── etcd/              # etcd 集群部署
│   ├── keepalived/        # Keepalived 高可用
│   ├── haproxy/           # HAProxy 负载均衡
│   ├── kube-apiserver/    # API Server 组件
│   ├── kube-controller-manager/ # Controller Manager 组件
│   ├── kube-scheduler/    # Scheduler 组件
│   ├── kubelet/           # Kubelet 组件
│   ├── kube-proxy/        # Kube-proxy 组件
│   └── addons/            # 插件安装（CoreDNS 等）
├── group_vars/            # 组变量目录
│   ├── all.yml           # 全局变量
│   ├── masters.yml       # Master 节点变量
│   └── workers.yml       # Worker 节点变量
├── host_vars/            # 主机变量目录
├── files/                # 文件目录
│   ├── download/         # 下载的二进制文件（已忽略）
│   └── download.sh       # 下载脚本
└── templates/            # 模板目录（Jinja2 模板）
```

## 系统要求

### 控制节点（Ansible 控制机）

- Ansible >= 2.9
- Python >= 3.6
- SSH 访问目标节点
- 脚本会自动安装 `cfssl`、`cfssljson`、`kubectl` 命令行工具

### 目标节点（Kubernetes 节点）

- Ubuntu 24.04.2 LTS
- 4GB+ RAM（推荐 4GB+）
- 2+ CPU 核心
- 20GB+ 磁盘空间
- 网络互通
- SSH 访问权限（root 或具有 sudo 权限的用户）

## 快速开始

### 1. 配置主机清单

编辑 `inventory/hosts.yml` 文件，填入实际的服务器 IP 地址和主机名：

```yaml
masters:
  hosts:
    master1:
      ansible_host: 192.168.0.112
      hostname: 'master01.k8s.local'
      etcd_hostname: 'etcd01.k8s.local'
    master2:
      ansible_host: 192.168.0.113
      hostname: 'master02.k8s.local'
      etcd_hostname: 'etcd02.k8s.local'
    master3:
      ansible_host: 192.168.0.114
      hostname: 'master03.k8s.local'
      etcd_hostname: 'etcd03.k8s.local'

etcd:
  hosts:
    etcd1:
      ansible_host: 192.168.0.112
      etcd_hostname: 'etcd01.k8s.local'
    # ... 其他 etcd 节点
```

### 2. 配置变量

根据实际环境修改 `group_vars/all.yml` 文件中的变量：

### 3. 下载二进制文件

在控制节点执行下载脚本：

```bash
cd files
bash download.sh
```

脚本会自动下载以下组件到 `files/download/` 目录：
- Kubernetes 二进制文件
- etcd 二进制文件
- CNI 插件
- cri-dockerd
- cfssl 和 cfssljson

### 4. 生成配置文件

在控制节点执行，生成 SSL 证书和 kubeconfig 文件：

```bash
ansible-playbook playbooks/generate-config.yml
```

生成的配置文件会保存在 `files/generate/` 目录中：
- `etcd/`: etcd 证书
- `k8s/`: Kubernetes 证书
- `kubeconfigs/`: kubeconfig 文件

### 5. 安装 Master 节点

```bash
ansible-playbook playbooks/install-master.yml
```

此 playbook 会执行以下操作：
1. 系统初始化（主机名、时区、防火墙、swap 等）
2. 安装 Docker 或 Containerd
3. 部署 etcd 集群
4. 配置 Keepalived + HAProxy
5. 安装 Kubernetes Master 组件
6. 部署 CoreDNS 等插件

### 6. 安装 Worker 节点

```bash
ansible-playbook playbooks/install-worker.yml
```

此 playbook 会执行以下操作：
1. 系统初始化
2. 安装 Docker
3. 安装 Kubelet 和 Kube-proxy

## 详细配置说明

### 网络配置

在 `group_vars/all.yml` 中配置：

```yaml
# Pod 网络
pod_network: '10.244.0.0/16'

# Service 网络
service_network: '172.16.0.0/16'

# DNS 集群 IP
dns_clusterip: '172.16.0.10'
```

### 高可用配置

```yaml
# Keepalived VIP
keepalived_vip: '192.168.0.119'
keepalived_vip_netmask: '24'
keepalived_router_id: '108'

# 负载均衡主机名
COMMON_LOAD_BALANCE_HOSTNAME: 'master.k8s.local'
COMMON_LOAD_BALANCE_PORT: '8443'
```

### 容器运行时

支持 Docker 和 Containerd，在 `group_vars/all.yml` 中配置：

```yaml
container_runtime: 'docker'  # 或 'containerd'
docker_data_root: '/var/lib/docker'
```

## 验证安装

### 检查集群状态

在 Master 节点执行：

```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```

### 检查 etcd 集群

```bash
etcdctl --endpoints='etcd01.k8s.local:2379,etcd02.k8s.local:2379,etcd03.k8s.local:2379' \
  --cacert=/etc/etcd/ssl/etcd-ca.pem \
  --cert=/etc/etcd/ssl/etcd.pem \
  --key=/etc/etcd/ssl/etcd-key.pem \
  endpoint status
```

### 检查节点状态文件

安装过程中会在 `/root/.state/` 目录创建状态文件：
- `initok`: 系统初始化完成
- `certok`: 证书生成完成
- `dockerok`: Docker 安装完成
- `etcdok`: etcd 安装完成
- `kube-apiserverok`: API Server 安装完成
- 等等...


## 注意事项

- ⚠️ 首次安装会自动重启节点（系统初始化后）
- ⚠️ 确保所有节点时间同步
- ⚠️ 确保防火墙规则允许必要的端口
- ⚠️ `files/download/` 目录已添加到 `.gitignore`，不会提交到 Git
- ⚠️ 生产环境请修改默认密码和密钥

## 版本信息

- Kubernetes: v1.34.3
- etcd: v3.6.4
- CNI: v1.7.1
- cri-dockerd: v0.3.20
- cfssl: v1.6.5

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎提交 Issue 和 Pull Request。

## 联系方式

如有问题，请提交 Issue 或联系维护者。

