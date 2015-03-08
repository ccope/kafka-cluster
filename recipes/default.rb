#
# Cookbook Name:: kafka-cluster
# Recipe:: default
#
# Copyright (c) 2015 Cam Cope, All Rights Reserved.
#

ips = %w(10.0.3.8 10.0.3.247 10.0.3.207)

#"S:1:10.0.3.8,S:2:10.0.3.247,S:3:10.0.3.207"
node.normal[:exhibitor][:config][:servers_spec] = ips.each_with_index.collect {|v, i| "S:#{i+1}:#{v}"}.join(",")
node.normal[:kafka][:automatic_start] = true
node.normal[:kafka][:automatic_restart] = true
#'10.0.3.8:2181,10.0.3.247:2181,10.0.3.207:2181/kafka'
node.normal[:kafka][:broker][:'zookeeper.connect'] = ips.collect {|x| x + ":2181"}.join(",") + "/kafka"
node.normal[:kafka][:broker][:port] = 9092
node.normal[:kafka][:ulimit_file] = 128000
node.normal[:zookeeper][:config][:dataLogDir] = '/tmp/zookeeper'
node.normal[:zookeeper][:config][:dataDir] = '/var/lib/zookeeper'

#{
#  :'server.3' => "10.0.3.207:2888:3888",
#  :'server.2' => "10.0.3.247:2888:3888",
#  :'server.1' => "10.0.3.8:2888:3888",
#}
serverlist = {}
ips.each_with_index {|v, i| serverlist[:"server.#{i+1}"] = "#{v}:2888:3888"}
config_hash = {
  clientPort: 2181, 
  dataDir: node[:zookeeper][:config][:dataDir],
  dataLogDir: node[:zookeeper][:config][:dataLogDir],
  tickTime: 2000,
  initLimit: 10,
  synclimit: 5,
}
config_hash.merge!(serverlist)

node_id = 1 + ips.index(node[:ipaddress])

file "#{config_hash['dataDir']}/myid" do
  action :create_if_missing
  content node_id.to_s
  user 'zookeeper'
  group 'zookeeper'
  mode 00640
end

zookeeper_config '/opt/zookeeper/zookeeper-3.4.6/conf/zoo.cfg' do
  config config_hash
  user   'zookeeper'
  action :render
end

include_recipe "exhibitor"
include_recipe "exhibitor::service"
include_recipe "kafka"

service "kafka" do
  action :enable
end
