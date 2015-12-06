##' A function compute ctmle estimator and its standard error based on julia package TargetedLearning.jl.
##' @title ctmle
##' @param logitQnA1 numeric vector containing initial estimates for treatment group in logit scale.
##' @param logitQnA0 numeric vector containing initial estimates for control group in logit scale.
##' @param W numeric matrix or dataframe, stand for covariates.
##' @param A numeric 1-0 vector, stand for treatment.
##' @param Y numeric vector, stand for outcome.
##' @param v integer, stand for number of folds for cross-validation in cTMLE.
##' @param gbounds: a  vector of numeric of length two (with both of them in [0,1]), stand for the truncation boud for gn.
##' @param searchstrategy  Strategy for adding covariates to estimates of g. Default is "ForwardStepwise". Other options: "LogisticOrdering", "PartialCorrOrdering",  "SuperLearner"
##' @param patience Integer. For how many steps should CV continue after finding a local optimum? Defaults to typemax(Int).
##' @param param a string stand for different target parameter. "ATE" stands for additive  treatment effect, Mean1 and Mean0 stand for the mean outcome in treatment or control group.
##' @param order an integer vector for the manual ordering option. Notice, the first column is intercept, so the indexes start from 2.
##' @return A list for targeted estimator and standard error.
##' @author Cheng JU
##' @export
ctmle <- function(logitQnA1, logitQnA0,
                  W, A, Y,
                  v = 10,
                  gbounds = c(0, 1),
                  searchstrategy = "ForwardStepwise",
                  patience = 100,
                  penalize_risk = TRUE,
                  param = "ATE",
                  order =  vector()){
      # This function will call ctmle in TargetedLearning.jl from julia.
      #
      # Args:
      #     logitQnA1: Vector of length n of initial estimates QnA1 in logit scale.
      #     logitQnA0: Vector of length n of initial estimates QnA0 in logit scale.
      #     W: Matrix of covariates to be potentially used to estimate g. n rows.
      #           (Do not require add ones for first column. This function will do it later.)
      #     A: Vector of length n of treatments, 0.0 or 1.0.
      #     Y: Vector of length n of outcomes, bounded between 0 and 1.
      #     v: number of folds for CV.
      #     gbounds: a length two vector, stand for lower and up bound for truncation gn1
      #     searchstrategy: Strategy for adding covariates to estimates of g. Default is
      #           "ForwardStepwise". Other options: "LogisticOrdering", "PartialCorrOrdering",
      #           "SuperLearner" and "ManualOrdering".
      #     patience: For how many steps should CV continue after finding a local optimum?
      #           Defaults to typemax(Int)
      #     param: a string stand for different target parameter. "ATE" stands for additive
      #           treatment effect, Mean1 and Mean0 stand for the mean outcome in treatment
      #           or control group.
      #     order: an integer vector for the manual ordering option. Notice, the first column is 
      #           intercept, so the indexes start from 2.
      # Return:
      #     a list with point estimator and its estimated standar error.


      # Add ones as first column of W
      # This is required by cTMLE in julia.
      n <- length(A)
      W <- cbind(rep(1, n), W)

      # Change variables to julia.
      r2j(Y, "outcome")
      r2j(A, "treatment")
      r2j(W, "baseline_covars")
      r2j(logitQnA1, "logitQnA1")
      r2j(logitQnA0, "logitQnA0")
      r2j(gbounds, "bound")
      r2j(patience, "patience")
      r2j(order, "order")
      julia_void_eval("n=length(treatment)")

      # Convert some variables to the required data type.
      julia_void_eval("treatment = convert(Array{Float64}, treatment)")
      julia_void_eval("outcome = convert(Array{Float64}, outcome)")

      if (param == "ATE"){
            julia_void_eval("param = ATE()")
      }else if (param == "Mean1"){
            julia_void_eval("param = Mean(1)")
      }else if (param == "Mean0"){
            julia_void_eval("param = Mean(0)")
      }else{
            stop("The options for param is ATE, Mean1 and Mean0")
      }

      # V folds cross-validation.
      r2j(v, "v")
      julia_void_eval("cvplan = collect(StratifiedKfold(treatment,v[1]))")

      # Set patience parameter
      r2j(patience, "patience")
      julia_void_eval("patience = convert(Integer,patience[1])")

      if (searchstrategy == "ForwardStepwise"){
            julia_eval("ctmle_res =  ctmle(logitQnA1, logitQnA0, baseline_covars,
                              treatment, outcome, cvplan=cvplan, gbounds = bound,
                                                      patience = patience[1],
                                                      param = param)")

      }else if(searchstrategy == "LogisticOrdering"){
            julia_eval("ctmle_res =  ctmle(logitQnA1, logitQnA0, baseline_covars,
                              treatment, outcome, cvplan=cvplan, gbounds = bound,
                              searchstrategy =PreOrdered( LogisticOrdering()),
                                                       param = param)")
      }else if(searchstrategy == "PartialCorrOrdering"){
            julia_eval("ctmle_res =  ctmle(logitQnA1, logitQnA0, baseline_covars,
                              treatment, outcome, cvplan=cvplan, gbounds = bound,
                              searchstrategy =PreOrdered( PartialCorrOrdering()),
                                                       param = param)")
      }else if(searchstrategy == "SuperLearner"){
            julia_eval("ctmle_res =  ctmle(logitQnA1, logitQnA0, baseline_covars,
                              treatment, outcome, cvplan=cvplan, gbounds = bound,
                              searchstrategy = [ForwardStepwise(),
                                       PreOrdered(PartialCorrOrdering()),
                                       PreOrdered(LogisticOrdering())],
                                                       param = param)")
      }else if(searchstrategy == "ManualOrdering"){
            julia_eval("ctmle_res =  ctmle(logitQnA1, logitQnA0, baseline_covars,
                              treatment, outcome, cvplan=cvplan, gbounds = bound,
                              searchstrategy =PreOrdered(CTMLEs.ManualOrdering(order)),
                                                       param = param)")
            
      }

      se <- j2r("sqrt(var(ctmle_res.ic))/sqrt(n)")
      psi <- j2r("ctmle_res.psi")
      result <- list(psi = psi, se = se )
      return(result)
}



