ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += plotutils
PLOTUTILS_VERSION := 2.6
DEB_PLOTUTILS_V   ?= $(PLOTUTILS_VERSION)

plotutils-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://ftpmirror.gnu.org/plotutils/plotutils-$(PLOTUTILS_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,plotutils-$(PLOTUTILS_VERSION).tar.gz)
	$(call EXTRACT_TAR,plotutils-$(PLOTUTILS_VERSION).tar.gz,plotutils-$(PLOTUTILS_VERSION),plotutils)
	cp -a $(BUILD_MISC)/config.sub $(BUILD_WORK)/plotutils

ifneq ($(wildcard $(BUILD_WORK)/plotutils/.build_complete),)
plotutils:
	@echo "Using previously built plotutils."
else
plotutils: plotutils-setup libx11 libxt libxaw libsm libice
	cd $(BUILD_WORK)/plotutils && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/plotutils
	+$(MAKE) -C $(BUILD_WORK)/plotutils install \
		DESTDIR=$(BUILD_STAGE)/plotutils
	touch $(BUILD_WORK)/plotutils/.build_complete
endif

plotutils-package: plotutils-stage
	# plotutils.mk Package Structure
	rm -rf $(BUILD_DIST)/plotutils
	mkdir -p $(BUILD_DIST)/plotutils
	
	# plotutils.mk Prep plotutils
	cp -a $(BUILD_STAGE)/plotutils $(BUILD_DIST)
	
	# plotutils.mk Sign
	$(call SIGN,plotutils,general.xml)
	
	# plotutils.mk Make .debs
	$(call PACK,plotutils,DEB_PLOTUTILS_V)
	
	# plotutils.mk Build cleanup
	rm -rf $(BUILD_DIST)/plotutils

.PHONY: plotutils plotutils-package
