#
# Cookbook:: elasticsearch
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package 'default-jdk'

elasticsearch_user 'elasticsearch'

#elasticsearch_install 'elasticsearch'
deploy_stage = File.read("/etc/pipeline.config").chop

elasticsearch_install 'my_es_installation' do
    type 'package'
    version '6.2.3'
    action :install
end

elasticsearch_configure 'elasticsearch' do
configuration ({
    'network.host' => '0.0.0.0',
    'http.port' => 9200,
  })
end

data_bag_info = data_bag_item('adobe_dbag', 'mcmp')
data = data_bag_info['itclouds']['ElasticSearch'][deploy_stage]

execute 'new_data_bag_content' do
    command "echo 'data bag: #{data}' > /etc/app.log"
end

version = data['version']
execute 'app_version' do
    command "echo 'version: #{version}' >> /etc/app.log"
end

app_data = data['app_data']
execute 'app_data_bag_content' do
    command "echo 'app data: #{app_data}' >> /etc/app.log"
end

data_nodes_up = false
master_nodes_up = false
config_master_node = true
until data_nodes_up == true and master_nodes_up == true do

    poll_data = data
    execute 'poll_app_data_bag_content' do
        command "echo 'poll data: #{poll_data}' >> /etc/app.log"
    end

    poll_app_data = poll_data['app_data']
    execute 'data_bag_logs' do
        command "echo 'poll app data: #{poll_app_data}' >> /etc/app.log"
    end

    if poll_app_data.key?("master_nodes") then
        master_nodes_up = true
        if poll_app_data['master_nodes'].include? node[:ipaddress] then

            if config_master_node then
                execute 'config_master_node' do
                    command "echo 'node.master: true' >> /etc/elasticsearch/elasticsearch.yml"
                end
                config_master_node = false
            end
        end

        if poll_app_data.key?("data_nodes") and poll_app_data['data_nodes'].any? then
            data_nodes_up = true
            next
        end

        execute 'sleeping_logs' do
            command "echo 'sleeping for 10 seconds' >> /etc/app.log"
        end
        sleep(10)
    end
end

# Forming the cluster
db_data = data_bag_item('elasticSearch', 'abc')
app_db_data = poll_data['app_data']

master_nodes = app_db_data["master_nodes"]
data_nodes =  app_db_data["data_nodes"]
all_nodes = master_nodes + data_nodes

execute 'configure_cluster' do
    command "echo 'discovery.zen.ping.unicast.hosts: #{all_nodes.to_s}' >> /etc/elasticsearch/elasticsearch.yml"
end

elasticsearch_service 'elasticsearch'
