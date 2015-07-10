#!/bin/bash
dpi=300
mosaicfile=mosaic.tif
resample=bilinear

IFS=:
tifs=()


for file in "$@"
do
  # Quad name with a space
  quadspace=$(gdalinfo $file | grep -Po 'TITLE=USGS 7.5-minute image map for \K.*(?=,.*)')
  # Quad name without a space
  quadnospace=$(echo $quadspace | sed 's/\s/_/')

  # Filename without an extension
  filebase=${file%.*}
  # Filename for un-cropped TIFF
  filetif=$filebase".tif"
  # Filename for cropped TIFF
  filecroppedtif=$filebase"_cropped.tif"

  # Create a GeoTiff
  gdal_translate -of GTiff -co COMPRESS=PACKBITS --config GDAL_PDF_LAYERS_OFF "Map_Collar,Map_Frame.Projection_and_Grids,Images" --config GDAL_PDF_DPI $dpi $file $filetif

  # Create a shapefile of the quadrangle's neatline
  whereexp="NAME='"$quadspace"'"

  # ogr2ogr -overwrite -where $whereexp -nln $quadnospace $quadnospace quad24.shp quad24
  gdalwarp -co COMPRESS=PACKBITS -r $resample -of GTiff -dstalpha -overwrite -cutline quad24.shp -cwhere $whereexp -cl quad24 -crop_to_cutline $filetif $filecroppedtif

  # Add this new cropped files to a list of files to mosaic together later
  tifs+=($filecroppedtif)
  
  # Remove GeoTiffs with collars; no longer needed.
  rm $filetif
done

# Combine all the croppedtifs together. Set 255 as the no-data value so that it turns white when the alpha layer is stripped out.
echo "Creating a mosaic..."
gdalwarp -dstnodata 255 -of GTiff -co BIGTIFF=YES -co COMPRESS=PACKBITS -overwrite ${tifs[@]} mosaictmp.tif

# Strip out the alpha layer
gdal_translate -b 1 -b 2 -b 3 -co COMPRESS=PACKBITS -co TFW=YES mosaictmp.tif $mosaicfile

# Remove temporary files
rm ${tifs[@]}
rm mosaictmp.tif
