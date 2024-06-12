# PhpThumbContentImages plugin for Evolution CMS
Convert Images in the content field (TinyMCE) to phpthumb images and adds more attributes and features

Required: PhpThumb snippet

### Plugin Configuration

![screenshot-www bs4 bubuna com-2024 05 17-10_39_49](https://github.com/Nicola1971/PhpThumbContentImages/assets/7342798/95a8b6b2-03d2-4553-adfd-0471865d8947)


**Use image sizes from**: get image size for the phpthumb image:  
1) **phpthumbParams**: from phpthumb snippet parameters (w/h) in the configuration tab
2) **imageAttribute**: from image attributes (width/height). **NOTE**: if image width & height attributes are empty the image will not be resized

**Image width**: phpthumb options (w)

**Image height**: phpthumb options (h)

**Image quality**: phpthumb options (q)

**Image Zoom crop**: phpthumb options (zc)

**Image Format**: phpthumb options (f)

**Image Class**: Add new or modifies image class

**fetchpriority**: Add fetchpriority attribute (no/auto/low/high)

**loading**: Add loading attribute (lazy)

**Change src to data-src**: Change image "src" tag to "data-src" for lazyload plugins
