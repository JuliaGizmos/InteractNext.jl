using Requires

# TODO change urls to be specific versions, not "master" etc
const jspaths = Dict(
    # "vue"=>"https://unpkg.com/vue",
    "vue"=>"https://gitcdn.xyz/repo/vuejs/vue/master/dist/vue.min.js",
    "vue-slider"=>"https://gitcdn.xyz/repo/NightCatSama/vue-slider-component/master/dist/index.js",
    "vue-material"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.js",
)

const widget_deps = [
    Dict("url"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.css", "type"=>"css"), # css deps only get loaded once - not for all widgets - see https://github.com/JuliaGizmos/WebIO.jl/blob/master/assets/basics/node.js#L206
    Dict("url"=>"vue", "type"=>"js"),
    Dict("url"=>"vue-slider", "type"=>"js"),
    Dict("url"=>"vue-material", "type"=>"js")
]

@require PlotlyJS begin
    PlotlyJS.js_default[] = :embed
    println("InteractNext: PlotlyJS enabled")
end

systemjs_config = Dict(
    "paths"=>jspaths
)

function setup()
    WebIO.setup()
    Base.invokelatest(WebIO.register_renderable, Manipulate)
end
