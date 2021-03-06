#' @title Truncated negative binomial distribuiton
#'  
#' @description \code{dptnegb} gives the probability mass function, \code{ptnegb} gives the cumulative mass 
#' function, \code{qtnegb} the quantile function, \code{rtnegb} randome number generation
#' 
#' @details These functions assume infinite support of the truncated negative binomial from [1, Inf).  The parameterization uses the mean of the untruncated distribution (\eqn{\mu}) and the dispersion (\eqn{k}).  This relates to a Gamma-Poisson mixture as \eqn{trunNB(x; \mu, k) = \int_0^{\inf} trunPois(x; \lambda) Gamma(\lambda; k, k/\mu)}.
#' 
#' @param x vector of integers for which to return the probability
#' @param q vector of integers for which to return the cumulative probability
#' @param p vector of probabilities for which to return the quantile
#' @param n number of random replicates
#' @param mu mean abundance
#' @param k dispersion parameter
#' @param log logical, should the log probability be used
#' @param lower.tail logical, should the lower tail be used
#' 
#' @keywords Truncated negative binomial, species abundance, SAD
#' @export
#' 
#' @examples
#' 
#' dtnegb(1:10, 0.5, 2)
#' 
#' @return A numeric vector of length equal to the input
#'
#' @author Andy Rominger <ajrominger@@gmail.com>
#' @seealso dnbinom
# @references 

#' @rdname TNegBinom

dtnegb <- function(x, mu, k, log=FALSE) {
    if(log) {
        out <- dnbinom(x, mu=mu, size=k, log=TRUE) - log(1 - dnbinom(0, mu=mu, size=k))
        out[x < 1] <- -Inf
    } else {
        out <- dnbinom(x, mu=mu, size=k) / (1 - dnbinom(0, mu=mu, size=k))
        out[x < 1] <- 0
    }
    
    return(out)
}


#' @export
#' @rdname TNegBinom

ptnegb <- function(q, mu, k, lower.tail=TRUE, log=FALSE) {
    if(lower.tail) {
        out <- (pnbinom(q, mu=mu, size=k) - dnbinom(0, mu=mu, size=k)) / (1 - dnbinom(0, mu=mu, size=k))
    } else {
        out <- pnbinom(q, mu=mu, size=k, lower.tail=FALSE) / (1 - dnbinom(0, mu=mu, size=k))
    }
    
    out[q < 1] <- 0
    if(log) out <- log(out)
    return(out)
}


#' @export
#' @rdname TNegBinom

qtnegb <- function(p, mu, k, lower.tail=TRUE, log=FALSE) {
    if(log) p <- exp(p)
    if(!lower.tail) p <- 1 - p
    
    return(qnbinom(p*(1-dnbinom(0, mu=mu, size=k)) + dnbinom(0, mu=mu, size=k), mu=mu, size=k))
}


#' @export
#' @rdname TNegBinom

rtnegb <- function(n, mu, k) {
    return(.its(n, qtnegb, dtnegb(0, mu, k), mu=mu, k=k))
}
