ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libXaw
LIBXAW_VERSION := 1.0.13
DEB_LIBXAW_V   ?= $(LIBXAW_VERSION)

libxaw-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://xorg.freedesktop.org/archive/individual/lib/libXaw-$(LIBXAW_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXaw-$(LIBXAW_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXaw-$(LIBXAW_VERSION).tar.gz,libXaw-$(LIBXAW_VERSION),libXaw)

ifneq ($(wildcard $(BUILD_WORK)/libXaw/.build_complete),)
libxaw:
	@echo "Using previously built libXaw."
else
libxaw: libxaw-setup libxext libxt libxmu libxpm
	cd $(BUILD_WORK)/libXaw && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--enable-malloc0returnsnull=no \
		--enable-specs=no \
		--disable-silent-rules
	+$(MAKE) -C $(BUILD_WORK)/libXaw
	+$(MAKE) -C $(BUILD_WORK)/libXaw install \
		DESTDIR=$(BUILD_STAGE)/libXaw
	+$(MAKE) -C $(BUILD_WORK)/libXaw install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libXaw/.build_complete
endif

libxaw-package: libxaw-stage
	# libXaw.mk Package Structure
	rm -rf $(BUILD_DIST)/libXaw-{6,dev,data,doc,Xcb{1,-dev}}
	mkdir -p $(BUILD_DIST)/libXaw-6/usr/lib \
		$(BUILD_DIST)/libXaw-dev/usr/{include/Xaw,lib/pkgconfig} \
		$(BUILD_DIST)/libXaw-{doc,data}/usr/share \
		$(BUILD_DIST)/libXaw-Xcb1/usr/lib/pkg \
		$(BUILD_DIST)/libXaw-Xcb-dev/usr/{include/Xaw,lib/pkgconfig}
	
	# libXaw.mk Prep libXaw-6
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/libXaw.6.dylib $(BUILD_DIST)/libXaw-6/usr/lib
	
	# libXaw.mk Prep libXaw-dev
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/libXaw{.a,.dylib} $(BUILD_DIST)/libXaw-dev/usr/lib
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/pkgconfig/Xaw.pc $(BUILD_DIST)/libXaw-dev/usr/lib/pkgconfig
	cp -a $(BUILD_STAGE)/libXaw/usr/include/Xaw/!(Xlib-Xcb.h) $(BUILD_DIST)/libXaw-dev/usr/include/Xaw
	
	# libXaw.mk Prep libXaw-data
	cp -a $(BUILD_STAGE)/libXaw/usr/share/Xaw $(BUILD_DIST)/libXaw-data/usr/share
	
	# libXaw.mk Prep libXaw-doc
	cp -a $(BUILD_STAGE)/libXaw/usr/share/man $(BUILD_DIST)/libXaw-doc/usr/share
	
	# libXaw.mk Prep libXaw-Xcb1
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/libXaw-Xcb.1.dylib $(BUILD_DIST)/libXaw-Xcb1/usr/lib
	
	# libXaw.mk Prep libXaw-Xcb-dev
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/libXaw-Xcb{.a,.dylib} $(BUILD_DIST)/libXaw-Xcb-dev/usr/lib
	cp -a $(BUILD_STAGE)/libXaw/usr/lib/pkgconfig/Xaw-Xcb.pc $(BUILD_DIST)/libXaw-Xcb-dev/usr/lib/pkgconfig
	cp -a $(BUILD_STAGE)/libXaw/usr/include/Xaw/Xlib-Xcb.h $(BUILD_DIST)/libXaw-Xcb-dev/usr/include/Xaw
	
	# libXaw.mk Sign
	$(call SIGN,libXaw-6,general.Xml)
	$(call SIGN,libXaw-Xcb1,general.Xml)
	
	# libXaw.mk Make .debs
	$(call PACK,libXaw-6,DEB_LIBXAW_V)
	$(call PACK,libXaw-dev,DEB_LIBXAW_V)
	$(call PACK,libXaw-data,DEB_LIBXAW_V)
	$(call PACK,libXaw-doc,DEB_LIBXAW_V)
	$(call PACK,libXaw-Xcb1,DEB_LIBXAW_V)
	$(call PACK,libXaw-Xcb-dev,DEB_LIBXAW_V)
	
	# libXaw.mk Build cleanup
	rm -rf $(BUILD_DIST)/libXaw-{6,dev,data,doc,Xcb{1,-dev}}

.PHONY: libXaw libXaw-package
