mysql_config_loc = node['mysql']['config_loc']
mysql_config_dir = node['mysql']['config_dir_name']
mysql_db_name = node['mysql']['db_name']

Dir.mkdir("#{mysql_config_loc}") unless Dir.exist?("#{mysql_config_loc}")

remote_directory "#{mysql_config_loc}" do
  source "#{mysql_config_dir}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'libmysqlclient-dev' do
  command 'apt-get install libmysqlclient-dev -y'
end

execute 'ruby-dev' do
  command 'apt-get install ruby-dev -y'
end

execute 'build-essential' do
  command 'apt-get install build-essential -y'
end

chef_gem "mysql2" do
  action :install
end

# Externalize conection info in a ruby hash
mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database "#{mysql_db_name}" do
  connection mysql_connection_info
  action :create
end

mysql_database_user 'root' do
  connection    mysql_connection_info
  database_name "#{mysql_db_name}"
  host          '%'
  privileges    [:select,:update,:insert]
  action        :grant
end

mysql_database "#{mysql_db_name}" do
  connection mysql_connection_info
  sql        'flush privileges'
  action     :query
end

execute 'schema sql' do
  command "mysql -u root -h localhost #{mysql_db_name} < #{mysql_config_loc}/schema.sql"
end

execute 'data sql' do
  command "mysql -u root -h localhost #{mysql_db_name} < #{mysql_config_loc}/data.sql"
end

execute 'run script' do
  command "sudo sh #{mysql_config_loc}/run_mysql.sh"
end
