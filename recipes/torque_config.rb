#
# Cookbook Name:: cfnclustr
# Recipe:: torque_config
#
# Copyright 2013-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'cfncluster::base_config'
include_recipe 'cfncluster::torque_install'

# Update ld.conf
append_if_no_line "add torque libs to ld.so.conf" do
  path "/etc/ld.so.conf.d/torque.conf"
  line "/opt/torque/lib"
  notifies :run, 'execute[run-ldconfig]', :immediately
end

# Run ldconfig
execute "run-ldconfig" do
  command 'ldconfig'
end

# Set toruqe server_name
template '/var/spool/torque/server_name' do
  source 'torque.server_name.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# Install trqauthd service
remote_file "install trqauthd service" do
  path "/etc/init.d/trqauthd"
  source node['cfncluster']['torque']['trqauthd_source']
  owner 'root'
  group 'root'
  mode 0755
end

# Enable and start trqauthd service
service "trqauthd" do
  supports restart: true
  action [:enable, :start]
end

# Create the munge key from template
template "/etc/munge/munge.key" do
  source "munge.key.erb"
  owner "munge"
  mode "0600"
end

# Enable munge service
service "munge" do
  supports restart: true
  action [:enable, :start]
end

cookbook_file "/etc/profile.d/torque.sh" do
  source 'torque.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# case node['cfncluster']['cfn_node_type']
case node['cfncluster']['cfn_node_type']
when 'MasterServer'
  include_recipe 'cfncluster::_master_torque_config'
when 'ComputeFleet'
  include_recipe 'cfncluster::_compute_torque_config'
else
  fail "cfn_node_type must be MasterServer or ComputeFleet"
end
