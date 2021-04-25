#! /bin/bash

# Quick script from readme texts, remember to check inside tools folder for original script
# Basic ussage of mkgmap from its documentation

MKGMAP="mkgmap-r4600" # adjust to latest version (see www.mkgmap.org.uk)
SPLITTER="splitter-r598"

mkdir -p tools
pushd tools > /dev/null

if [ ! -d "${MKGMAP}" ]; then
    wget "http://www.mkgmap.org.uk/download/${MKGMAP}.zip"
    unzip "${MKGMAP}.zip"
fi
MKGMAPJAR="$(pwd)/${MKGMAP}/mkgmap.jar"

if [ ! -d "${SPLITTER}" ]; then
    wget "http://www.mkgmap.org.uk/download/${SPLITTER}.zip"
    unzip "${SPLITTER}.zip"
fi
SPLITTERJAR="$(pwd)/${SPLITTER}/splitter.jar"

popd > /dev/null

if stat --printf='' bounds/bounds_*.bnd 2> /dev/null; then
    echo "bounds already downloaded"
else
    echo "downloading bounds"
    rm -f bounds.zip  # just in case
    wget -O bounds.zip "http://osm.thkukuk.de/data/bounds-latest.zip"
    unzip "bounds.zip" -d bounds
fi

BOUNDS="$(pwd)/bounds"

if stat --printf='' sea/sea_*.pbf 2> /dev/null; then
    echo "sea already downloaded"
else
    echo "downloading sea"
    rm -f sea.zip  # just in case
    wget -O sea.zip "http://osm.thkukuk.de/data/sea-latest.zip"
    unzip "sea.zip" -d sea
fi

SEA="$(pwd)/sea"

mkdir data
pushd data > /dev/null

#COUNTRY="andorra"
COUNTRY="spain"
MAP="$COUNTRY-latest.osm.pbf"
# TODO: Check if exists one file with x days old
rm -f $MAP
wget "https://download.geofabrik.de/europe/$MAP"

rm -f 6324*.pbf
java -jar $SPLITTERJAR --precomp-sea=$SEA "$(pwd)/$MAP"
DATA="$(pwd)/6324*.pbf"

popd > /dev/null

OPTIONS="$(pwd)/opentopomap_options"
STYLEFILE="$(pwd)/style/opentopomap"

pushd style/typ > /dev/null

java -jar $MKGMAPJAR --family-id=35 OpenTopoMap.txt
TYPFILE="$(pwd)/opentopomap.typ"

popd > /dev/null

NAMELIST="name:es,name:es,int_name,name"

SUFFIX='lite'

java -jar $MKGMAPJAR -c $OPTIONS --style-file=$STYLEFILE \
    --precomp-sea=$SEA \
    --name-tag-list=${NAMELIST} \
	--description="GnZ ${COUNTRY} ${SUFFIX}" \
	--family-name="GnZ ${COUNTRY} ${SUFFIX} `date "+%Y-%m-%d"`" \
	--series-name="GnZ ${COUNTRY} ${SUFFIX} `date "+%Y-%m-%d"`" \
    --output-dir=output --bounds=$BOUNDS $DATA $TYPFILE

# optional: give map a useful name:
mv output/gmapsupp.img output/GnZ_${COUNTRY}_${SUFFIX}.img