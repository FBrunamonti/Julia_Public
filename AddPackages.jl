# Install
using Pkg

##--------------------------
# Mathematics
function mathematics()
    Pkg.add("ForwardDiff")
    Pkg.add("ApproxFun")
    Pkg.add("Polynomials")
    Pkg.add("NLsolve")
    Pkg.add("Equations")
    Pkg.add("LinearAlgebra")
    Pkg.add("ODE")
    Pkg.add("Parameters")
    Pkg.add("Calculus")
    Pkg.add("TaylorSeries")
    Pkg.add("Roots")
end

##--------------------------
# Probability and Statistics
function statistics()
    Pkg.add("MultivariateStats")
    Pkg.add("TimeSeries")
    Pkg.add("HypothesisTests")
    Pkg.add("KernelDensity")
    Pkg.add("Bootstrap")
    Pkg.add("GaussianMixtures")
    Pkg.add("KernelEstimator")
    Pkg.add("Statistics")
    Pkg.add("Distributions")
    Pkg.add("StatsBase")
    Pkg.add("Loess")
end

##--------------------------
# Regression
function regressions()
    Pkg.add("GLM")
    Pkg.add("Lasso")
    Pkg.add("CurveFit")
    Pkg.add("SparseRegression")
    Pkg.add("FixedEffectModels")
    Pkg.add("StatsModels")
    Pkg.add("LeastSquaresOptim")
end

##--------------------------
# Supercomputing
function supercomputing()
    Pkg.add("SimJulia")
    Pkg.add("CPUTime")
    Pkg.add("Optim")
    Pkg.add("BlackBoxOptim")
    Pkg.add("BenchmarkTools")
    Pkg.add("TimerOutputs")
    Pkg.add("IterativeSolvers")
    Pkg.add("DistributedArrays")
end

##--------------------------
# Numerical Analysis
function numerical()
    Pkg.add("Interpolations")
    Pkg.add("FastTransforms")
    Pkg.add("RandomMatrices")
    Pkg.add("RandomNumbers")
end

##--------------------------
# Econometrics
function econometrics()
    Pkg.add("QuantEcon")
    Pkg.add("Expectations")
    Pkg.add("GARCH")
    Pkg.add("Econometrics")
    Pkg.add("Currencies")
    Pkg.add("InterestRates")
    Pkg.add("ARCHModels")
end

##--------------------------
# Data
function data()
    Pkg.add("FredData")
    Pkg.add("MarketData")
end

##--------------------------
# Plots
function plots()
    Pkg.add("Plots")
    Pkg.add("PlotThemes")
    Pkg.add("Gadfly")
    Pkg.add("Compose")
    Pkg.add("StatsPlots")
    Pkg.add("Colors")
    Pkg.add("VegaLite")
end

##--------------------------
# General
function general()
    Pkg.add("RCall")
    Pkg.add("RDatasets")
    Pkg.add("Weave")
    Pkg.add("Dates")
    Pkg.add("Measures")
    Pkg.add("ProgressBars")
    Pkg.add("DataConvenience")
    Pkg.add("Interact")
end

##--------------------------
# Scraping
function scraping()
    Pkg.add("HTTP")
    Pkg.add("Gumbo")
    Pkg.add("Cascadia")
    Pkg.add("JSON")
    Pkg.add("Downloads")
end

##--------------------------
# Read files
function files()
    Pkg.add("CSV")
    Pkg.add("XLSX")
    Pkg.add("DataFrames")
    Pkg.add("ExcelReaders")
    Pkg.add("ExcelFiles")
    Pkg.add("DelimitedFiles")
    Pkg.add("Tables")
    Pkg.add("ReadStat")
    Pkg.add("StatFiles")
end

##--------------------------
# Read files
function LaTeX()
    Pkg.add("LaTeXStrings")
    Pkg.add("RegressionTables")
end

##--------------------------
function precompiles()
    Pkg.build("SpecialFunctions")
    Pkg.build("FFTW")
    Pkg.build("Rmath")
    Pkg.build("RCall")
end

##--------------------------
function addall()
    mathematics()
    statistics()
    regressions()
    scraping()
    supercomputing()
    numerical()
    econometrics()
    data()
    plots()
    general()
    files()
    LaTeX()
    precompiles()
end

##--------------------------
addall()

using ForwardDiff, ApproxFun, Polynomials, NLsolve, Equations, LinearAlgebra, ODE, Parameters, Calculus, TaylorSeries, Roots
using MultivariateStats, TimeSeries, HypothesisTests, KernelDensity, Bootstrap, GaussianMixtures, KernelEstimator, Statistics, Distributions, StatsBase, Loess
using GLM, Lasso, CurveFit, SparseRegression, FixedEffectModels, StatsModels, LeastSquaresOptim
using SimJulia, CPUTime, Optim, BlackBoxOptim, BenchmarkTools, TimerOutputs, IterativeSolvers, DistributedArrays
using Interpolations, FastTransforms, RandomMatrices, RandomNumbers
using QuantEcon, Expectations, GARCH, Econometrics, Currencies, InterestRates, ARCHModels
using FredData, MarketData
using Plots, PlotThemes, Gadfly, Compose, StatsPlots, Colors, VegaLite
using RCall, RDatasets, Weave, Dates, Measures, ProgressBars, DataConvenience, Interact
using HTTP, Gumbo, Cascadia, JSON, Downloads
using CSV, XLSX, DataFrames, ExcelReaders, ExcelFiles, DelimitedFiles, Tables, ReadStat, StatFiles
using LaTeXStrings, RegressionTables
