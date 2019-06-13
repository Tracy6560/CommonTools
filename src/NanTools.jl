module NanTools

using Statistics

function nanmean(x)
    # Get mean and treat NaN as missing value
    result=mean(filter(.!isnan,x));
    return result
end

function nanmedian(A)
    # Get median and treat NaN as missing value
    cleanA = filter(.!isnan,A);
    if isempty(cleanA)
        return NaN
    else
        return median(cleanA)
    end

end

end
