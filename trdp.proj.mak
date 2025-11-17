#@desc Library implementing the TRDP (Train Real-time Data Protocol) protcol
#@desc developped by the TCNOpen initiative (http://www.tcnopen.eu) 
#@desc for IEC61375 standardized communication
#@desc Source code got with the following command: 
#@desc svn export http://svn.code.sf.net/p/tcnopen/trdp/tags/trdp/<version> trdp-<version>
#@author rsd
#@safety None
#@license MPL v2

COMP=trdp

$(COMP).COMP_REQUIRED+=tools/pactMake

$(COMP).COMP_REQUIRED+=thirdparty/libxml2
$(COMP).COMP_REQUIRED+=thirdparty/zlib

#### Includes for logs ####
$(COMP).PUBLIC_INCLUDES+=include

#### Includes for TRDP ####
$(COMP).PUBLIC_INCLUDES+=trdp/src/api
$(COMP).PUBLIC_INCLUDES+=trdp/src/common
$(COMP).PUBLIC_INCLUDES+=trdp/src/vos/api

# We must include platform dependent headers. 
ifdef linux
	$(COMP).PUBLIC_INCLUDES+=trdp/src/vos/posix
endif

