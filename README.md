## Repast Simphony Development Environment

This is a basic eclipse-based image with the [Repast Simphony] (https://repast.github.io/) development environment.  


### Tags

Latest Repast Simphony:
* `latest`

### Usage

Since this is an image for development, the workspace folder is shared from the host. 
Besides, for enabling writing permissions it requires the host user id (UID), by default 1000, but you can change it as required. 

If you need to rebuild the image, use the following command (with your host UID and UNAME):

    docker build --build-arg UID={YOUR HOST UID} --build-arg UNAME={YOUR HOST UNAME} -t uolmultiot/repast .

For running:

    docker run --name repast -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v {HOST WORKSPACE PATH}:/home/{YOUR HOST UNAME}/eclipse-workspace uolmultiot/repast:latest ./eclipse/eclipse


### Troubleshooting

* For the eclipse GUI to work you might need to enable connection to xserver from the container, on host terminal run:

1) xhost +
2) run container
3) run: docker inspect --format '{{ .NetworkSettings.IPAddress }}' $containerId -> on the running container to find out its ip
4) xhost -
5) xhost +local: $IP


* You might need to configure Groovy compiler version 2.4 at project and workspace level.


