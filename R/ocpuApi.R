#' @title hashFromImage 
#' @details \code{traceFromImage} wrapper for use through opencpu.
#' opencpu passes temp object name to function followed by \code{traceToHash}
#' curl -v http://localhost:8004/ocpu/library/finFindR/R/processFinFromHttp/json -F "imageobj=@C:/Users/jathompson/Documents/dolphinTestingdb/jensImgs/test2.jpg"
#' aka: traceFinFromHttp(imageobj = "yourfile1.jpg")
#'
#' Processes an image(cimg) containing a fin. 
#' First the image undergoes cleanup through a variety of filters and glare removal via
#' \code{constrainSizeFinImage} and \code{fillGlare}
#' These processes help enhance edge clarity.
#' The trailing edge is highlighted via neural network. 
#' The image is then cropped down to the trailing edge for efficiency purposes.
#' The canny edges are then extracted from the crop and passed to 
#' \code{traceFromCannyEdges}
#' which isolates coordinates for the trailing edge. These coordinates are then passed to
#' \code{extractAnnulus}
#' which collects image data used for identification.
#' Both the coordinates and the image annulus are then returned.
#' @param imageobj Value of type cimg. Load the image via load.image("directory/finImage.JPG")
#' @return Value of type list containing:
#' "coordinates" a matrix of coordinates
#' "hash" vector specifying an individual
#' @export

hashFromImage <- function(imageobj)
{
  if(class(imageobj)=="character")
  {
    traceResults <- traceFromImage(fin=load.image(imageobj),
                                   startStopCoords = NULL,
                                   pathNet = NULL)
    traceResult <- traceToHash(list(traceResults$annulus))
    traceResult[[2]] <- decodePath(traceResults$coordinates)
    return(traceResult)
  }else{
    traceImg <- list()
    for (imageName in imageobj)
    {
      traceResults <- traceFromImage(fin=load.image(imageName),
                     startStopCoords = NULL,
                     pathNet = NULL)
      traceImg <- append(traceImg,list(traceResults$annulus))
      
      names(traceImg) <- as.character(imageobj)
    }
    return(as.data.frame(traceToHash(traceImg)))
  }
}

#' @title hashFromImageAndEdgeCoord 
#' @details \code{extractAnnulus} wrapper for use through opencpu.
#' if coordinates are generated from finFindR, \code{constrainSizeFinImage} 
#' should be called by setting boundResize = 1
#' opencpu passes temp object name to function followed by \code{traceToHash}
#' curl -v http://localhost:8004/ocpu/library/finFindR/R/processFinFromHttp/json \
#' -F "imageobj=@C:/Users/jathompson/Documents/dolphinTestingdb/jensImgs/test2.jpg"\
#' -F "xvec=[6,7,8,7,6,5,5,6,7,8,9]\
#' -F "yvec=[3,4,5,6,6,5,6,6,7,8,9]
#' aka: traceFinFromHttp(imageobj = "yourfile1.jpg",xvec=c(3,4,5,6,6,5,6,7,8),yvec=c(6,7,8,7,6,5,5,6,7))
#' 
#' \code{extractAnnulus}
#' which collects image data used for identification.
#' Coordinates assume the upper left corner is denoted as 1,1 (recall, R is 1 indexed)
#' @param imageobj Value of type cimg. Load the image via load.image("directory/finImage.JPG")
#' @return hash assiciated with the provided image and trailing edge
#' @export

hashFromImageAndEdgeCoord <- function(imageobj,xvec,yvec,boundResize=F)
{
  if(boundResize)
  {
    finImg <- constrainSizeFinImage(load.image(imageobj))
  }else{
    finImg <- load.image(imageobj)
  }
  annulus <- extractAnnulus(imageFromR=finImg,xCoordinates=xvec,yCoordinates=yvec)
  return(traceToHash(list(annulus)))
}