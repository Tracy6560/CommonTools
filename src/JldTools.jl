"""
Tools for JLD files read and write
"""
module JldTools

using JLD, MAT

function cri_write_jld(writepath::String, variablename::String, variable)
    @assert(writepath[end-3 : end] == ".jld");
    jldopen(writepath, "w"; compress=true) do file
        write(file, variablename, variable);
    end
end

function cri_write_jld(writepath::String, variablename1::String, variable1, variablename2::String, variable2)
    @assert(writepath[end-3 : end] == ".jld");
    jldopen(writepath, "w"; compress=true) do file
        write(file, variablename1, variable1);
        write(file, variablename2, variable2);
    end
end

function cri_write_jld(writepath::String, variablename1::String, variable1, variablename2::String, variable2, variablename3::String, variable3)
    @assert(writepath[end-3 : end] == ".jld");
    jldopen(writepath, "w"; compress=true) do file
        write(file, variablename1, variable1);
        write(file, variablename2, variable2);
        write(file, variablename3, variable3);
    end
end

function cri_write_jld(writepath::String, variablename1::String, variable1, variablename2::String, variable2, variablename3::String, variable3, variablename4::String, variable4)
    @assert(writepath[end-3 : end] == ".jld");
    jldopen(writepath, "w"; compress=true) do file
        write(file, variablename1, variable1);
        write(file, variablename2, variable2);
        write(file, variablename3, variable3);
        write(file, variablename4, variable4);
    end
end

function cri_read_jld(readpath::String, variablename::String)
    @assert(readpath[end-3 : end] == ".jld");
    if isfile(readpath)
        data = jldopen(readpath, "r") do file
            read(file, variablename);
        end
    else
        readpath = replace(readpath, ".jld" => ".mat")
        data = matread(readpath)[variablename]
        @warn "Only found $readpath while .jld file is provided. Used matread instead."
    end
        
    return data;
end

function cri_read_jld(readpath::String)
    @assert(readpath[end-3 : end] == ".jld");
    if isfile(readpath)
    data = jldopen(readpath, "r") do file
        read(file);
    end
    else
        readpath = replace(readpath, ".jld" => ".mat")
        data = matread(readpath)
        @warn "Only found $readpath while .jld file is provided. Used matread instead."
    end
    return data;
end


end