# whitelist.mk

whitelist.configure: $(BUILD_DIR) # create whitelist configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval wlconf=$(BUILD_DIR)/conf/whitelist.conf)
	$(RM) $(wlconf)
	$(GREP) -q whitelist.conf $(localconf); \
		if [ $$? = 1 ]; then \
			echo -e "\ninclude whitelist.conf" >> $(localconf); \
		fi
	$(ECHO) "# whitelist.conf" > $(wlconf)
	$(ECHO) 'DISTRO_FEATURES_append = " sysvinit"'  >> $(wlconf)
	$(ECHO) 'VIRTUAL-RUNTIME_init_manager = "sysvinit"'  >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "bridge-utils"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "ebtables"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "gperftools"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "kea"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "libnet"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "libteam"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "lksctp-tools"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "log4cplus"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "minicoredumper"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "net-snmp"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "ntp"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "pps-tools"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "protobuf"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_openembedded-layer += "protobuf-c"' >> $(wlconf) 
	$(ECHO) 'PNWHITELIST_networking-layer += "strongswan"' >> $(wlconf)
	$(ECHO) 'PNWHITELIST_networking-layer += "vlan"' >> $(wlconf)
	#jemalloc ??
	#libyang ??
ifeq ($(V),1)
	@cat $(wlconf)
endif

whitelist.deconfigure: # remove whitelist configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval wlconf=$(BUILD_DIR)/conf/whitelist.conf)
	-$(RM) $(wlconf)
	-$(SED) '/whitelist.conf/d' $(localconf)

whitelist.help:
	$(call run-help, whitelist.mk)

#######################################################################

help:: whitelist.help

configure::
	$(MAKE) whitelist.configure

