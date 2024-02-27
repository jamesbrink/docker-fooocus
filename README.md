# Fooocus

## About

Simple docker image for the [Fooocus web interface][Foocus]. 

## Usage

Build and run the container container:
```shell
make
docker run -i -t --gpus all -p 7865:7865 -v ./models:/fooocus/models -v ./outputs:/fooocus/outputs jamesbrink/fooocus
```

[Foocus]: https://github.com/lllyasviel/Fooocus