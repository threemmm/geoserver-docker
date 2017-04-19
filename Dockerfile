FROM java:8-jre

MAINTAINER Mohammad Maghsoudi <maghsoudismtp@gmail.com>


# Update the sources list &
# Install basic applications
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
build-essential \
wget \
unzip \
&& rm -rf /var/lib/apt/lists/*


#
# Set GeoServer version and data directory
#
ENV GEOSERVER_VERSION 2.11.0
ENV JETTY_VERSION 9.2.13.v20150730
ENV GEOSERVER_DATA_DIR "/usr/share/geoserver/data_dir"
ENV GEOSERVER_HOME "/usr/share/geoserver"
ENV GEOSERVER_WEB_DIR "/usr/share/geoserver/webapps/geoserver/WEB-INF"


# __RUN_1__ Donwload geoserver and extract it in GEOSERVER_HOME
RUN mkdir -p $GEOSERVER_HOME \
&& cd $GEOSERVER_HOME \
&& wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip \
&& unzip geoserver-${GEOSERVER_VERSION}-bin.zip  \
&& mv geoserver-${GEOSERVER_VERSION}/* ./ \
&& rm -rf geoserver-${GEOSERVER_VERSION}-bin.zip geoserver-${GEOSERVER_VERSION}

# __RUN_2__ Add jetty-servlets for cross-origin problem
RUN cd $GEOSERVER_WEB_DIR/lib \
        && wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-servlets/${JETTY_VERSION}/jetty-servlets-${JETTY_VERSION}.jar

# __RUN_3__ (it depends on RUN_2)  Add setting to web.xml for cross-origin
RUN cd $GEOSERVER_WEB_DIR \
        && sed -i 's!</web-app>!<filter>\
        <filter-name>cross-origin</filter-name>\
        <filter-class>org.eclipse.jetty.servlets.CrossOriginFilter</filter-class>\
        </filter>\
        <filter-mapping>\
        <filter-name>cross-origin</filter-name>\
        <url-pattern>/*</url-pattern>\
        </filter-mapping>\
&!' web.xml



#add GDAL Plugin
RUN wget https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip \
&& unzip geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip -d $GEOSERVER_WEB_DIR/lib \
&& rm -rf geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip

#add GDAL data and GDAL native libraries
RUN mkdir -p /usr/share/geoserverGDAL \
&& cd /usr/share/geoserverGDAL \
&& wget http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.16/native/gdal/gdal-data.zip \
&& unzip gdal-data.zip \
&& rm -rf gdal-data.zip

ENV GDAL_DATA /usr/share/geoserverGDAL/gdal-data

#libraries
RUN mkdir -p /usr/share/geoserverGDAL/libraries \
&& cd /usr/share/geoserverGDAL/libraries \
&& wget http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.16/native/gdal/linux/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz \
&& tar -xvzf gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz \
&& rm -rf gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz

ENV LD_LIBRARY_PATH /usr/share/geoserverGDAL/libraries:$LD_LIBRARY_PATH

#jce_policy
RUN curl -LO "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
&& unzip jce_policy-8.zip \
&& cp UnlimitedJCEPolicyJDK8/*.jar $JAVA_HOME/lib/security \
&& rm -rf jce_policy-8.zip UnlimitedJCEPolicyJDK8


VOLUME $GEOSERVER_DATA_DIR
WORKDIR $GEOSERVER_HOME/bin/

CMD ["./startup.sh"]