module InteractNext

using WebIO

include("widgets.jl")
include("manipulate.jl")

function __init__()
    WebIO.setup()
end

end
