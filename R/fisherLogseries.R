#' @title Fisher's logseries
#'  
#' @description \code{dfish} gives the probability mass function, \code{pfish} gives the cumulative mass 
#' function, \code{qfish} the quantile function, \code{rfish} randome number generation
#' 
#' @details These functions assume infinite support of the Fisher logseries from [1, Inf).  An alternate parameterization is used to allow a larger range (i.e. the positive number line) of the parameter \code{beta}: \eqn{\frac{1}{log(1/(1-e^{-\beta}))} * \frac{e^{-\beta x}}{x}}.
#' 
#' @param x vector of integers for which to return the probability
#' @param q vector of integers for which to return the cumulative probability
#' @param p vector of probabilities for which to return the quantile
#' @param n number of random replicates
#' @param beta parameter of the Fisher log series, see Details
#' @param log logical, should the log probability be used
#' @param lower.tail logical, should the lower tail be used
#' 
#' @keywords Fisher logseries, species abundance, SAD
#' @export
#' 
#' @examples
#' 
#' dfish(1:10, 0.01)
#' 
#' @return A numeric vector of length equal to the input
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
# @seealso 
# @references 

#' @rdname Fisher

dfish <- function(x, beta, log=FALSE) {
    out <- 1/log(1/(1-exp(-beta))) * exp(-beta*x)/x
    
    if(any(x %% 1 != 0)) {
        for(bad in x[x %% 1 != 0]) {
            warning(sprintf('non-integer x = %s', bad))
        }
        
        out[x %% 1 != 0] <- 0
    }
    
    out[x < 1] <- 0
    
    if(log) out <- log(out)
    return(out)
}


#' @export
#' @rdname Fisher

pfish <- function(q, beta, lower.tail=TRUE, log=FALSE) {
    out <- 1 + .betax(exp(-beta), q+1, 0) / log(1 - exp(-beta))
    
    if(any(q %% 1 != 0)) {
        for(bad in q[q %% 1 != 0]) {
            warning(sprintf('non-integer q = %s', bad))
        }
        
        out[q %% 1 != 0] <- 0
    }
    
    out[q < 1] <- 0
    
    if(!lower.tail) out <- 1 - out
    if(log) out <- log(out)
    return(out)
}


#' @export
#' @rdname Fisher

qfish <- function(p, beta, lower.tail=TRUE, log=FALSE) {
    if(log) p <- exp(p)
    if(!lower.tail) p <- 1 - p
    
    out <- .fishcdfinv(p, beta)
    
    if(any(is.nan(out))) {
        warning('NaNs produced')
    }
    
    return(out)
}


#' @export
#' @rdname Fisher

rfish <- function(n, beta) {
    return(.its(n, .fishcdfinv, pfish(0, beta), beta=beta))
}


## =================================
## helper functions
## =================================

## fisher pdf
.fishpdf <- function(x, beta) {
    1/log(1/(1-exp(-beta))) * exp(-beta*x)/x
}

## solution to the beta function using the hypergeometic for better accuracy
#' @export
.betax <- function(x, a, b) {
    ## x = exp(-beta)
    ## a = data value + 1
    ## b = 0
    ## ==> in standard notation 2F1(a, b; c; z)
    ## a = data value + 1
    ## b = 1
    ## c = data value + 2
    ## z = exp(-beta)
    1/a * x^a * (1-x)^b * gsl::hyperg_2F1(a+b, 1, a+1, x)
}

## cdf of the fisher log series
#' @export
.fishcdf <- function(x, beta) {
    ## crit is based on empirically derived bounds of convergance of gsl::hyperg_2F1
    crit <- x > exp(-36)*exp(-beta)^-46653
    out <- numeric(length(x))
    
    if(any(!crit)) {
        out[!crit] <- 1 + .betax(exp(-beta), x[!crit]+1, 0) / log(1 - exp(-beta))
        out[crit] <- out[!crit][sum(!crit, na.rm=TRUE)] + cumsum(.fishpdf(x[crit], beta))
    } else {
        out[crit] <- cumsum(.fishpdf(x[crit], beta))
    }
    
    return(out)
}


## inverse cdf of the fisher log series
#' @export
.fishcdfinv <- function(p, beta) {
    approx(x=.fishcdf(0:10000, beta), y=0:10000, xout=p, method='constant', 
           yleft=NaN, yright=Inf, f=1)$y
}
