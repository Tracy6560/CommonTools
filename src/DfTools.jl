"""
some tools for processing DataFrames
"""
module DfTools
using Statistics
using DataFrames
using Dates
using BusinessDays

nanStr = ["N/A", "NA", "NaN", "nan"]




"""
    convert the companyID (first column) in the dataframe to integer
    cnovert the date (second column) to Date
"""
function to_date!(df::DataFrame, dateCol::Int = 2, format::String = "yyyymmdd")
    # if typeof(df[1]) == Array{Float64, 1}
    #     df[1] = Int.(df[1])
    # end

    if typeof(df[dateCol]) != Array{Date, 1}
        if typeof(df[dateCol][1]) != String
            if typeof(df[dateCol]) !=Array{Int64, 1}
                df[dateCol] = ismissing(df[dateCol]) ? missing : Int.(df[dateCol])
            end
            df[dateCol] = string.(df[dateCol])
        end

        df[dateCol] = Date.(df[dateCol], format)
    end
    return df
end

function to_int!(df::DataFrame, col::Int= 1)
    if typeof(df[col]) == Array{Float64, 1} ||typeof(df[col]) == Array{Union{Missing, Float64}, 1}
        df[col] = ismissing(df[col]) ? missing : Int.(df[col])
    end

    if typeof(df[col]) == Array{String, 1} ||typeof(df[col]) == Array{Union{Missing, String}, 1}
        df[col] = map(x -> ismissing(x) ? missing : parse(Int, x), df[col])
    end
    return df
end


"""
    confine the input dataframe to the time interval defined by startDate and endDate
    confine_DF!(df::DataFrame, startDate::Date, endDate::Date, dateCol::Int = 2)
"""
function confine_DF!(df::DataFrame, startDate::Date, endDate::Date, dateCol::Int = 2)
    df = df[(df[:, dateCol] .>= startDate) .& (df[:, dateCol] .<= endDate), :]
    return df
end


"""
    filter the DataFrame so that it contains only data of one company
"""
function filter_DF_by_company!(df::DataFrame, companyID::Int64)
    df = df[(df[:,1] .== companyID*1000), :]
    df = sort!(df, :date)
    return df
end


"""
Converts all entries that is meant to be NaN to missing
"""
function to_missing!(df::DataFrame)
    allowmissing!(df)

    (Nr, Nc) = size(df)
    for c = 1:Nc
        df[c] = map(x->contain_NaN(x) ? missing : x, df[c])
    end
end

"""
Converts all entries that is meant to be Float64 to Float64
"""
function to_float!(df::DataFrame, col::Int = 1)
    df[col] = Array{Union{Missing, String, Float64}, 1}(df[col])

    (Nr, Nc) = size(df)
    for r = 1:Nr
        if !ismissing(df[r, col]) && typeof(df[r, col]) !=Float64
            df[r,col] = parse(Float64, df[r,col])
        end
    end
    df[col] = Array{Union{Missing, Float64}, 1}(df[col])

    return df

end


"""
check if the element is NaN or meant to be NaN
e.g. N/A,#N/A N/A
"""
function contain_NaN(s::Any)
    res = false
    if typeof(s) == String
        for str in nanStr
            if occursin(str, s)
                res = true
            end
        end
    elseif typeof(s) == Float64
        if isnan(s)
            res = true
        end
    end

    return res
end

"""
    remove entries with maturity < 30 days
"""
function filter_by_maturity!(df::DataFrame, limit::Int=30)
    rows = Vector(1:size(df,1))
    colNames = string.(names(df))
    cols = findall(x -> occursin("Maturity", x), colNames)
    for c in cols
        for r in rows
            if !ismissing(df[r, c]) && df[r, c] <= limit
                if split(colNames[c], "_")[1] == split(colNames[c-1], "_")[1]
                    df[r, c]= missing
                    df[r, c-1] = missing
                else
                    error("Check $(split(colNames[c], "_")[1]) has G-Spread and Maturity side by side")
                end
            end
        end
    end

    return df
end

"""
    remove rows with all missing values
"""
function remove_all_missing!(df::DataFrame)
    rows_to_remove = []
    rows = Vector(1:size(df,1))
    colNames = string.(names(df))
    cols = findall(x -> occursin("Spread", x), colNames)
    @debug :cols cols
    for r in rows
        if all(ismissing.(df[r, cols]))
            push!(rows_to_remove, r)
        end
    end
    rows_to_keep = findall(x-> !(x in rows_to_remove), rows)
    df = df[rows_to_keep, :]
    return df
end

"""
convert Date to string
"""
function date_to_string(date::Date, format::String="yyyymmdd")
    yyyy = string(year(date))
    mm = string(month(date))
    dd = string(day(date))
    yyyy = string(repeat("0", 4 - length(yyyy)), yyyy)
    mm = string(repeat("0", 2 - length(mm)), mm)
    dd = string(repeat("0", 2 - length(dd)), dd)
    return string(yyyy, mm, dd)
end

"""
find the column symbol corresponding to date

`find_Date_col(df::DataFrame)`

"""
function find_Date_col(df::DataFrame)
    candidates = names(df)
    res = []
    for c in candidates
        if occursin("date", lowercase(string(c)))
            push!(res, c)
        end
    end

    if length(res) == 1
        return res[1]
    elseif length(res) > 1
        @warn "Multiple possible data columns found, using the first one."
        return res[1]
    else
        error("no data column found")
    end
    return res


end


"""
remove duplicates for date values in a dataframe. If two values
are present for one date, the non-Nan value will be preserved.

`remove_duplicates!(df::DataFrame) dateCol = find_Date_col(df)`
"""
function remove_duplicates_according_to_date(df::DataFrame)
    dateCol = find_Date_col(df)
    otherFields = filter(x->x != dateCol, names(df))
    duplicateRows = findall(nonunique(df, dateCol))
    duplicateDF = df[duplicateRows, :]

    referenceRows = findall(.!nonunique(df, dateCol))
    referenceDF = df[referenceRows, :]

    for field in otherFields
        for r = 1:size(duplicateDF, 1)
            if !isnan(duplicateDF[r, field]) && isnan(referenceDF[r, field])
                referenceDF[r, field] = duplicateDF[r, field]

            end
        end
    end

    return referenceDF
end


"""
generate a series of business day month ends from startDate to endDate

`generate_businessday_month_end(startDate::Date, endDate::Date)`
"""
function generate_businessday_month_end(startDate::Date, endDate::Date)
    raw_dates = collect(startDate:Month(1):endDate)
    raw_dates = lastdayofmonth.(raw_dates)
    raw_dates = tobday.("USSettlement", raw_dates, forward = false)
    return raw_dates
end



end
