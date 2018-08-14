1、es集群可以分布在多台机器，相应的要修改ES_HOST_IP和extra_hosts对应IP和端口
2、es的配置文件elasticsearch.yml要根据实际需要配置gateway.expected_nodes和discovery.zen.ping.unicast.hosts
   gateway.expected_nodes表示节点故障后，只有启动该设置数量的节点，集群才开始恢复并同步数据
   discovery.zen.ping.unicast.hosts表示集群发现机制为多播，主要用于新节点被启动时能够发现广播发起者，可配置所有节点
3、修改es持久化数据属性（optional）
chown -R 1000:1000 ./volumes/elasticsearch/
4、其他配置可默认
5、kibana启动时间较长，因为需要加载xpack等监控工具
