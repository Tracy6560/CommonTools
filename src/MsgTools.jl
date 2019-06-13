module MsgTools

function print_message(fileName::String, message::String)

    fid = open(fileName, "a+");

    try
        write(fid, string(message, "\n"))
        close(fid)
    catch Exception
        @warn string("RMI:print_message", string("Error in print_message: ", Exception))
    end

end

function disp_print_message(fileName::String, message::String)

    display(message)
    display(" ")
    print_message(fileName, message)

end

end