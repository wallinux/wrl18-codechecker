# arn-awallin-linux-l5 host config file
#
# Define where you have wrlinux 18
WRL_INSTALL_DIR	= /opt/projects/ericsson/installs/wrlinux_lts18

# Define to trace cmd's
# V=1

OUT_DIR			= /opt/awallin/$(shell basename $(PWD))
CONTAINER_MOUNTS	+= -v $(OUT_DIR):$(OUT_DIR)

arn-awallin-linux-l5.configure: $(OUT_DIR)
	$(TRACE)
	$(Q)ln -sn $(OUT_DIR) $(TOP)/out

configure:: arn-awallin-linux-l5.configure
