module InteractNext

using WebIO

include("setup.jl")
include("package_support.jl")
include("widgets.jl")
include("manipulate.jl")
include("observablesIO.jl")

function __init__()
    webio_setup()
end

end
