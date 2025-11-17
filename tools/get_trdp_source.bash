#!/bin/bash
#
# Retrieve TRDP source code from the official repository and create the tarball.
#
# usage:
# get_trdp_source.bash <version>
#
# Example: get_trdp_source.bash 1.1.0.0
#
# Note: the last version is retrieved if the version parameter is omitted
#
# Note: 
# Don't forget to enable HTTP proxy support in the subversion server configuration 
# (${HOME}/subversion/servers) if necessary


#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------

THIS_SCRIPT_DIR=$( cd $(dirname $0) ; pwd )

: ${TCNOPEN_SVN_REPOSITORY:=http://svn.code.sf.net/p/tcnopen}
: ${VERSION:="last"} 


# SVN Paths
readonly TRDP_SVN_ROOT=${TCNOPEN_SVN_REPOSITORY}/trdp
readonly TRDP_SVN_TAGS=${TRDP_SVN_ROOT}/tags/trdp


#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

# Print helper
function print()
{
   echo "$@"
}

# Error helper
function error()
{
   print "ERROR> $@"
   exit 1
}


# Get the last version of the TRDP stack
function get_stack_last_version()
{
   svn list ${TRDP_SVN_TAGS} | sort -r | head -1 | sed 's|/||g' \
      || error "Cannot get TRDP version from ${TRDP_SVN_TAGS}"
}

# Strip the stack. Keep only interesting things
function strip_stack()
{
   print "Stripping TRDP stack..."
   ( 
      cd ${TRDP_SOURCE}
      rm -rf bld resources spy VisualC Xcode
   )
   print "Done !"
}

# Create the TRDP stack archive
function create_stack_archive()
{
   print "Creating TRDP stack archive ${TRDP_ARCHIVE}..."
   # Remove any timestamp from archive in order to have exactly the same archive for the same version of TRDP
   cd $(dirname ${TRDP_SOURCE})
   \tar  --mtime=2000-01-01 --owner=0 --group=0 -c $(basename ${TRDP_SOURCE}) | gzip -n -9 > ${TRDP_ARCHIVE} \
      || error "Cannot create the tar archive ${TRDP_ARCHIVE}"
   cd -
   print "Done !"
}

# Update the component
function update_component()
{
   print "Updating TRDP component..."
   rm -rf ../trdp*.tar.gz
   cp ${TRDP_ARCHIVE} ${THIS_SCRIPT_DIR}/../
   sed -i "s/VERSION=.*/VERSION=${TRDP_VERSION}/g" ${THIS_SCRIPT_DIR}/../trdp.pre.mak
   print "Done !"
}


# Get the stack
function get_stack()
{
   print "Downloading TRDP version ${TRDP_VERSION}..."
   svn export ${TRDP_SVN_TAGS}/${TRDP_VERSION} ${TRDP_SOURCE} \
      || error "Cannot get TRDP source code from ${TRDP_SVN_TAGS}/${TRDP_VERSION}"
      
   print "Done !"
}


function cleanup()
{
   rm -rf ${TRDP_SOURCE} ${TRDP_ARCHIVE}
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Get the version
TRDP_VERSION=
if (( "$#" < 1 )) ; then 
   TRDP_VERSION=$(get_stack_last_version)
   [[ -n "${TRDP_VERSION}" ]] || error "Undefined version"
else
   TRDP_VERSION=$1
fi 

# Setup filename with the version value
readonly TRDP_SOURCE=${THIS_SCRIPT_DIR}/trdp-${TRDP_VERSION}
readonly TRDP_ARCHIVE=${THIS_SCRIPT_DIR}/trdp-${TRDP_VERSION}.tar.gz

# Download process
cleanup
get_stack
strip_stack
create_stack_archive
update_component
cleanup

print "Finished !"
exit 0
