## Aims
This Dockerfile aims for build libheif/libvips in centos7 easier. With this dockerfile, you do not need to care about dependencies error in building phase.

## samples
```bash 
# build libheif with dependencies and all building tools inside image (About 3.8G disk space needs)
`docker build --target=libheif -t libheif . `

# build libheif and heif tools chains without dependencies inside image (About Only 400M disk space needs)
`docker build --target=libheif -t heif-tools . `

# build libheif and libvips with dependencies and all building tools inside image (About 4G disk space needs)
`docker build --target=libvips -t libvips . `

# build libheif and libvips with dependencies and all building tools inside image (About 4G disk space needs)
`docker build --target=libvips -t vips-tool . `
```


## Other docker build Args
`docker build --build-args ARG=VAL`

### platform chioce opts:
--build-args PLATFORM=linux/arm64 for `arm` arch

### dependcies libs version chioce opts:
--build-args DE265_VERSION for libde265 version

--build-args X265_VERSION for libx265 version

--build-args AOM_VERSION for libaom version

--build-args VVENC_VERSION for libvvenc version

--build-args VVDEC_VERSION for libvvdec version

--build-args LIBWEBP_VERSION for libwebp version

--build-args LIBHEIF_VERSION for libheif version

--build-args LIBVIPS_VERSION for libvips version

`note`: **Use default value is more recommended**

## Usage for heif tools (jpg to heif, heif to jpg)
After building heif-tools，use command as below to convert jpg2heif

### list encoders: 
`docker run --rm -v /work/path:/container/path  ghcr.io/navyum/heif-tools:heif-tool heif-enc --list-encoders`
### with x265:  
`docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:heif-tool heif-enc /container/path/xx.jpg -o /container/path/xx.heif`
### with aom: 
`docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:heif-tool heif-enc /container/path/xx.jpg -A -o /container/path/xx.avif`
### with acc: 
`docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:heif-tool heif-enc /container/path/xx.jpg --acc -o /container/path/xx.heif`
### view boxs of heif: 
`docker run --rm -v /work/path:/container/path --entrypoint heif-info ghcr.io/navyum/heif-tools:heif-tool /container/path/xx.heif`

## Usage for vips tool (convert more image format)
After building vips-tool，use command as below to convert jpg2heif, other format to heif and other formats convert each other
```bash
docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:vips-tool vips copy xx.jpg  xx.heif
docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:vips-tool vips copy xx.heif xx.webp
docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:vips-tool vips copy xx.wepb xx.avif
docker run --rm -v /work/path:/container/path ghcr.io/navyum/heif-tools:vips-tool vips copy xx.avif xx.jpg
```
