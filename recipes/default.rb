#
# Cookbook Name:: gina-gisshare_server
# Recipe:: default
#
# Copyright 2015 UAF
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shared group setup
group 'gisanalysts' do
  gid '9016'
  action :create
end

# GIS users setup
node['gisshare']['users'].each do |u|
  user u do
    gid 'gisanalysts'
    action :create
  end
end

