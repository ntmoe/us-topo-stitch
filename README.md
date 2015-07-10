# us-topo-stitch
A `bash` script to stich together U.S. Topo maps.

Requires a working `GDAL` installation.

Requires the shapefile `quad24.shp` and its associated files to be in the same directory as the script. You can obtain `quad24.shp` from `http://data.geocomm.com/catalog/US/group127.html`

Usage:

    $ ./script [list of GeoPDF files]

The mosaic is output to `mosaic.tif`, with a world file output to `mosaic.tfw`.
