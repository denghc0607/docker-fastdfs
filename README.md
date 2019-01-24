# learn from:  https://github.com/luhuiguo/fastdfs-docker

# FastDFS Docker Cluster

Usage:
```
docker run -dti --network=host --name tracker -v /data/fdfs/tracker:/var/fdfs denghc/fastdfs:1.0.0 tracker

docker run -dti --network=host --name storage0 -e TRACKER_SERVER=10.1.5.85:22122,10.1.5.84:22122 -e -v /data/fdfs/storage0:/var/fdfs denghc/fastdfs:1.0.0 storage

docker run -dti --network=host --name storage1 -e TRACKER_SERVER=10.1.5.85:22122 -e -v /data/fdfs/storage1:/var/fdfs denghc/fastdfs:1.0.0 storage

docker run -dti --network=host --name storage2 -e TRACKER_SERVER=10.1.5.85:22122 -e GROUP_NAME=group2 -e PORT=22222 -v /var/fdfs/storage2:/var/fdfs denghc/fastdfs:1.0.0 storage
```

