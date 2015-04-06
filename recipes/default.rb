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
# Need version of LVM2 from Vivid Vervet (15.04)
include_recipe 'apt::default'
apt_repository 'vivid' do
  uri 'http://archive.ubuntu.com/ubuntu/'
  distribution 'vivid'
  repo_name 'vivid'
  components ['main', 'multiverse', 'universe']
  action :add
end
apt_preference 'vivid' do
  glob '*'
  pin 'release n=vivid'
  pin_priority '250'
  action :add
end
# still need to execute the following after initial install:
# sudo apt-get upgrade
# sudo apt-get install dmeventd
# sudo apt-get upgrade -t vivid lvm2 dmsetup libdevmapper1.02.1 dpkg \
#  init-system-helpers libselinux1 perl-base
# sudo apt-get install -t vivid apparmor console-setup debconf-i18n kbd \
#  keyboard-configuration libapparmor-perl libarchive-extract-perl \
#  libclass-accessor-perl libio-string-perl liblocale-gettext-perl \
#  liblog-message-simple-perl libmodule-pluggable-perl libparse-debianchangelog-perl \
#  libpod-latex-perl libsub-name-perl libterm-ui-perl libtext-charwidth-perl \
#  libtext-iconv-perl libtext-soundex-perl libtext-wrapi18n-perl libtimedate-perl perl \
#  perl-modules tasksel tasksel-data ubuntu-minimal ureadahead

#
# scratch filesystem setup
directory '/mnt/gis' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
mount '/mnt/gis' do
  device '/dev/mapper/gisscratch_vg-gisscratch'
  fstype 'xfs'
  options 'inode64'
  action :mount
end
directory '/mnt/gis/scratch' do
  owner 'root'
  group 'gisanalysts'
  mode '0775'
  action :create
end

#
# NFS setup
include_recipe 'nfs::server'
nfs_export '/mnt/gis/scratch' do
  network '10.19.16.0/23'
  anongroup 'gisanalysts'
  writeable true
  options ['squash_gids=5010\,5035\,5037\,5040\,5086\,5087']
end
iptables_ng_rule '10-gina-private-net' do
  # rules to allow all tcp & udp from GINA private network
  # beats trying to handle NFS through iptables
  rule ['--source 10.19.16.0/23 --protocol tcp --jump ACCEPT',
        '--source 10.19.16.0/23 --protocol udp --jump ACCEPT']
  # source is IPv4 so cannot apply this rule to IPv6
  ip_version 4
end

#
# Samba setup
template "/etc/samba/smb.conf" do
  source "smb.conf.erb"
  mode "0644"
  action :create
end

