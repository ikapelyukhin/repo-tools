projname = repo-tools-$(shell rpm -q --specfile --qf '%{VERSION}' repo-tools.spec)

tar:
	mkdir "$(projname)"
	cp $(shell git ls-files | grep -v repo-tools.spec) "$(projname)"
	tar -cjf "$(projname).tar.bz2" "$(projname)"
	rm -rf "$(projname)"

