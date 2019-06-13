"""
Tools for MAT files read and write
"""
module MatTools

using MAT

function cri_read_mat(readpath::String, variablename::String)
	@assert(readpath[end-3 : end] == ".mat");
    data = matopen(readpath) do file_io
        read(file_io, variablename)
    end
    return data
end

function cri_read_mat(readpath::String)
	@assert(readpath[end-3 : end] == ".mat");
    data = matopen(readpath) do file_io
        read(file_io)
    end
    return data
end

function cri_write_mat(writepath::String, variablename::String, variable)
    @assert(writepath[end-3 : end] == ".mat");
    matopen(writepath, "w") do file_io
        write(file_io, variablename, variable)
    end
end

end