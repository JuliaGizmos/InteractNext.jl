module InteractNext

using WebIO

include("setup.jl")
include("widgets.jl")
include("manipulate.jl")
include("observablesIO.jl")

function __init__()
    setup()
end

end
