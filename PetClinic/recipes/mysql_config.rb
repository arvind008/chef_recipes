mysql_app_name=""
project_name=""
deploy_stage=""
SF_app_name=""
chef_secret_key_loc=""
File.open('/etc/petclinic.config', 'r') do |file|
  file.each_line do |line|
    line_data = line.split('=')
    if line_data[0].match('mysql_app_name')
        mysql_app_name=line_data[1].chop
    elsif line_data[0].match('project_name')
        project_name=line_data[1].chop
    elsif line_data[0].match('pipeline_stage')
        deploy_stage=line_data[1].chop
    elsif line_data[0].match('sf_app_name')
        SF_app_name=line_data[1].chop
    elsif line_data[0].match('chef_secret_key_loc')
        chef_secret_key_loc=line_data[1].chop
    end
  end
end

puts mysql_app_name
puts project_name
puts deploy_stage
puts chef_secret_key_loc

my_secret_key = Chef::EncryptedDataBagItem.load_secret(chef_secret_key_loc)
adobe_databag = Chef::EncryptedDataBagItem.load("adobe_dbag", "mcmp", my_secret_key)

mysql_pipeline_stage = adobe_databag[project_name][mysql_app_name]['stage']

if deploy_stage!=mysql_pipeline_stage
    exit
end

ip = adobe_databag[project_name][mysql_app_name]['app_data']['db_ip']


petclinic_mysql = adobe_databag[project_name][mysql_app_name]['app_data']
mysqlun = petclinic_mysql['mysql_un']
mysqlpasswd = petclinic_mysql['mysql_pwd']

version = adobe_databag[project_name][SF_app_name]['version']

puts version

execute 'chef_jarxf' do
  command "sudo jar xf #{node['petclinic']['war_dir']}/spring-petclinic-#{version}.jar BOOT-INF/classes/application-mysql.properties"
  action :run
end

execute 'chef_mysqlip' do
  command "sed -i 's/localhost/#{ip}/g' BOOT-INF/classes/application-mysql.properties"
  action :run
end

execute 'chef_mysqlun' do
  command "sudo sed -i \'s/username=root/username=#{mysqlun}/g\' BOOT-INF/classes/application-mysql.properties"
  action :run
end

execute 'chef_mysqlpasswd' do
  command "sudo sed -i \'s/password=root/password=#{mysqlpasswd}/g\' BOOT-INF/classes/application-mysql.properties"
  action :run
end

execute 'chef_jaruf' do
  command "sudo jar uf #{node['petclinic']['war_dir']}/spring-petclinic-#{version}.jar BOOT-INF/classes/application-mysql.properties"
  action :run
end

execute 'chef_runjar' do
  command "sudo java -jar #{node['petclinic']['war_dir']}/spring-petclinic-#{version}.jar >> #{node['petclinic']['war_dir']}/petclinic.log"
  action :run
end

