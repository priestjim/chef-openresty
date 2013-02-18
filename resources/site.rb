#
# Cookbook Name:: openresty
# Resource:: site
#
# Copyright 2012, Panagiotis Papadomitsos <pj@ezgr.net>
#

actions :enable, :disable

default_action :enable

attribute :name,    :kind_of => String, :name_attribute => true
attribute :timing,  :kind_of => Symbol, :default => :delayed
