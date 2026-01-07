#!/bin/bash

proxy_url=https://gh-proxy.org/

k8s_version=v1.34.3
cfssl_version=1.6.5
cri_dockerd_version=0.3.20
etcd_version=3.6.4
cni_version=1.7.1
nerdctl_version=2.2.1
crictl_version=1.34.0
containerd_version=2.0.5
runc_version=1.1.12
cilium_version=0.18.9

# 所有下载的文件统一放在当前目录下的 download 目录中
DOWNLOAD_DIR="$(pwd)/download"
mkdir -p "${DOWNLOAD_DIR}"


if [ ! -f "${DOWNLOAD_DIR}/cfssl" ]; then
    wget -O "${DOWNLOAD_DIR}/cfssl" "${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_amd64"
    chmod +x "${DOWNLOAD_DIR}/cfssl"
    cp -r "${DOWNLOAD_DIR}/cfssl" /usr/local/bin/
fi

if [ ! -f "${DOWNLOAD_DIR}/cfssljson" ]; then
    wget -O "${DOWNLOAD_DIR}/cfssljson" "${proxy_url}https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_amd64"
    chmod +x "${DOWNLOAD_DIR}/cfssljson"
    cp -r "${DOWNLOAD_DIR}/cfssljson" /usr/local/bin/
fi

if [ ! -f "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz" ]; then
    wget -O "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz" "${proxy_url}https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"
    if [ ! -f "${DOWNLOAD_DIR}/cri-dockerd" ]; then
        tar -xf "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz" -C "${DOWNLOAD_DIR}"
        mv "${DOWNLOAD_DIR}/cri-dockerd" "${DOWNLOAD_DIR}/cridockerd"
        cp "${DOWNLOAD_DIR}/cridockerd/cri-dockerd" ${DOWNLOAD_DIR}/cri-dockerd
        rm "${DOWNLOAD_DIR}/cridockerd/" -rf
        #rm -rf "${DOWNLOAD_DIR}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"
    fi
fi


if [ ! -f "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" "${proxy_url}https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/etcd" ]; then
        tar -xf "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}/"
        mv "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64"/{etcd,etcdctl,etcdutl} "${DOWNLOAD_DIR}/"
        # rm "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64.tar.gz" -rf
        rm "${DOWNLOAD_DIR}/etcd-v${etcd_version}-linux-amd64" -rf
    fi
fi


if [ ! -f "${DOWNLOAD_DIR}/cni-plugins-linux-amd64-v${cni_version}.tgz" ]; then
    wget -O "${DOWNLOAD_DIR}/cni-plugins-linux-amd64-v${cni_version}.tgz" "${proxy_url}https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-amd64-v${cni_version}.tgz"
fi


if [ ! -f "${DOWNLOAD_DIR}/kubernetes-server-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/kubernetes-server-linux-amd64.tar.gz" "https://dl.k8s.io/${k8s_version}/kubernetes-server-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/kube-apiserver" ]; then
        tar -xf "${DOWNLOAD_DIR}/kubernetes-server-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
        cp "${DOWNLOAD_DIR}/kubernetes/server/bin"/{kube-apiserver,kube-controller-manager,kubectl,kubelet,kube-proxy,kube-scheduler} "${DOWNLOAD_DIR}"
        cp "${DOWNLOAD_DIR}/kubernetes/server/bin/kubectl" /usr/local/bin/
        rm -rf "${DOWNLOAD_DIR}/kubernetes"
    fi
fi


if [ ! -f "${DOWNLOAD_DIR}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz" "${proxy_url}https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/nerdctl" ]; then
        tar -xf "${DOWNLOAD_DIR}/nerdctl-${nerdctl_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
    fi
fi


if [ ! -f "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64.tar.gz" "${proxy_url}https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_version}/crictl-v${crictl_version}-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/crictl" ]; then
        tar -xf "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
        mv "${DOWNLOAD_DIR}/crictl-v${crictl_version}-linux-amd64"/{crictl,critest} "${DOWNLOAD_DIR}/"
    fi
fi

if [ ! -f "${DOWNLOAD_DIR}/containerd-${containerd_version}-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/containerd-${containerd_version}-linux-amd64.tar.gz" "${proxy_url}https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/containerd" ]; then
        tar -xf "${DOWNLOAD_DIR}/containerd-${containerd_version}-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
        mv "${DOWNLOAD_DIR}/bin"/{containerd,containerd-shim-runc-v2,containerd-stress,ctr} "${DOWNLOAD_DIR}/"
        rm -rf "${DOWNLOAD_DIR}/bin"
    fi
fi


if [ ! -f "${DOWNLOAD_DIR}/runc" ]; then
    wget -O "${DOWNLOAD_DIR}/runc" "${proxy_url}https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"
    chmod +x "${DOWNLOAD_DIR}/runc"
fi


if [ ! -f "${DOWNLOAD_DIR}/cilium-linux-amd64.tar.gz" ]; then
    wget -O "${DOWNLOAD_DIR}/cilium-linux-amd64.tar.gz" "${proxy_url}https://github.com/cilium/cilium-cli/releases/download/v${cilium_version}/cilium-linux-amd64.tar.gz"
    if [ ! -f "${DOWNLOAD_DIR}/cilium" ]; then
        tar -xf "${DOWNLOAD_DIR}/cilium-linux-amd64.tar.gz" -C "${DOWNLOAD_DIR}"
    fi
fi