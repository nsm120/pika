% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logLikMethods.R
\name{logLik.sad}
\alias{logLik.sad}
\alias{logLikZ}
\alias{logLikZ.sad}
\title{Log likelihood methods for objects of class \code{sad}}
\usage{
\method{logLik}{sad}(x)

logLikZ(x, ...)

\method{logLikZ}{sad}(x, ...)
}
\arguments{
\item{x}{an object of class \code{sad}}

\item{...}{arguments to be passed to methods}
}
\value{
\code{logLik} returns an object of class \code{logLik} with attributes "\code{df}" and "\code{nobs}". 
\code{logLikZ} returns a list with elements
\describe{
   \item{z}{The z-score}
   \item{obs}{The observed log-likelihood of the actual data set}
}
}
\description{
Compute log likelihood and likelihood-based z-scores for objects of class \code{sad}.
}
\details{
\code{logLikZ.sad} 
simulates from a fitted SAD and calculates the likelihood of these simulated data sets. 
The distribution of these values is compared against the likelihood of the data to obtain 
a z-score.
}
\examples{
x <- rtpois(1000, 2)
sad1 <- fitSAD(x, models='tpois')
logLik(sad1[[1]])

}
\seealso{
fitSAD, logLik
}
\author{
Andy Rominger <ajrominger@gmail.com>
}
\keyword{SAD,}
\keyword{abundance,}
\keyword{likelihood}
\keyword{log}
\keyword{species}
