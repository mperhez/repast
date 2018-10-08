## Repast Simphony Development Environment

This is a basic eclipse-based image with the [Repast Simphony](https://repast.github.io/) development environment.  


### Tags

Latest Repast Simphony:
* `latest`

### Usage

Since this is an image for development, the workspace folder is shared from the host. 
Besides, for enabling writing permissions it requires the host user id (UID), by default 1000, but you can change it as required. 

If you need to rebuild the image, use the following command (with your host UID and UNAME):

    docker build --build-arg UID={YOUR HOST UID} --build-arg UNAME={YOUR HOST UNAME} -t uolmultiot/repast .

For running:

    docker run --name repast -it -e DISPLAY -v $XAUTHORITY:/home/{YOUR HOST USER NAME}/.Xauthority --net=host -v {YOUR HOST WORKSPACE PATH}:/home/{YOUR CONTAINER USER NAME}/eclipse-workspace uolmultiot/repast:latest ./eclipse/eclipse


### Troubleshooting

* For the eclipse GUI to work you might need to enable connection to xserver from the container, on the host terminal:

1) xhost +
2) Run the container (See command for running container above)
3) docker inspect --format '{{ .NetworkSettings.IPAddress }}' $containerId 
4) xhost -
5) xhost +local: $IP (IP obtained in step 3)


* From within eclipse, you might need to configure Groovy compiler version 2.4 at project and workspace level. Project -> Groovy Compiler  and Window -> Preferences -> Groovy -> Compiler -> Switch to 2.4.xx.

### Acknowledgments

* Running command is an adaptation this [blog.](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/)


