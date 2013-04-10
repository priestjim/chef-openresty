## 0.1.9:

* Fixed service restart

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
