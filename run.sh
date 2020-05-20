set -e
docker run --rm --name vue-cli -v $PWD:/home/node/app -w /home/node/app -p 8080:8080 -it vue-cli bash