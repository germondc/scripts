#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
	echo "usage `basename $0` <install URL> <eclipse path> [output name]"
	echo "  install URL  - the install URL from the Eclipse Market Place"
	echo "  eclipse path - the path eclipsec can be found at"
	echo "  output name  - (optional) the name of the ZIP output, default: local_p2.zip"
	exit 1
fi

URL=$1
echo "retrieving from: ${URL}"
ECLIPSE_PATH=$2
if [ ! -x ${ECLIPSE_PATH}/eclipsec ]
then
	echo "eclipsec cannot be found at ${ECLIPSE_PATH}, or is no executable"
	exit 1
fi
echo "eclipsec found at: ${ECLIPSE_PATH}"

if [ $# -eq 3 ]
then
	OUTPUT=$3
else
	OUTPUT=local_p2.zip
fi
echo "output will be written to: ${OUTPUT}"
CAN_ZIP=1
which zip >/dev/null 2>&1 || CAN_ZIP=0
if [ ${CAN_ZIP} -eq 0 ]
then
	echo "no utility found to ZIP, will leave the directory output instead"
fi

DEST=output
[ -d ${DEST} ] && rm -rf ${DEST}
mkdir ${DEST}
echo 'log4j.rootLogger=info, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%5p [%t] (%F:%L) - %m%n' > app.properties

${ECLIPSE_PATH}/eclipsec -nosplash -application org.eclipse.equinox.p2.metadata.repository.mirrorApplication -source ${URL} -destination ${DEST} -vmargs -Dlog4j.configuration='file:app.properties'
${ECLIPSE_PATH}/eclipsec -nosplash -application org.eclipse.equinox.p2.artifact.repository.mirrorApplication -source ${URL} -destination ${DEST} -vmargs -Dlog4j.configuration='file:app.properties'

rm app.properties
if [ ${CAN_ZIP} -eq 1 ]
then
	[ -f ${OUTPUT} ] && rm ${OUTPUT}
	cd ${DEST}
	zip -r ../${OUTPUT} *
	cd ..
	rm -rf ${DEST}
	echo "output at: $(realpath $OUTPUT)"
else
	echo "output at: $(realpath $DEST)"
fi

