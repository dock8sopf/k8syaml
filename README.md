# k8syaml
开放平台的k8s配置文件，采用如下命令逐一拉取配置文件：
```shell
kubectl apply -f fileUrl
```
## 此文件夹存储k8s项目的各种配置文件
## 项目结构
```
.
├── openplatform
│   ├── openplatform.yaml     // namespace.yaml
│   └── pods
│       └── opengateway.yaml  // pods.yaml
└── readme.md
```

如果想要通过配置ingress的方式进行7层代理，需要配置nginx的相关k8s插件。
