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

test_that("Test argument parameter=Mean0 for cTMLE", {
      expect_equal(length(ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, 
            gbounds=c(0.025,0.095), patience =p, param = "Mean0")), 2)
})

test_that("Test argument parameter=Mean1 for cTMLE", {
      expect_equal(length(ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5,
            gbounds=c(0.025,0.095), patience =p, param = "Mean1")), 2)
})

test_that("Test argument parameter=ATE for cTMLE", {
      expect_equal(length(ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, 
            gbounds=c(0.025,0.095), patience =p, param = "ATE")), 2)
})


test_that("Test argument searchstrategy = 'LogisticOrdering'", {
      expect_equal(length(ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095),
            patience =p, searchstrategy = "LogisticOrdering")), 2)
})

test_that("Test argument searchstrategy = 'ManualOrdering'", {
      expect_equal(length(ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095),
            patience =p, searchstrategy = "ManualOrdering", order = 2:11)), 2)
})
