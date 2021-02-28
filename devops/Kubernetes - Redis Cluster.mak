apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-01
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/redis01"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-02
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/redis02"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-03
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/redis03"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-04
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/redis04"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-05
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/redis05"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv-06
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /redis06
---
apiVersion: v1
kind: Service
metadata:
  name: redis-cluster-service
spec:
  selector:
    app: redis-cluster
  ports:
    - name: client
      port: 6379
      targetPort: 6379
    - name: gossip
      port: 16379 
      targetPort: 16379
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  selector:
    matchLabels:
      app: redis-cluster 
  serviceName: "redis-cluster-service"
  replicas: 6
  template:
    metadata:
      labels:
        app: redis-cluster
    spec:
      containers:
      - name: redis-container
        image: redis:5.0.1-alpine
        command: ["/conf/update-node.sh", "redis-server", "/conf/redis.conf"]
        env:
        - name: POD_IP 
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        ports:
        - containerPort: 6379
          name: client
        - containerPort: 16379
          name: gossip
        volumeMounts:
        - name: conf
          mountPath: /conf
          readOnly: false
        - name: data
          mountPath: /data
          readOnly: false
      volumes:
       - name: conf
         configMap:
           name: redis-cluster-configmap
           defaultMode: 0755
  volumeClaimTemplates:
  - metadata:
      name: data 
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "manual"
      resources:
        requests:
          storage: 1Gi