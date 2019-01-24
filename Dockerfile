FROM centos:7

LABEL maintainer "denghc940607@gmail.com"

ENV FASTDFS_SRC_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
	FASTDFS_CONF_PATH=/etc/fdfs \
	HTTP_SERVER_PORT= \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=
	
#get all the dependences
RUN yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget -y

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_SRC_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_SRC_PATH}/fastdfs \
 && mkdir -p ${FASTDFS_SRC_PATH}/fastdfs-nginx-module \
 && mkdir ${FASTDFS_BASE_PATH}
 
#compile the libfastcommon
WORKDIR ${FASTDFS_SRC_PATH}/libfastcommon
RUN git clone --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_SRC_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_SRC_PATH}/libfastcommon
 
#compile the fastdfs
WORKDIR ${FASTDFS_SRC_PATH}/fastdfs
RUN git clone --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_SRC_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_SRC_PATH}/fastdfs
 
#set up fastdfs-nginx-module
WORKDIR ${FASTDFS_SRC_PATH}/fastdfs
RUN git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 ${FASTDFS_SRC_PATH}/fastdfs-nginx-module
COPY conf/*.* ${FASTDFS_CONF_PATH}/

WORKDIR ${FASTDFS_SRC_PATH}
RUN wget http://nginx.org/download/nginx-1.15.4.tar.gz
RUN tar -zxvf nginx-1.15.4.tar.gz
WORKDIR ${FASTDFS_SRC_PATH}/nginx-1.15.4
#add module fastdfs-nginx-module
RUN ./configure --add-module=${FASTDFS_SRC_PATH}/fastdfs-nginx-module/src/ 
RUN make && make install #编译安装

EXPOSE 22122 23000 8080 8888
VOLUME ["$FASTDFS_BASE_PATH", "$FASTDFS_CONF_PATH"] 

COPY start.sh /usr/bin/

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]