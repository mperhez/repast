#Since this is a Dev container, for enabling sharing volumes with host is required to build this way:
#docker build --build-arg UID={YOUR HOST UID} -t uolmultiot/repast .
FROM openjdk:8 as builder

#Find out your user name (UNAME), ID and group Id (GRID) by running in the host: id
ARG UNAME=mperhez
ARG UID=1003
ENV ECP_URL=http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/2019-06/R/
ENV ECP_PKG=eclipse-committers-2019-06-R-linux-gtk-x86_64.tar.gz
ENV GRECLIPSE=https://dist.springsource.org/release/GRECLIPSE/3.4.0/e4.12
ENV REPAST_VERSION=2.7
ENV REPAST=https://repocafe.cels.anl.gov/repos/repast
ENV REPO=http://download.eclipse.org/releases/2019-06
#ENV REPO=http://download.eclipse.org/releases/helios/
# Check repository https://help.eclipse.org/2020-06/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html

RUN useradd -u $UID -ms /bin/bash $UNAME

#eclipse
WORKDIR /root/
RUN wget "$ECP_URL$ECP_PKG" \
&& tar -xf $ECP_PKG \
&& rm $ECP_PKG \
&& sed -i 's/"-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"//g' /root/eclipse/eclipse


#groovy
RUN ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,$GRECLIPSE -installIU org.codehaus.groovy.eclipse.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,$GRECLIPSE -installIU org.codehaus.groovy24.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,$GRECLIPSE -installIU org.codehaus.groovy.compilerless.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,$GRECLIPSE -installIU org.codehaus.groovy25.feature.feature.group \
        && ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,$GRECLIPSE -installIU org.codehaus.groovy.m2eclipse.feature.feature.group
#repast
RUN mkdir -p /home/$UNAME/$REPAST_VERSION/features \
        mkdir -p /home/$UNAME/$REPAST_VERSION/plugins \
        && wget $REPAST/artifacts.jar --no-check-certificate -P /home/$UNAME/$REPAST_VERSION \
        && wget $REPAST/content.jar --no-check-certificate -P /home/$UNAME/$REPAST_VERSION \
        && wget $REPAST/site.xml --no-check-certificate -P /home/$UNAME/$REPAST_VERSION \
        && wget -r -nH -l 1 --cut-dirs=3 --no-parent --reject="index.html*" $REPAST/features --no-check-certificate -P /home/$UNAME/$REPAST_VERSION/features \
        && wget -r -nH -l 1 --cut-dirs=3 --no-parent --reject="index.html*" $REPAST/plugins --no-check-certificate -P /home/$UNAME/$REPAST_VERSION/plugins \
        && ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository $REPO,file:///home/$UNAME/$REPAST_VERSION -installIU repast.simphony.feature.feature.group

FROM openjdk:8

#Default user (Replace with the User name {UNAME}, id {UID} and Group Id {GRID} from your host)
ARG UNAME=mperhez
ARG UID=1003
ARG GRID=1004

RUN apt-get update  \
	&& apt-get install -y \
	#sudo
	sudo \
	#2D/3D rendering: opengl libraries & video tools (for debugging video problems)
	mesa-utils libgl1-mesa-dri \
	# For eclipse
	libx11-6 libxext-dev libxrender-dev libxtst-dev libcanberra-gtk3-module \
        --no-install-recommends \
	&& apt-get clean \
       && rm -rf /var/lib/apt/lists/* \
	#For enabling sharing of volume with host
	&& useradd -u $UID -ms /bin/bash $UNAME	\
	&& export uid=$UID gid=$GRID && \
	mkdir -p /home/${UNAME}/workspace && \
	echo "${UNAME}:x:${uid}:${gid}:${UNAME},,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
	echo "${UNAME}:x:${uid}:" >> /etc/group && \
	echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
	chmod 0440 /etc/sudoers.d/${UNAME} && \
	chown ${uid}:${gid} -R /home/${UNAME}

USER $UNAME
WORKDIR /home/$UNAME
COPY --from=builder /root/eclipse ./eclipse
