################################################################################
#
# bro
# Inspired by https://github.com/krkhan/openwrt-bro/blob/master/bro/Makefile
#
################################################################################

BRO_VERSION = 2.5.3
BRO_SOURCE = bro-$(BRO_VERSION).tar.gz
BRO_SITE = http://www.bro-ids.org/downloads
BRO_INSTALL_STAGING = NO
BRO_INSTALL_TARGET = YES

HOST_BRO_DEPENDENCIES += \
	host-flex host-bison host-python host-file host-zlib

BRO_DEPENDENCIES = host-bro libpcap openssl bind zlib

################################################################################
# PRECONFIGURABLE OPTIONS
################################################################################

CMAKE_INSTALL_PREFIX = /opt/bro

# Common CMAKE options for host and target build.
CMAKE_CONFIG_OPTS += \
	-DBRO_ETC_INSTALL_DIR=$(CMAKE_INSTALL_PREFIX)/etc \
	-DBINARY_PACKAGING_MODE=false \
	-DENABLE_DEBUG=true \
	-DINSTALL_BROCTL=false \
	-DINSTALL_AUX_TOOLS=false \
	-DDISABLE_PERFTOOLS=true \
	# Adding optional configuration for Broker would require the creation of an
	# additional C++ Actor Framework package for Buildroot. Not sure about the
	# benefits of using Broker over Broccoli.
	-DENABLE_BROKER=false \
	-DDISABLE_PYBROKER=true

################################################################################
# HOOKS
################################################################################

# Following hook will create a build directory as CMAKE requires.
define BRO_MKDIR_BUILD
	rm -rf $(@D)/build
	mkdir $(@D)/build
endef

# Following hook will copy bifcl and binpac generated on host build to the host
# directory, to be used during target installation.
define BRO_COPY_HOST_BIFCL_BINPAC
	mkdir -p $(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin

	cp -f $(@D)/src/bifcl \
				$(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/bifcl

	cp -f $(@D)/aux/binpac/src/binpac \
				$(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/binpac
endef

# Following hook will install broccoli to the host if required. Python-bindings
# to be copied to the target.
define BRO_INSTALL_HOST_BROCCOLI
	$(MAKE) -C $(@D)/aux/broccoli
	$(MAKE) -C $(@D)/aux/broccoli install
endef

# Following hook will copy python-bindings from the host to the target.
define BRO_COPY_HOST_BROCCOLI_BINDINGS
	cp -rf $(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/lib/python \
				$(TARGET_DIR)$(CMAKE_INSTALL_PREFIX)/lib/python
endef

################################################################################
# OPTIONAL DEPENDENCIES
################################################################################

# Whether or not we install Broccoli on the target.
ifeq ($(BR2_PACKAGE_BRO_BROCCOLI),y)
	CMAKE_CONFIG_OPTS += \
		-DINSTALL_BROCCOLI=true \
		-DBRO_SYSCONF_FILE=$(@D)/aux/broccoli/broccoli.conf
else
	CMAKE_CONFIG_OPTS += -DINSTALL_BROCCOLI=false
endif

# Whether or not we install Broccoli Python bindings on the target.
ifeq ($(BR2_PACKAGE_BRO_BROCCOLI_BINDINGS),y)
	# Building python bindings requires SWIG.
	HOST_BRO_DEPENDENCIES += host-swig
	#Trivial target dependency.
	BRO_DEPENDENCIES += python
	# We'll be building bindings on host and copying them to target afterwards.
	HOST_BRO_CONF_OPTS += -DDISABLE_PYTHON_BINDINGS=false
	HOST_BRO_POST_BUILD_HOOKS += BRO_INSTALL_HOST_BROCCOLI
	# Copying bindings to the target.
	BRO_POST_INSTALL_TARGET_HOOKS += BRO_COPY_HOST_BROCCOLI_BINDINGS
else
	HOST_BRO_CONF_OPTS += -DDISABLE_PYTHON_BINDINGS=true
endif

################################################################################
# HOST BUILD
################################################################################

HOST_BRO_CONF_OPTS += \
	-DCMAKE_INSTALL_PREFIX=$(HOST_DIR)$(CMAKE_INSTALL_PREFIX) \
	$(CMAKE_CONFIG_OPTS)

HOST_BRO_POST_BUILD_HOOKS += BRO_COPY_HOST_BIFCL_BINPAC

# Don't install host-bro. We just need to compile and import bifcl and binpac,
# as well as install and import optional modules such as python-bindings for
# Broccoli, using post-build hooks.
# Therefore only run 'true' and do nothing, not even the default action.
HOST_BRO_INSTALL_CMDS = true

################################################################################
# TARGET INSTALLATION
################################################################################

BRO_CONF_OPTS += \
	-DCMAKE_INSTALL_PREFIX=$(CMAKE_INSTALL_PREFIX) \
	-DBIFCL_HOST=$(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/bifcl \
	-DBINPAC_HOST=$(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/binpac \
	-DCMAKE_CXX_FLAGS=-Os \
	-DCMAKE_C_FLAGS=-Os \
	# Bindings to be always disabled for target intallation. Will be copied from
	# host if required.
	-DDISABLE_PYTHON_BINDINGS=true \
	$(CMAKE_CONFIG_OPTS)

BRO_POST_CONFIGURE_HOOKS += BRO_MKDIR_BUILD

BRO_INSTALL_CMDS = $(MAKE) -C $(@D) install

define BRO_PERMISSIONS
		$(CMAKE_INSTALL_PREFIX)/bin/bro f 4755 0 0 - - - - -
		/usr/bin/bro f 4755 0 0 - - - - -
endef

$(eval $(cmake-package))
$(eval $(host-cmake-package))
