module PathTools

function conditional_mkdir(PathNames,removeFirst)
    # make directory and remove if exist
    keyPathNames = keys(PathNames);

    for direcotry in keyPathNames
        if isdir(PathNames[direcotry])
            if removeFirst==1
                success = 0;
                while success == 0
                    try
                        rm(PathNames[direcotry];recursive=true)
                        success = 1;
                    catch
                        error("removing the folder...please close all the opened folders (window explorer)")
                    end
                end
            end
        end
        success = 0
        while success == 0
            try
                mkpath(PathNames[direcotry])
                success = 1;
            catch
                error("creating the folder...please close all the opened folders (window explorer), after that hit enter to continue")
            end
        end
    end
end

end
