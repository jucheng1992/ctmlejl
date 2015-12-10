ctmlejl: an interface to julia package TargetedLearning.jl


--------------------------

This package built a interfact to julia package TargetedLearning (https://lendle.github.io/TargetedLearning.jl/) based on rjulia project (https://github.com/armgong/RJulia).

For details of Targeted Learning, see the book Van der Laan, Mark J., and Sherri Rose. Targeted learning: causal inference for observational and experimental data. Springer Science & Business Media, 2011., or https://lendle.github.io/TargetedLearning.jl/


--------------------------
### Installation julia

Before using this package, ensure you have julia (v0.4.x.) installed. If not, you can download latest version of julia in http://julialang.org/downloads/

For mac users, use symbolic link so you can simply call julia in terminal (else rjulia package can not be installed):

```
ln -s /Applications/Julia-0.4.1.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia

```

Finally, simply open julia by type `julia` in terminal. In julia, you need install several packages:

```
Pkg.add("GLM")
Pkg.clone("https://github.com/lendle/TargetedLearning.jl.git")
```


### Installation

Install devtools package:

```
install.packages("devtools")
```

Install rjulia package from github:
```
devtools::install_github("armgong/rjulia", ref="master")
```


Install ctmlejl package from github:
```
devtools::install_github("jucheng1992/ctmlejl")
```

### Initialize julia

For some technical reasons, this package is not able to automatic load julia package for you. You may manually initialize it:


```
julia_init() 
julia_void_eval("using DataArrays")
julia_void_eval("using NumericExtensions")
julia_void_eval("using Distributions")
julia_void_eval("using TargetedLearning")
julia_void_eval("using DataFrames")
julia_void_eval("using GLM")
julia_void_eval("import StatsBase.predict")

```

### Examples using cTMLE model:


Here is some examples about using cTMLE models:


```
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


ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095),
      patience =p, searchstrategy = "LogisticOrdering")

ctmle(logit(QnA1), logit(QnA0), w, a, y, v=5, gbounds=c(0.025,0.095),
      patience =p, searchstrategy = "ManualOrdering", order = 2:11)
```