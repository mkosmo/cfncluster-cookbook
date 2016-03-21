#
# Cookbook Name:: cfncluster
# Recipe:: _prep_env
#
# Copyright 2013-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Determine cfn_scheduler_slots settings and update cfn_instance_slots appropriately
if node['cfncluster']['cfn_scheduler_slots'] == 'vcpus'
  node.default['cfncluster']['cfn_instance_slots'] = node['cpu']['total']
elsif node['cfncluster']['cfn_scheduler_slots'] == 'cores'
  node.default['cfncluster']['cfn_instance_slots'] = node['cpu']['total'] / 2
else
  node.default['cfncluster']['cfn_instance_slots'] = node['cfncluster']['cfn_scheduler_slots']
end

directory '/etc/cfncluster'
directory '/opt/cfncluster'
directory '/opt/cfncluster/scripts'

template '/etc/cfncluster/cfnconfig' do
  source 'cfnconfig.erb'
  mode '0644'
end

link '/opt/cfncluster/cfnconfig' do
  to '/etc/cfncluster/cfnconfig'
end

cookbook_file "fetch_and_run" do
  path "/opt/cfncluster/scripts/fetch_and_run"
  owner "root"
  group "root"
  mode "0755"
end

cookbook_file "compute_ready" do
  path "/opt/cfncluster/scripts/compute_ready"
  owner "root"
  group "root"
  mode "0755"
end
