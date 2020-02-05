function removeFilesMaching(pathern::Regex, path::String)
    f = readdir(path)
    idx = findall(x->occursin(pathern,x), f)
    files = f[idx]
    for x in files
        rm(x)
    end
    if length(files)>0
        println("removed ", files[1],"...",files[end] )
    end
end
