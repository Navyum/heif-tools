## Aims
This Dockerfile aims for build libheif/libvips in centos7 easier. With this dockerfile, you do not need to care about dependencies error in building phase.

## samples
```bash 
# build libheif with dependencies and all building tools inside image (About 3.8G disk space needs)
Docker build --target=libheif -t libheif . 

# build libheif and heif tools chains without dependencies inside image (About Only 400M disk space needs)
Docker build --target=libheif -t heif-tools . 

# build libheif and libvips with dependencies and all building tools inside image (About 4G disk space needs)
Docker build --target=libvips -t libvips . 

# build libheif and libvips with dependencies and all building tools inside image (About 4G disk space needs)
Docker build --target=libvips -t vips-tool . 
```


## Other docker build Args
--build-args PLATFORM=linux/arm for `arm` arch

--build-args DE265_VERSION for libde265 version

--build-args X265_VERSION for libx265 version

--build-args AOM_VERSION for libaom version

--build-args VVENC_VERSION for libvvenc version

--build-args VVDEC_VERSION for libvvdec version

--build-args LIBWEBP_VERSION for libwebp version

--build-args LIBHEIF_VERSION for libheif version

--build-args LIBVIPS_VERSION for libvips version

`note`: **Use default value is more recommended**

## Usage for heif tools
After building heif-tools，use command as below to convert jpg2heif
list encoders: `docker run --rm ${ghcr}/heif-tools heif-enc --list-encoders`

with x265:  `docker run --rm ${ghcr}/heif-tools heif-enc xx.jpg -o xx.heif`
with aom: `docker run --rm ${ghcr}/heif-tools heif-enc xx.jpg -A -o xx.avif`
with acc: `docker run --rm ${ghcr}/heif-tools heif-enc xx.jpg --acc -o xx.heif`

view boxs of heif: `docker run --rm ${ghcr}/heif-tools --entrypoint heif-info xx.heif`

## Usage for vips tools
After building vips-tools，use command as below to convert jpg2heif, other format to heif and other formats convert each other
```bash
vips copy xx.jpg xx.heif
vips copy xx.heif xx.webp
vips copy xx.wepb xx.avif
vips copy xx.avif xx.jpg
```
