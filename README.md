## Repast Simphony Development Environment

This is a basic eclipse-based image with the [Repast Simphony](https://repast.github.io/) development environment.  


### Tags

Latest Repast Simphony:
* `latest`

### Usage

Since this is an image for development, the workspace folder is shared from the host. 
Besides, for enabling writing permissions it requires the host user id (UID), by default 1001, but you can change it as required. 

If you need to rebuild the image, use the following command (with your host UID and UNAME):

    docker build --build-arg UID={YOUR HOST UID} --build-arg UNAME={YOUR HOST UNAME} -t uolmultiot/repast .

For running:

* With no opengl support:

`docker run --name repast -it -e DISPLAY -v $XAUTHORITY:/home/{YOUR HOST USER NAME}/.Xauthority --net=host -v {YOUR HOST WORKSPACE PATH}:/home/{YOUR CONTAINER USER NAME}/eclipse-workspace uolmultiot/repast:latest ./eclipse/eclipse`

* With opengl:

`docker run -ti --name repast -e DISPLAY -v="/tmp/.X11-unix:/tmp/.X11-unix:rw" -v $XAUTHORITY:/home/{YOUR UNAME}/.Xauthority --net=host --device=/dev/dri/card0:/dev/dri/card0 --device=/dev/dri/renderD128:/dev/dri/renderD128 --privileged -v {YOUR HOST WORKSPACE PATH}:/home/{YOUR UNAME}/eclipse-workspace uolmultiot/repast:latest ./eclipse/eclipse`

### Troubleshooting

* For the eclipse GUI to work you might need to enable connection to xserver from the container, on the host terminal:

1) `xhost +`
2) Run the container (See command for running container above)
3) `docker inspect --format '{{ .NetworkSettings.IPAddress }}' $containerId`
4) `xhost -`
5) `xhost +local: $IP` (IP obtained in step 3)

* From within eclipse, you might need to configure Groovy compiler version 2.4 at project and workspace level. Project -> Groovy Compiler  and Window -> Preferences -> Groovy -> Compiler -> Switch to 2.4.xx.

* If you have problems with video rendering (opengl), find out the right dri devices to map in the docker run command, by running in the host:
   `ls  dev/dri`
then, replace the left side of the --device parameters with the right device e.g. `--device=/dev/dri/card1:/dev/dri/card0`
For me, the above run command works for  Intel UHD 620 Graphics. You cand find out yours with:
  `sudo lspci -s 02 -v`

* You can test if rendering is correclty mapped by running this command inside the container:
	`sudo glxinfo | grep "OpenGL version string" | rev | cut -d" " -f1 | rev` 
you should get the version of driver running, normally the same on the host.

* You can read this [blog](http://gernotklingler.com/blog/howto-get-hardware-accelerated-opengl-support-docker/) that shows alternative solutions for Nvidia cards.


### Acknowledgements

* Some ideas for script and adaptation of running command from this [blog.](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/)


