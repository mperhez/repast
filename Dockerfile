FROM openjdk:8

ENV HOME /home/ruser
ENV USER ruser

RUN apt-get update && apt-get install -y \
	# For eclipse            
	libx11-6 libxext-dev libxrender-dev libxtst-dev libcanberra-gtk-module \
        --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* 

RUN useradd -u 1000 -ms /bin/bash $USER

WORKDIR $HOME

RUN wget "http://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/neon/1/eclipse-committers-neon-1-linux-gtk-x86_64.tar.gz"
RUN tar -xf eclipse-committers-neon-1-linux-gtk-x86_64.tar.gz
RUN rm eclipse-committers-neon-1-linux-gtk-x86_64.tar.gz


#To check why the size of the image is bigger when downloading from container than from downloading outside and adding to container using:
#ADD eclipse-committers-neon-1-linux-gtk-x86_64.tar.gz $HOME


#COPY repast-plugin-2.4/plugins $HOME/eclipse
#COPY repast-plugin-2.4/features $HOME/features

RUN mkdir -p /home/multiot/workspace

RUN chown -R $USER:$USER $HOME

RUN sed -i 's/"-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"//g' $HOME/eclipse/eclipse

USER $USER 

#ADDITIONAL MANUAL STEPS:
#installation of Groovy via eclipse add new software: http://dist.springsource.org/snapshot/GRECLIPSE/e4.6/
#Extra Groovy Compilers, Groovy-Eclipse and Uncategorized
#installation of Repast via eclipse add new software:
#The groovy compiler version must be set to anything in the 2.0. version line
#if repast missing: https://repocafe.cels.anl.gov/repos/repast
