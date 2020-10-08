# codechecker.mk

CODECHECKER_REPO	= git@github.com:wallinux/meta-codechecker.git
CODECHECKER_DIR		= $(TOP)/layers/meta-codechecker
CODECHECKER_BRANCH	?= thud2

CODECHECKER_PORT	?= 8003
CODECHECKER_IP		?= localhost

CODECHECKER_PATH	?= /opt/codechecker

#######################################################################

$(CODECHECKER_DIR):
	$(TRACE)
	-$(GIT) clone $(CODECHECKER_REPO) -b $(CODECHECKER_BRANCH) $@

codechecker.configure: $(BUILD_DIR) $(CODECHECKER_DIR) # create codechecker configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval ccconf=$(BUILD_DIR)/conf/codechecker.conf)
	$(RM) $(ccconf)
	$(GREP) -q codechecker.conf $(localconf); \
		if [ $$? = 1 ]; then \
			echo -e "\ninclude codechecker.conf" >> $(localconf); \
		fi
	$(ECHO) "# codechecker.conf" > $(ccconf)
	$(ECHO) "INHERIT += \"codechecker\"" >> $(ccconf)
	$(ECHO) "CODECHECKER_ENABLED = \"1\"" >> $(ccconf)
	$(ECHO) "CODECHECKER_ANALYZE_ARGS = \"--ctu -e sensitive\"" >> $(ccconf)
#	$(ECHO) "CODECHECKER_REPORT_HTML = \"1\""  >> $(ccconf)
	$(ECHO) "CODECHECKER_REPORT_STORE = \"1\""  >> $(ccconf)
	$(ECHO) "CODECHECKER_REPORT_HOST = \"http://$(CODECHECKER_IP):$(CODECHECKER_PORT)/Default\"" >> $(ccconf)
ifeq ($(V),1)
	@cat $(ccconf)
endif

codechecker.deconfigure: # remove codechecker configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval ccconf=$(BUILD_DIR)/conf/codechecker.conf)
	-$(RM) $(ccconf)
	-$(SED) '/codechecker.conf/d' $(localconf)

codechecker.add_layer: $(BUILD_DIR) $(CODECHECKER_DIR) # add codechecker layer
	$(TRACE)
	$(BBPREP) bitbake-layers add-layer $(CODECHECKER_DIR)
	$(MKSTAMP)

codechecker.remove_layer: # remove codechecker layer
	$(TRACE)
	-$(BBPREP) bitbake-layers remove-layer $(CODECHECKER_DIR)
	$(call rmstamp,codechecker.add_layer)

codechecker.update: $(CODECHECKER_DIR) # update codechecker layer
	$(TRACE)
	$(GIT) -C $< fetch --prune
	$(GIT) -C $< gc --auto
	$(GIT) -C $< checkout $(CODECHECKER_BRANCH) &> /dev/null || git checkout -b $(CODECHECKER_BRANCH) origin/$(CODECHECKER_BRANCH)
	$(GIT) -C $< pull

codechecker.enable: # enable codechecker
	$(TRACE)
	$(MAKE) codechecker.add_layer
	$(MAKE) codechecker.configure

codechecker.disable: # disable codechecker
	$(TRACE)
	$(MAKE) codechecker.deconfigure
	$(MAKE) codechecker.remove_layer

codechecker.distclean: # delete codechecker dir
	$(TRACE)
	$(MAKE) codechecker.remove_layer
	$(RM) -r $(CODECHECKER_DIR)
	$(call rmstamp,codechecker.configure)

codechecker.shell: # enable codechecker in shell
	$(TRACE)
	$(Q)source $(CODECHECKER_PATH)/venv/bin/activate; export PATH=$(CODECHECKER_PATH)/build/CodeChecker/bin:$$PATH; bash

codechecker.help:
	$(call run-help, codechecker.mk)

#######################################################################

help:: codechecker.help

update:: codechecker.update

distclean:: codechecker.distclean

ifndef INSIDE_CONTAINER
 include codechecker.server.mk
endif
