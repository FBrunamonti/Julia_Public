## -----------------------------------
# Import
using MarketData

using DataFrames

using ARCHModels

using RCall

## ----------------------------------
# Define
function getdata(ticker)
    data = yahoo(ticker)
    array = data[:AdjClose]
    TimeSeries.rename!(array, Symbol(ticker))
    # Remove missing
    array = TimeArray(dropmissing(DataFrame(array)), timestamp=:timestamp)
end

function makedf(tickers)
    prices = getdata(tickers[1])

    for i in 2:length(tickers)
        s = getdata(tickers[i])
        prices = merge(prices, s)
    end

    return prices
end

## ----------------------------------
# Parameters
tickers = ["^GSPC" "GC=F" "FTSEMIB.MI" "SI=F" "K" "VBMFX" "KO"]
longnames = ["S&P500" "Gold" "FTSE MIB" "Silver" "US Steel" "Vanguard Bond Fund" "Coca Cola"]

## ----------------------------------
# Get data
prices = makedf(tickers)

#Clean data
returns = percentchange(prices, :log)
dates = TimeSeries.timestamp(returns)
l = length(dates)
n = length(tickers)

# Initialize dataframe
df = DataFrame(Float64, l, n^2)

# ----------------------------------
# Calculate
multiv = ARCHModels.fit(
    DCC{1, 1, TGARCH{1, 1, 1}}, # <- Avoid EGARCH for convergence error
    values(returns),
    dist = MultivariateStdNormal,
    meanspec = Intercept
)

dcor = ARCHModels.correlations(multiv)

# Fill dataframe
for i in 1:l
    df[i,:] = vec(dcor[i])'
end
df = round.(df, digits = 3)

# Change dataframe column names to pairs
dfnames = []
for i in 1:n, j in 1:n
    longname = "$(longnames[i])-$(longnames[j])"
    push!(dfnames, longname)
end

DataFrames.rename!(df, Symbol.(dfnames))

## -------------------------
# Plot
@rput dates
@rput df
@rput dfnames
@rput l
@rput n

R"""
library(gridExtra)

library(ggplot2)
theme_set(theme_bw())

# ----------------------------------------------
# Make list
rownames(df) <- dates

plist <- list()

# Loop
for(i in c(1:n^2)){
    df_loop <- data.frame(df[i])
    rownames(df_loop) <- dates
    colnames(df_loop) <- "variable"

    plist[[i]] <- ggplot(data = df_loop, aes(x = dates, y = variable)) +
        geom_line() +
        ylim(-1, 1) +
        labs(x = NULL, y = NULL, title = dfnames[i]) +
        geom_hline(yintercept = c(-1:1), linetype = 'dashed')

    gc()
}

# ----------------------------------------------
# Plot
do.call("grid.arrange", c(plist, ncol = n, nrow = n))
""" 
