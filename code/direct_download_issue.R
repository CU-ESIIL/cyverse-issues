

#####################################
# This code is for a simple direct data download from a URL.
# The code works locally, but not on CyVerse. Error in comment at end
computing <- "cyverse"
if(computing == "local") {
  rawDir <- here::here('data', 'raw')
} else if(computing == "cyverse") {
  rawDir <- "~/data-store/data/iplant/home/shared/earthlab/macrosystems/disturbance-stack-patch-analysis/data/raw"
}
if (!dir.exists(rawDir)){
  dir.create(rawDir)
}

#Avoid download timeout
options(timeout = max(500, getOption("timeout")))

#URLs for downloads
epaUrls <- c("https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip",
             "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l4.zip")
destFiles <- file.path(rawDir, basename(epaUrls))

#Download
mapply(FUN = function(url, destfile) {download.file(url = url,
                                                    destfile = destfile,
                                                    mode = "w")},
       url = epaUrls,
       destfile = destFiles)

#Unzip downloaded files
mapply(FUN = function(destfile, exdir) {unzip(zipfile = destfile,
                                              files = NULL,
                                              exdir = exdir)},
       destfile = destFiles,
       exdir = gsub(pattern = ".zip", replacement = "", x = destFiles))


###########################

# Warning message in download.file(url = url, destfile = destfile, mode = "w"):
#   “URL 'https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip': status was 'SSL peer certificate or SSH remote key was not OK'”
# Error in download.file(url = url, destfile = destfile, mode = "w"): cannot open URL 'https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip'
# Traceback:
#   
#   1. mapply(FUN = function(url, destfile) {
#     .     download.file(url = url, destfile = destfile, mode = "w")
#     . }, url = epaUrls, destfile = destFiles)
# 2. (function (url, destfile) 
#   . {
#     .     download.file(url = url, destfile = destfile, mode = "w")
#     . })(url = dots[[1L]][[1L]], destfile = dots[[2L]][[1L]])
# 3. download.file(url = url, destfile = destfile, mode = "w")   # at line 10-12 of file <text>