##
# Useful documentation
# http://pages.stern.nyu.edu/~pschnabl/research/callreport_1976_2020_WRDS.sas
# http://pages.stern.nyu.edu/~pschnabl/research/sas_callreport_code.sas

##
# Packages
using CSV, DataFrames
using Dates
using RCall

##
# Functions
function readcsv(address)
    df = CSV.read(address, DataFrame)
    return df
end

function parseint(number)
    parsed = parse(Int64, number)
    return parsed
end

function parsedate(vector)
    v = Date.(string.(vector), dateformat"yyyymmdd")
    return v
end

function removemissings(df)
    df = df[completecases(df), :]
    return df
end

##
# Gather data
HHI = readcsv("C:\\Users\\Francesco\\Desktop\\l1_herfdepcty.csv")
df = readcsv("C:\\Users\\Francesco\\Desktop\\callreports_1976_2020_WRDS.csv")

## BEGINNING OF PROBLEM SET
## Exercise B
# Clean data to facilitate matching
HHI = removemissings(HHI)
HHI.Year = first.(HHI.dateq, 4)
HHI.Year = parseint.(HHI.Year)
HHI.Quarter = last.(HHI.dateq, 1)
HHI.Quarter = parseint.(HHI.Quarter)
unique!(HHI, [:cert, :dateq]) # Keeps the first of any cert-dateq pair duplicate if present
select!(HHI, Not(:dateq)) # To avoid name overlaps when merging

rename!(df, :year => :Year, :quarter => :Quarter)
unique!(df, [:date, :name]) # Keeps the first of any date-name pair duplicate if present

# Match data sets
df = innerjoin(df, HHI, on = [:cert, :Year, :Quarter])

# Restrict to commercial banks
filter!(:chartertype => isequal(200), df)

# restrict to observations in 1994-2013
filter!(:Year => ∈(1994:2013), df)

## EXERCISE C
# Import Fed Funds
ff = readcsv("C:\\Users\\Francesco\\Desktop\\ff.csv")
ff.Quarter = [Quarter.(i).value for i in ff.DATE]
ff.Year = [Year.(i).value for i in ff.DATE]

#=
FRED has weekly data for Fed Funds, but for each quarter I only want
to keep the last observation. I do so by assigning a quarter and year to each
observation, and using an indicator to select the last date of each quarter.
I can then directly match the remaining values.
=#
ff.dummy = 0
ff.dummy = [[ff.Quarter[i] != ff.Quarter[i+1] for i ∈ 1:(size(ff)[1]-1)]; 0]
filter!(:dummy => isequal(1), ff)
select!(ff, Not([:DATE, :dummy]))

df = innerjoin(df, ff, on = [:Quarter, :Year])

# Only keep useful variables
select!(df, ([:name, :date, :l1_herfdepcty, :deposits, :intexpdomdep, :totsavdep, :timedep, :timedepuninsured, :liabilities, :assets, :cash, :securities, :loans, :reloans, :ciloans, :FF]))
df.timedep = df.timedep + df.timedepuninsured
select!(df, Not(:timedepuninsured))
rename!(df, ([:Name, :Date, :HHI, :Deposits, :InterestExpense, :SavingsDeposits, :TimeDeposits, :Liabilities, :Assets, :Cash, :Securities, :Loans, :RELoans, :CILoans, :FF]))
df = removemissings(df)

df.Date = parsedate(df.Date)
df.quarter = Dates.quarter.(df.Date)

# For Robustness Check 2
top10 = quantile(df.Assets, 0.90)
top25 = quantile(df.Assets, 0.75)

#filter!(row -> row.Assets > top25, df)

## EXERCISE D - REGRESSIONS

@rput df
R"""
# ------------------------------------------
# Libraries
library(lfe)
library(plm)
library(stargazer)
library(dplyr)
library(collapse)

# ------------------------------------------
# Clean data
pdf <- pdata.frame(df, index = c("Name", "Date"), drop.index = TRUE)
pdf <- fdiff(pdf, log = TRUE)

df2 <- cbind(index(pdf), as.data.frame(pdf)) %>% filter_if(~is.numeric(.), all_vars(!is.infinite(.)))
df2 <- na.omit(df2)
df2 <- select(df2, -c("HHI", "quarter"))
df2$Date <- as.Date(df2$Date)

df <- left_join(df, df2, by = c("Name", "Date"), keep = FALSE)
df <- na.omit(df)
df <- select(df,
             c("Name", "Date", "HHI", "quarter", "Deposits.y", "InterestExpense.y", "SavingsDeposits.y", "TimeDeposits.y",
               "Liabilities.y", "Assets.y", "Cash.y", "Securities.y", "Loans.y", "RELoans.y", "CILoans.y", "FF.y"
              )
)
names(df) <- c(
    "Name", "Date", "HHI", "Quarter", "Deposits", "InterestExpense", "SavingsDeposits", "TimeDeposits", "Liabilities",
    "Assets", "Cash", "Securities", "Loans", "RELoans", "CILoans", "FF"
)

df$y <- df$HHI * df$FF
df$Wholesale <- df$Liabilities - df$Deposits
df$DepositSpread <- df$FF - df$InterestExpense

# ------------------------------------------
# Panel regression
rl1 <- felm(y ~ Deposits | Name + Quarter | 0 | Name, data = df)
rl2 <- felm(y ~ DepositSpread | Name + Quarter | 0 | Name, data = df)
rl3 <- felm(y ~ SavingsDeposits | Name + Quarter | 0 | Name, data = df)
rl4 <- felm(y ~ TimeDeposits | Name + Quarter | 0 | Name, data = df)
rl5 <- felm(y ~ Wholesale | Name + Quarter | 0 | Name, data = df)
rl6 <- felm(y ~ Liabilities | Name + Quarter | 0 | Name, data = df)

stargazer(
    rl1, rl2, rl3, rl4, rl5, rl6,
    type = "latex",
    table.placement = "H",
    title = "Liabilities",
    font.size = "scriptsize",
    notes = ""
)

ra1 <- felm(y ~ Assets | Name + Quarter | 0 | Name, data = df)
ra2 <- felm(y ~ Cash | Name + Quarter | 0 | Name, data = df)
ra3 <- felm(y ~ Securities | Name + Quarter | 0 | Name, data = df)
ra4 <- felm(y ~ Loans | Name + Quarter | 0 | Name, data = df)
ra5 <- felm(y ~ RELoans | Name + Quarter | 0 | Name, data = df)
ra6 <- felm(y ~ CILoans | Name + Quarter | 0 | Name, data = df)

stargazer(
    ra1, ra2, ra3, ra4, ra5, ra6,
    type = "latex",
    table.placement = "H",
    title = "Assets",
    font.size = "scriptsize"
)
"""
