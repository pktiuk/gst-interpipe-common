# some Makefile.am snippets to fix libtool's breakage w.r.t. DLL
# building
#
#
# define AS_LIBTOOL_LIB before calling.  Sorry, only one lib per
# directory
#


# add this to EXTRA_DIST
as_libtool_EXTRA_DIST = $(AS_LIBTOOL_LIB).def

if AS_LIBTOOL_WIN32

as_libtool_noinst_DATA_files = $(AS_LIBTOOL_LIB).lib

as_libtool_LDFLAGS = -no-undefined -export-symbols $(srcdir)/$(AS_LIBTOOL_LIB).def

# depend on this in install-data-local
as-libtool-install-data-local:
	$(INSTALL) $(AS_LIBTOOL_LIB).lib $(DESTDIR)$(libdir)
	$(INSTALL) .libs/$(AS_LIBTOOL_LIB).dll.a $(DESTDIR)$(libdir)
	$(INSTALL) $(srcdir)/$(AS_LIBTOOL_LIB).def $(DESTDIR)$(libdir)

# depend on this in uninstall-local
as-libtool-uninstall-local:
	-rm $(DESTDIR)$(libdir)/$(AS_LIBTOOL_LIB).lib
	-rm $(DESTDIR)$(libdir)/$(AS_LIBTOOL_LIB).dll.a
	-rm $(DESTDIR)$(libdir)/$(AS_LIBTOOL_LIB).def

else

as-libtool-install-data-local:
as-libtool-uninstall-local:

endif

$(AS_LIBTOOL_LIB).lib: $(AS_LIBTOOL_LIB).la $(AS_LIBTOOL_LIB).def
	dlltool -S $(CC) -f "-c" --export-all-symbols --input-def \
		$(srcdir)/$(AS_LIBTOOL_LIB).def --output-lib $@

$(AS_LIBTOOL_LIB).def:
	echo EXPORTS >$(AS_LIBTOOL_LIB).def.tmp
	nm --defined-only -g .libs/$(AS_LIBTOOL_LIB).so | \
		awk '{ print $$3 }' | \
		grep -v '^{_DYNAMIC,_GLOBAL_OFFSET_TABLE_,__bss_start,_edata,_end,_fini,_init}$$' | \
		sed 's/^/	/' >>$(AS_LIBTOOL_LIB).def.tmp
	mv $(AS_LIBTOOL_LIB).def.tmp $(AS_LIBTOOL_LIB).def
