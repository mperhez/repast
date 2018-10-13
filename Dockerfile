#Since this is a Dev container, for enabling sharing volumes with host is required to build this way: 
#docker build --build-arg UID={YOUR HOST UID} -t uolmultiot/repast .
FROM openjdk:8 as builder

#Find out your user name (UNAME), ID and group Id (GRID) by running in the host: id
ARG UNAME= mperhez
ARG UID=1001
ENV ECP_URL=http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/oxygen/1a/
ENV ECP_PKG=eclipse-committers-oxygen-1a-linux-gtk-x86_64.tar.gz
ENV GRECLIPSE=http://dist.springsource.org/snapshot/GRECLIPSE/e4.7/
ENV REPAST=https://repocafe.cels.anl.gov/repos/repast

RUN useradd -u $UID -ms /bin/bash $UNAME

#eclipse
WORKDIR /root/
RUN wget "$ECP_URL$ECP_PKG" \
&& tar -xf $ECP_PKG \
&& rm $ECP_PKG \
&& sed -i 's/"-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"//g' /root/eclipse/eclipse

#repast
RUN ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$GRECLIPSE -installIU org.codehaus.groovy.eclipse.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$GRECLIPSE -installIU org.codehaus.groovy24.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$GRECLIPSE -installIU org.codehaus.groovy.compilerless.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$GRECLIPSE -installIU org.codehaus.groovy25.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$GRECLIPSE -installIU org.codehaus.groovy.m2eclipse.feature.feature.group \
&& ./eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/,$REPAST -installIU repast.simphony.feature.feature.group

FROM openjdk:8

#Default user (Replace with the User name {UNAME}, id {UID} and Group Id {GRID} from your host)
ARG UNAME=mperhez 
ARG UID=1001
ARG GRID=1001

RUN apt-get update  \
	apt-get install -y \
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
