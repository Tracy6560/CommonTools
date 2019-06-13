module DateTools

using Dates




function converDate(date)
    #convert num date to date format eg.20180630->2018-06-30
    startDateY=floor(Int,date/10000);
    md=mod(date,10000);
    startDateM=floor(Int,md/100);
    startDateD=mod(md,100);
    startDate=Date(startDateY,startDateM,Int(startDateD));
    return startDate
end

"""
add_time(oldDay::Any,day::Any,format::String)

add/minus day/month/year to the array of dates by an array of days

# Examples:
```julia-repl
julia> add_time([20190114, 20181223, 20181211], -1, "month")

3-element Array{Int64,1}:
 20181214
 20181123
 20181111


julia> add_time([20190114, 20181223, 20181211], 1, "month")

3-element Array{Int64,1}:
 20190214
 20190123
 20190111
```
Note: Datatype loosely defined. It is not corrected because function is called with multiple datatypes of inputs
"""
function add_time(oldDay::Any,day::Any,format::String)
    # oldDay is an integer array of the format yyyymmdd.
    # day is the number of days, months or years to add [minus if negative].

    # Author: Zhang Zhifeng [ZF]
    # Created Time: 2016-01-31
    # Last modified: 2016-05-13 by ZF

    if isempty(format)
        format = "day"
    end

    idx = nothing
    if length(oldDay) == 1
        idx = isfinite(oldDay) ? 1 : nothing
    else
        idx = LinearIndices(oldDay)[isfinite.(oldDay)]
    end

    oldDayFinite = oldDay[idx]
    if length(day)>1
        dayChangeFinite = day[idx]
    else
        dayChangeFinite = day
    end

    newDay = fill!(Array{Float64}(undef, size(oldDay)),NaN)


    if format=="day"
        dateNum = Date.(floor.(oldDayFinite ./ 10000),floor.(oldDayFinite ./100) .% 100,oldDayFinite .% 100)
        dateNum = dateNum + Dates.Day.(dayChangeFinite)
        newDayFinite = Dates.year.(dateNum)*10000+Dates.month.(dateNum)*100+Dates.day.(dateNum)
    elseif format=="month"
        yyyy = floor.(oldDayFinite/10000)
        mm = floor.(oldDayFinite/100).%100
        mm = (x -> x == 0 ? 12 : x).(mm)
        dd = oldDayFinite.%100
        isLastDay = dd .== Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm)))
        mm = mm .+ dayChangeFinite
        yyyy = yyyy .+ floor.(Int, (mm .-1)/12)
        mm = (mm.-1) .%(12) .+1
        mm = (x -> x == 0 ? 12 : x).(mm)
        dd = min(dd,Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm))))
        newDayFinite = 10000*yyyy +
            100*mm +
            dd.*Int.(.!isLastDay)+Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm))).*Int.(isLastDay)
    elseif format=="year"
        yyyy = floor.(oldDayFinite/10000)
        mm = floor.(oldDayFinite/100) .% 100
        dd = oldDayFinite .% 100
        isLastDay = dd.==Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm)))
        yyyy = yyyy .+ dayChangeFinite
        dd = min(Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm))),dd)
        newDayFinite = 10000*yyyy +
            100*mm +
            dd.*Int.(.!isLastDay)+Dates.day.(Dates.lastdayofmonth.(Date.(yyyy,mm))).*Int.(isLastDay)
    else
        error("Please choose the format from day, month and year!")
    end
    newDay[idx] = newDayFinite

    return Int64.(newDay)
end

function convertBackdate(date)
    #conver date format to num date eg: 2018-06-30->20180630
    yyyy=Dates.year(date);
    mm=Dates.month(date);
    d=Dates.day(date);
    newdate=yyyy*10000+100*mm+d;
    return newdate
end

end
