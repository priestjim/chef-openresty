## 0.3.2:

* OpenResty version bump (LuaJIT 2.1!)
* PCRE version bump
* FIX: zip package dependency installation (#11)
* FIX: luarocks installation (#12)
* FIX: onditionally notify service on service changes (#13)
* FIX: PCRE URL to fix Chef redirect limit

## 0.3.1:

* Version bumps to multiple addons and OpenResty

## 0.3.0:

* OpenResty major version bump to 1.4-based NGINX
* Removed rate limit response code patch (since this is supported natively now)
* Promoted IPv6 support to standard configure flags

## 0.2.0:

* Added support for dynamic service definitions (i.e. runit, monit etc)
* OpenResty version bump
* Added automatic creation of /var/cache/nginx/{fastcgi,scgi,uwsgi,proxy}_cache
* Added support for linking with jemalloc. May provide some benefits when used in serving LUA
* Minor file naming fix

## 0.1.9:

* Fixed a bug in service restart
* Added flag for the control of the automatic activation of the bundled init script
* Refactored the build+install recipes (thanks @sdelano!)
* Altered the configure flags detection algorithm from consulting the OHAI plugin to
  consulting a set node attribute, which is more consistent and less error prone (thanks @sdelano!)
* Various fixes to the nxensite/nxdissite scripts (thanks @sdelano!)
* Fixed a bug where disabling the default site would not skip installing the `default` file in sites-enabled
  hence overwriting a potential `default` file installed from the administrator (thanks @sdelano!)
* Added support for LUA Rocks + a `luarock` LWRP
* Added support for more OpenResty modules
* Small fixes all around

## 0.1.8:

* Version bump
* Removed copytruncate from logrotate and used USR1 signaling
  after rotation in order to notify nginx that logs have been rotated. Thanks to @dim
* Added custom PCRE installation support (useful for includeing JIT-enabled PCRE installations)
* Updated Vagrantfile (supports Vagrant 1.1)

## 0.1.7:

* Added a manual restart command upon recompile

## 0.1.6:

* Added support for the cache_purge module
* Changelog updates
* Minor fixes

## 0.1.5:

* Added general security rules available for ad-hoc inclusion
* Updated documentation
* OpenResty version bump

## 0.1.4:

* OpenResty version bump
* mime.types update
* Added process notification timing information on LWRP

## 0.1.3:

* Added support for automatic CPU affinity

## 0.1.2:

* Various bugfixes

## 0.1.1:

* Added support for rate limit patch (changes 503 HTTP code to 429 which is more appropriate)

## 0.1.0:

* Initial release
