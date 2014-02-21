export PERLLIB="/home01/ekelly/sandbox/fcs/trunk/lib"

# Set env for QUOTE pdf BU.
#export PDF_DATA_DIR=/home01/ekelly/sandbox/fcs/trunk/BU/quote/fcs_email_pdf/fcs_email_pdf_files;
#export PDF_DIR=/nfs/www/pbxtra_proposal_downloads;
#export PDF_URI=http://intranet.test29.fonality.com;
#export PDF_INCLUDE=FonalityPBXtra-datasheet_061611.pdf;

# State Machine and business unit env vars.
export TEST_DIR="/home01/ekelly/sandbox/fcs/trunk" 
export FON_LIB="/home01/ekelly/sandbox/fcs/trunk/src"
export BU_TARGET="/home01/ekelly/sandbox/fcs/trunk/BU"
export CLASSPATH="/home01/ekelly/sandbox/fcs/trunk/src/java/core-fsp/lib/ext/*:/home01/ekelly/sandbox/fcs/trunk/src/java/core-fsp/lib/*:/home01/ekelly/sandbox/fcs/trunk/src/java/core-fsp/conf/"
export JAVA_HOME="/usr/java/latest"
export CONF_TARGET="/home01/ekelly/sandbox/fcs/trunk/res/conf"
export ANT_HOME="/home01/cwolf/pub_bin/ant"
export FCS_TEST=1

# Build jars.
if [ $T_WD ]; then
    cd ~/sandbox/fcs/trunk/src/java/core-fsp
    $ANT_HOME/bin/ant
    cd $T_WD
fi

# temporarily copy jars so that i can run my tests.
# later on, grep for jars and move them in this script.
cp \
 /home01/ekelly/sandbox/fcs/trunk/src/java/core-fsp/build/dist/quote/*.jar \
 /home01/ekelly/sandbox/fcs/trunk/BU/quote/java

cp \
 /home01/ekelly/sandbox/fcs/trunk/src/java/core-fsp/build/dist/order/*.jar \
 /home01/ekelly/sandbox/fcs/trunk/BU/order/java

