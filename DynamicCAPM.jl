## ------------------------------
# Import
using DataFrames

using MarketData

using Gadfly

using RCall

## ------------------------------
# Define function
function getData(ticker, variable)
    data = DataFrame(yahoo(ticker))
    select!(data, 1, 6) # <- timestamp, AdjClose

    if variable == "x"
        colnames = ["Date", "Benchmark"]
        DataFrames.rename!(data, Symbol.(colnames))
    else
        colnames = ["Date", "Stock"]
        DataFrames.rename!(data, Symbol.(colnames))
    end

    return data
end

function customjoin(stockData, benchmarkData)
    df = innerjoin(stockData, benchmarkData, on = :Date)
    dropmissing!(df)
    return df
end

function dlog(vector)
    dlog = diff(log.(vector))
    return dlog
end

## ------------------------------
# Parameters
stock = "C"
benchmark = "^GSPC"

stock_name = "Citigroup"
benchmark_name = "S&P 500"

signif = 0.10

## ------------------------------
# Get data
stockData = getData(stock, "y")
benchmarkData = getData(benchmark, "x")

df = customjoin(stockData, benchmarkData)

y = dlog(df[!, 2])
x = dlog(df[!, 3])
dates = df[!, 1]

## ----------------------
# Rput
@rput dates
@rput stock
@rput x
@rput y
@rput benchmark
@rput signif

# RCall
R"""
"Packages"
library('dlm')

"Functions"
buildDynamicCAPM <- function(param){
    dlmModReg(
        x,
        dV = param[1],
        dW = param[2:3],
        m0 = c(0, 1.5)
    )
}

"Estimate"
outMLE = dlmMLE(
    y,
    c(1, 0.5, 0.5),
    buildDynamicCAPM,
    lower = c(0.001, 0, 0),
    hessian = TRUE
)

"Get estimates"
mod <- buildDynamicCAPM(outMLE$par)
outSmooth <- dlmSmooth(y, mod)

alphaplot <- dropFirst(outSmooth$s[,1])
betaplot <- dropFirst(outSmooth$s[,2])

alpha_stdev <- c(1:length(dates))
beta_stdev <- c(1:length(dates))

"Covariance matrix of coefficients is 2x2"
"I only want variance of alpha and beta which are the"
"1st and 4th elements of the matrix"
g <- dlmSvd2var(outSmooth$U.S, outSmooth$D.S)

for(i in c(1:length(dates))){
    full = unlist(g[i])
    alpha_stdev[i] <- full[1]
    beta_stdev[i] <- full[4]
}

alpha_stdev <- dropFirst(alpha_stdev)
alpha_stdev <- sqrt(alpha_stdev)

beta_stdev <- dropFirst(beta_stdev)
beta_stdev <- sqrt(beta_stdev)

"Build confidence interval"
Z <- qnorm(1-signif/2)
"""

## ----------------------
# rget and plot
@rget alphaplot
@rget alpha_stdev
@rget betaplot
@rget beta_stdev
@rget Z

df2 = DataFrame(
    Dates = dates[2:end],

    Alpha = alphaplot,
    Alpha_stdev = alpha_stdev,
    Alpha_ymin = alphaplot - Z*alpha_stdev,
    Alpha_ymax = alphaplot + Z*alpha_stdev,

    Beta = betaplot,
    Beta_stdev = beta_stdev,
    Beta_ymin = betaplot - Z*beta_stdev,
    Beta_ymax = betaplot + Z*beta_stdev
)

p1 = Gadfly.plot(
    # Data frame
    df2,
    # Variables
    x = df2[!, :Dates], y = df2[!, :Alpha], Geom.line,
    # Ribbon
    ymin = df2[!, :Alpha_ymin], ymax = df2[!, :Alpha_ymax], Geom.ribbon,
    # Axes and title
    Guide.xlabel(nothing),
    Guide.ylabel("Confidence interval at $signif"),
    Guide.title("Dynamic α of $stock_name on $benchmark_name from Kalman Smoother"),
    # yintercept
    yintercept = [0], Geom.hline(style=:dash),
    # Set min and max coordinates -- Need Coord.cartesian to force them
    Coord.cartesian(
        xmin = minimum(df2[!, :Dates]),
        xmax = maximum(df2[!, :Dates])
    ),
    # Theme
    Theme(background_color = "white")
)

p2 = Gadfly.plot(
    # Data frame
    df2,
    # Variables
    x = df2[!, :Dates], y = df2[!, :Beta], Geom.line,
    # Ribbon
    ymin = df2[!, :Beta_ymin], ymax = df2[!, :Beta_ymax], Geom.ribbon,
    # Axes and title
    Guide.xlabel(nothing),
    Guide.ylabel("Confidence interval at $signif"),
    Guide.title("Dynamic β of $stock_name on $benchmark_name from Kalman Smoother"),
    # yintercept
    yintercept = [0, 1], Geom.hline(style=:dash),
    # Set min and max coordinates -- Need Coord.cartesian to force them
    Coord.cartesian(
        xmin = minimum(df2[!, :Dates]),
        xmax = maximum(df2[!, :Dates])
    ),
    # Theme
    Theme(background_color = "white")
)

f = Gadfly.vstack(p1, p2)
f
