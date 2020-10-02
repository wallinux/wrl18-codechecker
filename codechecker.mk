# codechecker.mk

CODECHECKER_PORT	?= 8003

ifdef INSIDE_CONTAINER
CODECHECKER_IP		?= $(HOSTIP)
else
CODECHECKER_IP		?= localhost
endif

#######################################################################

CODECHECKER_PATH	?= /opt/codechecker
CODECHECKER_DIR		?= $(BUILD_DIR)/tmp-glibc/deploy/CodeChecker

CODECHECKER_PKGLIST	+= $(shell grep -v "^\#" codechecker.pkglist)
CODECHECKER_PKG		?= busybox

##########################################################################
CCPREP			= $(BBPREP) source $(CODECHECKER_PATH)/venv/bin/activate;\
			  export PATH=$(CODECHECKER_PATH)/build/CodeChecker/bin:$$PATH;\
			  export BB_ENV_EXTRAWHITE="LD_PRELOAD LD_LIBRARY_PATH CC_LOGGER_FILE CC_LOGGER_GCC_LIKE $$BB_ENV_EXTRAWHITE";

define cc-log
	$(eval ccdir=$(CODECHECKER_DIR)/$(1))
	$(MKDIR) $(ccdir)
	$(call bitbake-task, busybox, cleanall)
	$(call bitbake-task, busybox, configure)
	$(CCPREP) CodeChecker --verbose debug log -o $(ccdir)/codechecker-log.json -b "bitbake $(1)"
endef

define cc-analyze
	$(eval ccdir=$(CODECHECKER_DIR)/$(1))
	$(MKDIR) $(ccdir)/results
	$(CCPREP) CodeChecker analyze -o $(ccdir)/results/ --report-hash context-free-v2 $(ccdir)/codechecker-log.json
endef

define cc-parse
	$(eval ccdir=$(CODECHECKER_DIR)/$(1))
	$(MKDIR) $(ccdir)/report-html/
	$(CCPREP) CodeChecker parse -e html --trim-path-prefix -o $(ccdir)/report-html/ $(ccdir)/$(1)/results/
endef

define cc-store
	$(eval ccdir=$(CODECHECKER_DIR)/$(1))
	$(CCPREP) CodeChecker store -n $(1) --trim-path-prefix --url "http://$(CODECHECKER_IP):$(CODECHECKER_PORT)/Default" $(ccdir)/results/
endef

#######################################################################

codechecker.configure: $(BUILD_DIR) # create codechecker configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval ccconf=$(BUILD_DIR)/conf/codechecker.conf)
	$(RM) $(ccconf)
	$(GREP) -q codechecker.conf $(localconf); \
		if [ $$? = 1 ]; then \
			echo -e "\ninclude codechecker.conf" >> $(localconf); \
		fi
	$(ECHO) "# codechecker.conf" > $(ccconf)
	$(ECHO) "export LD_PRELOAD" >> $(ccconf)
	$(ECHO) "export CC_LOGGER_GCC_LIKE" >> $(ccconf)
	$(ECHO) "export LD_LIBRARY_PATH" >> $(ccconf)
	$(ECHO) "export CC_LOGGER_FILE" >> $(ccconf)
ifeq ($(V),1)
	@cat $(ccconf)
endif

codechecker.deconfigure: # remove codechecker configuration
	$(TRACE)
	$(eval localconf=$(BUILD_DIR)/conf/local.conf)
	$(eval ccconf=$(BUILD_DIR)/conf/codechecker.conf)
	$(RM) $(ccconf)
	$(SED) '/codechecker/d' $(localconf)

codechecker.log: codechecker.configure # run codechecker log on $(CODECHECKER_PKG)
	$(TRACE)
	$(call cc-log,$(CODECHECKER_PKG))

codechecker.analyze: codechecker.configure # analyze codechecker log for $(CODECHECKER_PKG)
	$(TRACE)
	$(call cc-analyze,$(CODECHECKER_PKG))

codechecker.save_as_html: codechecker.configure # parse codechecker $(CODECHECKER_PKG) and store as html
	$(TRACE)
	$(call cc-parse,$(CODECHECKER_PKG))

codechecker.upload_to_webserver: codechecker.configure # store codechecker $(CODECHECKER_PKG) on webserver
	$(TRACE)
	$(call cc-store,$(CODECHECKER_PKG))

codechecker.build: # analyze, save and upload codechecker result for $(CODECHECKER_PKG)
	$(TRACE)
	$(MAKE) codechecker.log
	$(MAKE) codechecker.analyze
	$(MAKE) codechecker.save_as_html
	$(MAKE) codechecker.upload_to_webserver

codechecker.bbs: codechecker.configure # start bbshell with codechecker settings
	$(TRACE)
	$(CCPREP) bash

codechecker.prepare: codechecker.configure # build all packages with codechecker enabled but not activated
	$(TRACE)
	$(CCPREP) bitbake $(ML)$(WORLDIMAGE)

codechecker.all: # run codechecker on all $(CODECHECKER_PKGLIST)
	$(TRACE)
	@$(foreach pkg,$(CODECHECKER_PKGLIST), make -s codechecker.build CODECHECKER_PKG=$(pkg) ;)

codechecker.help:
	$(call run-help, codechecker.mk)
	$(GREEN)
	$(ECHO) " CODECHECKER_PKG=$(CODECHECKER_PKG)"
	$(ECHO) " CODECHECKER_PKGLIST=$(CODECHECKER_PKGLIST)"
	$(NORMAL)

#######################################################################

help:: codechecker.help

ifndef INSIDE_CONTAINER
 include codechecker.server.mk
endif
