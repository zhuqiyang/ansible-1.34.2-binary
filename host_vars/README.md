# host_vars 目录说明

## 用途

`host_vars` 目录用于定义**特定主机**的变量，这些变量会覆盖 `group_vars` 和 `all.yml` 中的同名变量。

## 变量优先级

在 Ansible 中，变量优先级从高到低为：
1. **host_vars** (最高优先级) - 主机特定变量（如：master1.yml 定义了 inventory/hosts.yml all.masters.hosts.master1 节点的变量）
2. **group_vars** - 组变量（如 masters.yml, workers.yml）
3. **all.yml** - 全局变量（最低优先级）

## 文件命名规则

- 文件名必须与 `inventory/hosts.yaml` 中的主机名完全匹配
- 例如：如果 inventory 中有主机 `master1`，则创建 `host_vars/master1.yml`
- 文件格式：YAML (.yml 或 .yaml)

## 使用场景

1. **主机特定 IP 地址**：每个主机的实际 IP 地址
2. **资源限制**：不同主机的 CPU/内存限制
3. **存储路径**：主机特定的存储配置
4. **标签和污点**：节点特定的 Kubernetes 标签和污点
5. **端口配置**：如果某个主机需要使用不同的端口
6. **覆盖组变量**：为特定主机覆盖组级别的配置

## 示例

查看本目录中的示例文件：
- `master1.yml` - master1 主机的特定配置
- `master2.yml` - master2 主机的特定配置
- `etcd1.yml` - etcd1 节点的特定配置

## 注意事项

- 不是所有主机都需要 host_vars 文件
- 只有当主机需要与组变量不同的配置时，才创建对应的文件
- 保持配置简洁，避免重复定义已在 group_vars 中定义的变量

