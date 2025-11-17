# Create a compatible TRDP component from the sources

BASENAME=trdp
VERSION=2.0.3.0

ARCHIVE=$(BASENAME)-$(VERSION).tar.gz

source.is.ready : ./$(ARCHIVE)
	@$(ECHO) "$(cInfo). Extracting archive $(cVar)$<$(cInfo) ...$(cReset)"
	@$(SMUTE); tar xzf ./$(ARCHIVE)
	@$(SMUTE); rm -rf ./$(BASENAME) ; mv ./$(BASENAME)-$(VERSION) ./$(BASENAME)
	@$(SMUTE); touch $@

source.is.patched : source.is.ready
	@$(ECHO) "$(cInfo). Preparing code ...$(cReset)"
	@$(ECHO) "$(cInfo). Patch list : $(cReset)"
	@$(SMUTE); quilt series ; 
	@$(SMUTE); if [[ "$$( quilt series | wc -l )" != "0" ]] ; then  \
	   $(ECHO) "$(cInfo). Patching code ...$(cReset)" ; quilt push -a ; \
	fi
	@$(SMUTE); touch $@
   
all:: source.is.patched

veryclean:: clean
	@$(SMUTE); if [[ "$$( quilt series | wc -l )" != "0" ]] ; then  \
      quilt pop -a -f; \
      if [[ "$$?" != "0" ]]; then \
         $(ECHO) "$(cWarn). quilt failed to removed applied patches !!!$(cReset)"; \
      fi ; \
   fi
	@$(RM) -rf .pc
	@$(SMUTE); rm -rf ./$(BASENAME)
	@$(RM) -rf source.is.ready
