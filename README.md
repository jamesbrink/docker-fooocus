# Docker image for Fooocus (Stable Diffusion)

## About

Simple docker image for the [Fooocus web interface][Foocus]. 

## Usage

Build and run the container container:  

```shell
make
docker run -i -t --gpus all -p 7865:7865 -v ./models:/fooocus/models -v ./outputs:/fooocus/outputs jamesbrink/fooocus
```

If you want to share models between Fooocus and tools like ComfyUI, you can map the volumes like so:  

```shell
mkdir -p ~/AI/Models/StableDiffusion/
mkdir -p ~/AI/Output
```

Then simply run the container with the newly mapped volumes:  

```shell
docker run -d --gpus all --network=host -v ~/AI/Models/StableDiffusion/:/fooocus/models -v ~/AI/Output:/fooocus/output --name fooocus jamesbrink/fooocus
```

Running with CPU model only:  

```shell
docker run -d --network=host -v ~/AI/Models/StableDiffusion/:/fooocus/models -v ~/AI/Output:/fooocus/output --restart=always --name fooocus jamesbrink/fooocus --listen --always-cpu --preset lightning
```

[Foocus]: https://github.com/lllyasviel/Fooocus