systemjs_config = Dict(
    "paths"=>Dict(
        # "vue"=>"https://gitcdn.xyz/repo/vuejs/vue/master/dist/vue.js",
        "vue"=>"https://unpkg.com/vue",
        "vue-slider"=>"https://gitcdn.xyz/repo/NightCatSama/vue-slider-component/master/dist/index.js",
        "vue-material"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.js"
    )
)

function setup()
    WebIO.setup()
    # TODO change urls to be specific versions, not "master" etc
    display(dom"div"(
        dom"link"(;rel="stylesheet", href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Material+Icons"),
        dom"link"(;rel="stylesheet", href="https://fonts.googleapis.com/icon?family=Material+Icons"),
        dom"link"(;rel="stylesheet", href="https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.css"),
        # dom"link"(;rel="stylesheet", href="https://gitcdn.xyz/repo/vuetifyjs/vuetify/master/dist/vuetify.min.css"),
        # dom"script"(;src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.3/require.js"),
        # dom"script"(;src="https://gitcdn.xyz/repo/vuejs/vue/master/dist/vue.js"),
        dom"script"(WebIO.jsstring(@js begin
            SystemJS.config($systemjs_config)
        end))
    ))
end
