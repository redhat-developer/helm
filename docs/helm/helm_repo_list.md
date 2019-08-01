## helm repo list

List chart repositories

### Synopsis

List chart repositories

```
helm repo list [flags]
```

### Options

```
  -h, --help   help for list
```

### Options inherited from parent commands

```
      --debug                           Enable verbose output
      --home string                     Location of your Helm config. Overrides $HELM_HOME (default "~/.helm")
      --host string                     Address of Tiller. Overrides $HELM_HOST
      --kube-context string             Name of the kubeconfig context to use
      --kubeconfig string               Absolute path of the kubeconfig file to be used
      --tiller-connection-timeout int   The duration (in seconds) Helm will wait to establish a connection to Tiller (default 300)
      --tiller-namespace string         Namespace of Tiller (default "kube-system")
```

### SEE ALSO

* [helm repo](helm_repo.md)	 - Add, list, remove, update, and index chart repositories

###### Auto generated by spf13/cobra on 16-May-2019