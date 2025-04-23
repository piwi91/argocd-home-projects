# Node configuration

## Open files and user watchces

Argo Events and Argo Workflows require greater maximum user instances and user watches on the Kubernetes nodes that run these pods.

```
sysctl fs.inotify.max_user_instances=1280
sysctl fs.inotify.max_user_watches=655360
```
