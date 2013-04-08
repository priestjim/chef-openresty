Description
===========

Installs the OpenResty NGINX bundle (http://www.openresty.org) from source and 
sets up configuration handling similar to Debian's Apache2 scripts. It also 
provides an OHAI plugin for configuration detection and an LWRP for easy site
activation and deactivation.

Requirements
============

Cookbooks
---------

The following cookbooks are direct dependencies because they're used
for common "default" functionality.

* build-essential
* ohai (for openresty::ohai_plugin)
* logrotate (for log file rotation)

Platform
--------

The following platforms are supported and tested under test kitchen:

* Ubuntu 12.04
* CentOS 6.3

Other Debian and RHEL family distributions are assumed to work.

Chef Server
-----------

The cookbook converges best on Chef installations >= 10.16.2

Awesome stuff
=============

This cookbook includes automatic activation of some nice NGINX features such as:

* **By default LUAJIT-enabled build**: The cookbook by default activates the LUAJIT
  feature of OpenResty (since this is the main reason to use the bundle) and
  accounts for all the peculiarities this option may bring.

* **Automatic CPU affinity**: Automatically sets the worker-to-core affinity for all
  of the NGINX worker processes. For a scenario of 8 workers and 8 cores, the
  following directive gets generated:

        worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;

  This feature can offer a nice performance boost, since it helps the CPUs maintain
  cache locality (especially when used in conjunction to the LUA module)

* **Automatic detection and activation of the AIO feature**: The cookbook automatically
  detects support (Linux kernel >= 2.6.22) and enables the `aio` directive of NGINX.

* **Automatic IPv6 detection and activation**: The cookbook automatically detects and
  activates IPv6 support on NGINX.

* **Rate limit proper HTTP response**: The cookbook contains a small patch that enables
  NGINX to respond to over-quota requests of the limit_req module with a 429 HTTP
  response that is more semantically correct than the default 503 one and aids in
  separate and log such issues more granularly. It gives away though the fact
  that you are rate limiting, so there is an option to disable this patch.

* **Support for custom PCRE runtime**: The cookbook can use custom PCRE sources in order
  to statically link to a custom-compiled PCRE runtime that supports JIT regular expression
  compilation which will significantly speed up RE execution in the NGINX and Lua environments.

Attributes
==========

Node attributes for this cookbook are logically separated into different files.

## default.rb

Generally used attributes. Some have platform specific values. See
`attributes/default.rb`. "The Config" refers to "nginx.conf" the main config file.

* `node['openresty']['source']['version']` - The OpenResty version to be installed from source.

* `node['openresty']['source']['url']` - The URL for downloading the selected version.

* `node['openresty']['source']['checksum']` - The SHA-256 checksum for the selected version.

* `node['openresty']['source']['limit_code_patch']` - Enables application of a
  patch that converts over-quota request limit HTTP 503 responses to proper 429 ones.

* `node['openresty']['dir']` - Location for NGINX configuration.

* `node['openresty']['log_dir']` - Location for NGINX logs.

* `node['openresty']['cache_dir']` - Location for NGINX cache files.

* `node['openresty']['run_dir']` - Location for NGINX state and pid files.

* `node['openresty']['binary']` - Location for NGINX executable.

* `node['openresty']['pid']` - The exact NGINX pid filename.

* `node['openresty']['source']['conf_path']` - Exact filename for the NGINX configuration file

* `node['openresty']['source']['prefix']` - Installation prefix for miscellaneous data

* `node['openresty']['source']['default_configure_flags']` - A set of default configuration
  flags for the source compilation, generally best left untouched unless you
  *really* know what you're doing.

* `node['openresty']['modules']` - An array of recipe names that are included
  from this cookbook and add additional features to the source compilation process.

* `node['openresty']['extra_modules']` - An array of full recipe references (in the
  form of cookbook::recipe), for you to include extra-cookbook modules in the same
  manner as above.

* `node['openresty']['configure_flags']` - An array of extra configure flags to
  be included included along the default configure flags.

* `node['openresty']['user']` - User that NGINX will run as.
* `node['openresty']['group]` - Group for NGINX.

* `node['openresty']['ipv6']` - Enables IPv6 support for NGINX. Automatically
  detected and enabled.

* `node['openresty']['gzip']` - Whether to use gzip, can be "on" or "off"

* `node['openresty']['gzip_http_version']` - used for config value of `gzip_http_version`.

* `node['openresty']['gzip_comp_level']` - used for config value of `gzip_comp_level`.
* `node['openresty']['gzip_proxied']` - used for config value of `gzip_proxied`.

* `node['openresty']['gzip_vary']` - used for config value of `gzip_vary`.

* `node['openresty']['gzip_buffers']` - used for config value of `gzip_buffers`.

* `node['openresty']['gzip_types']` - used for config value of `gzip_types` - must be an Array.

* `node['openresty']['keepalive']` - Whether to use `keepalive_timeout`,
  any value besides "on" will leave that option out of the config.

* `node['openresty']['keepalive_timeout']` - used for config value of
  `keepalive_timeout`.

* `node['openresty']['worker_processes']` - used for config value of
  `worker_processes`.

* `node['openresty']['worker_connections']` - used for config value of
  `events { worker_connections }`  

* `node['openresty']['worker_rlimit_nofile']` - used for config value of
  `worker_rlimit_nofile`. Can replace any "ulimit -n" command. The
  value depend on your usage (cache or not) but must always be
  superior than worker_connections.

* `node['openresty']['worker_auto_affinity']` - Automatically computes and creates
  CPU affinity assignments (config value `worker_cpu_affinity`) based on the 
  total number of workers and CPU cores. Can show a nice performance boost when 
  used in high request volume scenarios.

* `node['openresty']['multi_accept']` - used for config value of `events {
  multi_accept }`. Try to accept() as many connections as possible.
  Disable by default.

* `node['openresty']['event']` - used for config value of `events { use
  }`. Set the event-model. By default NGINX looks for the most
  suitable method for your OS. Automatically set to `epoll` for Linux >= 2.6 kernels

* `node['openresty']['server_names_hash_bucket_size']` - used for config
  value of `server_names_hash_bucket_size`.

* `node['openresty']['client_max_body_size']` - used for config
  value of `client_max_body_size`.

* `node['openresty']['client_body_buffer_size']` - used for config
  value of `client_body_buffer_size`.

* `node['openresty']['large_client_header_buffers']` - used for config
  value of `large_client_header_buffers`.

* `node['openresty']['types_hash_max_size']` - used for config
  value of `types_hash_max_size`.

* `node['openresty']['types_hash_bucket_size']` - used for config
  value of `types_hash_bucket_size`.

* `node['openresty']['open_file_cache']` - used for config
  value of `open_file_cache`. Must be an array with values used in the 
  `open_file_cache` directive of NGINX.

* `node['openresty']['logrotate']` - set to true to use the `logrotate_app` of the
  `logrotate` cookbook to enable automatic log rotation of NGINX logs.

* `node['openresty']['disable_access_log']` - set to true to disable the
  general access log, may be useful on high traffic sites.

* `node['openresty']['default_site_enabled']` - enable the default site

* `node['openresty']['custom_pcre']` - Se to true to download and use a custom
  PCRE source tree in order to enable RE JIT support.

## realip.rb

From: http://wiki.nginx.org/HttpRealIpModule

* `node['openresty']['realip']['header']` - Header to use for the RealIp
  Module; only accepts "X-Forwarded-For" or "X-Real-IP"

* `node['openresty']['realip']['addresses']` - Addresses to use for the
  `http_realip` configuration.

## fair.rb

From: http://wiki.nginx.org/HttpUpstreamFairModule

* `node['openresty']['fair']['url']` - GitHub URL to checkout the fair module from

* `node['openresty']['fair']['name']` - Directory name to checkout the module to

## upload_progress.rb

From: http://wiki.nginx.org/HttpUploadProgressModule

* `node['openresty']['upload_progress']['url']` - GitHub URL to checkout the upload_progress
  module from

* `node['openresty']['upload_progress']['name']` - Directory name to checkout the 
  module to

## status.rb

* `node['openresty']['status']['url']` - The URL that will be exposed as the NGINX
  status URL
* `node['openresty']['status']['name']` - An array of IPs allowed to view the
  status URL

## cache_purge.rb

From: https://github.com/FRiCKLE/ngx_cache_purge and http://labs.frickle.com/nginx_ngx_cache_purge

* `node['openresty']['cache_purge']['version']` - The version of the cache_purge module
* `node['openresty']['cache_purge']['url']` - URL to download the cache purge module from
* `node['openresty']['cache_purge']['checksum']` - The SHA-256 sum of the cache_purge module archive

Recipes
=======

## default.rb

The default recipe will install the OpenResty NGINX bundle from source,
automatically including your selected set of modules, extra-cookbook modules and
set up the configuration according to the Debian site enable/disable style with 
`sites-enabled` using the `nxensite` and `nxdissite` scripts provided by the
`openresty_site` LWRP. 

The recipe ensures that the required packages to build NGINX are installed (pcre,
openssl, compile tools). The source will be downloaded from the
`node['openresty']['source']['url']`. The `node['openresty']['user']` will be
created as a system user. The appropriate configuration and log
directories and config files will be created as well according to the
attributes `node['openresty']['dir']` and `'node['openresty']['log_dir']`.

The recipe attempts to detect whether additional modules should be
added to the configure command through recipe inclusion (see below),
and whether the version or configuration flags have changed and should
trigger a recompile.

Many features are automatically detected and enabled into the NGINX default
configuration file such as AIO support for Linux kernels >= 2.6.22, IPv6 support
and CPU worker affinity.

The NGINX service will be managed with init scripts installed by the cookbook.

The cookbook generates various include files (.inc) that are available for inclusion
in standard NGINX site definition files via the `#include` directive. Look in the
`conf.d` directory of `node['openresty']['dir']` location for them!

Includes the `ohai_plugin` recipe so the plugin is available.

## ohai_plugin.rb

This recipe provides an Ohai plugin as a template. It is automatically included
by the `default.rb` recipe.

## http_*_module.rb, fair_module.rb, upload_progress_module.rb, cache_purge_module.rb

These recipes are automatically included by the `default.rb` recipe according to
the `node['openresty']['modules']` array and provide compiled-in additional
features to the standard OpenResty NGINX compile. Check each recipe separately
for more information.

## http_stub_status_module.rb

Special mention needs to be made for the stub status module. The approach followed
here is to create an _include_ file with proper directives (set in the 
`status_module.rb` attribute file) that can be included in any NGINX configuration 
virtual host via the include directive:

    include /etc/nginx/conf.d/nginx_status.conf.inc;

Adding New Modules
------------------

To add a new module to be compiled into NGINX in the source recipe,
the node's run state is manipulated in a recipe, and the module as a
recipe should be added to `node['openresty']['modules']`. For
example:

    node.run_state['openresty_configure_flags'] =
      node.run_state['openresty_configure_flags'] | ["--with-http_stub_status_module"]

The recipe will be included by `recipe[nginx::default]` automatically,
adding the configure flags. Add any other configuration templates or
other resources as required. See the recipes described above for
examples.

In order to include extra-cookbook modules (most probably via an _application_ 
cookbook), you can use the `node['openresty']['extra_modules']` array, 
which takes as elements full recipe references like
    
    'recipe[my_openresty::module_42istheanswerforeveryhing]'

The extra-cookbook modules will be included in the same manner as the standard 
intra-cookbook modules.

LWRP
====

The cookbook includes the `openresty_site` LWRP (in contrast to the original
`nginx_site` cookbook definition script). The LWRP can be used in the same manner
as `nginx_site` and offers resource notifications (an advantage LWRPs
offer over simpler definitions). It also includes a `timing` parameter that can
be used to notify the `nginx` process to restart immediately based on configuration
file changes. The LWRP can be used like

    openresty_site "site.example.com" do
        action :enable
        timing :immediately
    end

Ohai Plugin
===========

The `ohai_plugin` recipe includes an Ohai plugin. It will be
automatically installed and activated, providing the following
attributes via ohai, no matter how NGINX is installed (source or
package):

* `node['nginx']['version']` - version of NGINX
* `node['nginx']['configure_arguments']` - options passed to
  ./configure when NGINX was built.
* `node['nginx']['prefix']` - installation prefix
* `node['nginx']['conf_path']` - configuration file path

The Ohai plugin is generally used to determine whether control
attributes for building NGINX have changed.

Usage
=====

Include the recipe on your node or role. Modify the
attributes as required in your role to change how various
configuration is applied per the attributes section above. In general,
override attributes in the role should be used when changing
attributes.

License and Author
==================

- Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)

A whole lot of this cookbook was based on original work by:

- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: Adam Jacob (<adam@opscode.com>)
- Author:: AJ Christensen (<aj@opscode.com>)
- Author:: Jamie Winsor (<jamie@vialstudios.com>)

Copyright 2012, Panagiotis Papadomitsos

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
