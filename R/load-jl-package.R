# load rjulia package, initialize julia, and install related packages.
#' @import rjulia
julia_init() 
julia_void_eval("using DataArrays")
julia_void_eval("using NumericExtensions")
julia_void_eval("using Distributions")
julia_void_eval("using TargetedLearning")
julia_void_eval("using DataFrames")
julia_void_eval("using GLM")
julia_void_eval("import StatsBase.predict")
