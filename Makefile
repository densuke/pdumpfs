SHELL = /bin/bash
VERSION = 1.3

check:
	cd tests && bash -x pdumpfs-test

clean:
	rm -f pdumpfs pdumpfs.exe pdumpfs.exr
	rm -f tests/tmp.log

dist: clean
	rm -rf pdumpfs-$(VERSION)
	mkdir pdumpfs-$(VERSION)
	cp -p   README COPYING ChangeLog Makefile\
		bin/pdumpfs lib/pdumpfs.rb lib/pdumpfs/version.rb pdumpfs-$(VERSION)
	cp -rp tests man doc pdumpfs-$(VERSION)
	find pdumpfs-$(VERSION) -name CVS -or -name '*~' | xargs rm -rf
	tar zcvf pdumpfs-$(VERSION).tar.gz pdumpfs-$(VERSION)
	rm -rf pdumpfs-$(VERSION)
