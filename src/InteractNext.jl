module InteractNext

using WebIO

include("widgets.jl")
include("manipulate.jl")
include("observablesIO.jl")

function __init__()
    WebIO.setup()
end

end
