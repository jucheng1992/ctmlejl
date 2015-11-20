logit <- function(x){
      res = log(x/ (1-x))
      return(res)
}


n <- 1000
p <- 10
QnA1 <- runif(n)
QnA0 <- runif(n)
w <- matrix(rnorm(n * p), n, p)
a <- sample(c(0,1), n, replace = TRUE)
y <- sample(c(0,1), n, replace = TRUE)
gn1 <- runif(n)

tmle(logit(QnA1), logit(QnA0), w, a, y, gn1,
      param = "ATE")

ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095), patience =p, param = "Mean0")
ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095), patience =p, param = "Mean1")
ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095), patience =p, param = "ATE")

system.time(
      ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095),
            patience =p, searchstrategy = "LogisticOrdering")
)