##' A function compute ctmle estimator and its standard error based on julia package TargetedLearning.jl.
##' @title tmle
##' @param logitQnA1 logitQnA1 numeric vector containing initial estimates for treatment group in logit scale.
##' @param logitQnA0 logitQnA0 numeric vector containing initial estimates for control group in logit scale.
##' @param W numeric matrix or dataframe, stand for covariates.
##' @param A numeric 1-0 vector, stand for treatment.
##' @param Y numeric vector, stand for outcome.
##' @param gn1 numeric vector, stand for estimated probability of treatment (propensity score).
##' @param param a string stand for different target parameter. "ATE" stands for additive  treatment effect, Mean1 and Mean0 stand for the mean outcome in treatment or control group.
##' @return A list for targeted estimator and standard error.
##' @author Cheng JU
##' @export
tmle <- function(logitQnA1, logitQnA0,
                 W, A, Y, gn1,
                 param = "ATE"){
      # This function will call ctmle in TargetedLearning.jl from julia.
      #
      # Args:
      #     logitQnA1: Vector of length n of initial estimates QnA1 in logit scale.
      #     logitQnA0: Vector of length n of initial estimates QnA0 in logit scale.
      #     W: Matrix of covariates to be potentially used to estimate g. n rows.
      #           (Do not require add ones for first column. This function will do it later.)
      #     A: Vector of length n of treatments, 0.0 or 1.0.
      #     Y: Vector of length n of outcomes, bounded between 0 and 1.
      #     param: a string stand for different target parameter. "ATE" stands for additive
      #           treatment effect, Mean1 and Mean0 stand for the mean outcome in treatment
      #           or control group.
      
      
      # Add ones as first column of W
      # This is required by cTMLE in julia.
      n <- length(A)
      W <- cbind(rep(1, n), W)
      
      # Change variables to julia.
      r2j(Y, "outcome")
      r2j(A, "treatment")
      r2j(W, "baseline_covars")
      r2j(logitQnA1, "logitQnA1")
      r2j(logitQnA0, "logitQnA0")
      julia_void_eval("n=length(treatment)")
      
      # Convert some variables to the required data type.
      julia_void_eval("treatment = convert(Array{Float64}, treatment)")
      julia_void_eval("outcome = convert(Array{Float64}, outcome)")
      
      if (param == "ATE"){
            julia_void_eval("param = ATE()")
      }else if (param == "Mean1"){
            julia_void_eval("param = Mean(1)")
      }else if (param == "Mean0"){
            julia_void_eval("param = Mean(0)")
      }else{
            stop("The options for param is ATE, Mean1 and Mean0")
      }
      
      r2j(gn1, "gn1")
      julia_eval("ctmle_res =  tmle(logitQnA1, logitQnA0,
                       gn1, treatment, outcome, param=ATE(), weightedfluc=false,
                                                       param = param)")
      se <- j2r("sqrt(var(ctmle_res.ic))/sqrt(n)")
      psi <- j2r("ctmle_res.psi")
      result <- list(psi = psi, se = se )
      return(result)
}








