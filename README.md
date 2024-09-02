# Scarab-infra-light
This project provides a simple command-line interface to build, run, and execute a Docker container


## Prerequisites
- Docker must be installed and running on your system.
- `jq` must be installed on your system to parse JSON from the configuration file.


## Usage
- **Update the Configuration Json File**

- **Build the Docker Image**
```
./run_docker.sh build
```

- **Run the Docker Container**
```
./run_docker.sh run
```

- **Execute into the Docker Container**
```
./run_docker.sh exec
```
