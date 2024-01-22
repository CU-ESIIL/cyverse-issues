####################################################
#FIRST FIX ATTEMPT FOR CYVERSE:
# ssl_cert_path <- "/opt/conda/envs/macrosystems/lib/python3.10/site-packages/certifi/cacert.pem"
# # Set SSL_CERT_FILE if it is not set or different
# if (Sys.getenv("SSL_CERT_FILE") != ssl_cert_path) {
#   Sys.setenv(SSL_CERT_FILE = ssl_cert_path)
# }
# # Set REQUESTS_CA_BUNDLE if it is not set or different
# if (Sys.getenv("REQUESTS_CA_BUNDLE") != ssl_cert_path) {
#   Sys.setenv(REQUESTS_CA_BUNDLE = ssl_cert_path)
# }

######################################################
#THESE LINES OF CODE WORK LOCALLY, BUT NOT ON CYVERSE

require(glue)
require(sf)
test <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip", #copied link to download location
  "/us_eco_l3.shp") |> #path inside zip file
  sf::st_read()
test2 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l4.zip", #copied link to download location
  "/us_eco_l4_no_st.shp") |> #path inside zip file
  sf::st_read()

print('done')

#HOWEVER, THIS ONE WORKS BOTH LOCALLY AND ON CYVERSE

require(terra)
DEM_continuous_CONUS_15s <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection 
  "https://data.hydrosheds.org/file/hydrosheds-v1-dem/hyd_na_dem_15s.zip", #copied link to download location
  "/hyd_na_dem_15s.tif") |> #path inside zip file
  terra::rast()
