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
# TODO: MAKE BROCCOLI & BROCTL OPTIONAL
################################################################################

CMAKE_INSTALL_PREFIX = /opt/bro

CMAKE_CONFIG_OPTS += \
	-DBINARY_PACKAGING_MODE:BOOL=true \
	-DENABLE_DEBUG=true \
	-DINSTALL_BROCCOLI=false \
	-DINSTALL_BROCTL=false \
	-DINSTALL_AUX_TOOLS=false \
	-DDISABLE_PERFTOOLS=true \
	-DDISABLE_PYTHON_BINDINGS=true \
	-DDISABLE_PYBROKER=true

################################################################################
# HOOKS
################################################################################

define BRO_MKDIR_BUILD
	rm -rf $(@D)/build
	mkdir $(@D)/build
endef

define BRO_COPY_HOST_BIFCL_BINPAC
	mkdir -p $(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin
	cp -f $(@D)/src/bifcl $(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/bifcl
	cp -f $(@D)/aux/binpac/src/binpac $(HOST_DIR)$(CMAKE_INSTALL_PREFIX)/bin/binpac
endef

define BRO_TARGET_BIN_SYMLINK
	rm -rf $(TARGET_DIR)/usr/bin/bro
	ln -s $(TARGET_DIR)$(CMAKE_INSTALL_PREFIX)/bin/bro \
				$(TARGET_DIR)/usr/bin/bro
	chmod ugo+x $(TARGET_DIR)/usr/bin/bro
endef

################################################################################
# HOST BUILD
################################################################################

HOST_BRO_CONF_OPTS += \
	-DCMAKE_INSTALL_PREFIX=$(HOST_DIR)$(CMAKE_INSTALL_PREFIX) \
	$(CMAKE_CONFIG_OPTS)

HOST_BRO_POST_BUILD_HOOKS += BRO_COPY_HOST_BIFCL_BINPAC

# Don't install host-bro. We just need to compile and import bifcl and binpac.
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
	$(CMAKE_CONFIG_OPTS)

BRO_POST_CONFIGURE_HOOKS += BRO_MKDIR_BUILD
BRO_POST_INSTALL_TARGET_HOOKS += BRO_TARGET_BIN_SYMLINK

BRO_INSTALL_CMDS = $(MAKE) install -C $(@D)

define BRO_PERMISSIONS
		$(CMAKE_INSTALL_PREFIX)/bin/bro f 4755 0 0 - - - - -
		/usr/bin/bro f 4755 0 0 - - - - -
endef

$(eval $(cmake-package))
$(eval $(host-cmake-package))
