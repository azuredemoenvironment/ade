# Dependencies: wget, unzip

echo Downloading and Installing a Local Version of Gatling
echo This directory is not source controlled, but will symlink to files and folders in the main project
echo This is meant to allow local runs and to be used in an IDE like IntelliJ

rm -Rf local/*
GATLING_VERSION=3.5.1

echo Download Gatling Version $GATLING_VERSION
mkdir -p local/tmp/downloads
wget -q -O local/tmp/downloads/gatling-$GATLING_VERSION.zip https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/$GATLING_VERSION/gatling-charts-highcharts-bundle-$GATLING_VERSION-bundle.zip
mkdir -p local/tmp/archive && cd local/tmp/archive

echo Extracting Gatling Version $GATLING_VERSION
unzip ../downloads/gatling-$GATLING_VERSION.zip

echo Moving Gatling Version $GATLING_VERSION
cd ../../../
mv local/tmp/archive/gatling-charts-highcharts-bundle-$GATLING_VERSION/* local/
rm -rf local/tmp

echo Symlinking Simulations and Configuration to local

rm -Rf local/user-files/*
ln -s $PWD/simulations $PWD/local/user-files/simulations

rm -Rf local/results
ln -s $PWD/results $PWD/local/results

rm local/conf/gatling.conf
rm local/conf/logback.xml
ln -s $PWD/conf/gatling.conf $PWD/local/conf/gatling.conf
ln -s $PWD/conf/logback.xml $PWD/local/conf/logback.xml