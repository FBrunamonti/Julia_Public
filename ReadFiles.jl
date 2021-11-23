##
using CSV, XLSX
using DataFrames
using StatFiles

##
function readxlsx(address, sheetname)
    df = DataFrame(XLSX.readtable(address, sheetname)...)
    return df
end

function readcsv(address)
    df = CSV.read(address, DataFrame)
    return df
end

function readdta(address)
    df = DataFrame(load(address))
    return df
end
