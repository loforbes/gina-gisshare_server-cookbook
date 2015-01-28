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

#
# shared group setup
group 'gisanalysts' do
  gid '9016'
  action :create
end

#
# GIS users setup
node['users'].each do |u|
  user u do
    gid 'gisanalysts'
    action :create
  end
end

#
# scratch filesystem setup
directory '/mnt/gisscratch' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
mount '/mnt/gisscratch' do
  device '/dev/mapper/gisscratch_vg-gisscratch'
  fstype 'xfs'
  options 'inode64'
  action :mount
end

#
# NFS setup
include_recipe 'nfs::server'
nfs_export '/mnt/gisscratch' do
  network '10.19.16.0/23'
  anongroup 'gisanalysts'
  writeable true
end

#
# Samba setup
#include_recipe 'samba::server'

