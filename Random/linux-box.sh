#/bin/bash

type docker >/dev/null 2>&1 || { echo >&2 "docker not installed. Aborting."; exit 0; }

spawn() {
    docker pull ubuntu
    docker run -td ubuntu
    docker exec -it "$(docker ps | grep "ubuntu" | awk '/[a-z0-9].*/' | awk '{print $1}')" /bin/bash
}

clean() {
    docker kill "$(docker ps | grep "ubuntu" | awk '/[a-z0-9].*/' | awk '{print $1}')"
    docker rmi -f ubuntu
}

case $1 in
    "spawn") spawn;;
    "clean") clean;;
    *) ;;
esac
