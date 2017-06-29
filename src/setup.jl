systemjs_config = Dict(
    "paths"=>Dict(
        # "vue"=>"https://unpkg.com/vue",
        "vue"=>"https://gitcdn.xyz/repo/vuejs/vue/master/dist/vue.js",
        "vue-slider"=>"https://gitcdn.xyz/repo/NightCatSama/vue-slider-component/master/dist/index.js",
        "vue-material"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.js",
        # "roboto-fonts"=>"https://fonts.googleapis.com/css?family=Roboto:300,400,500,700|Material+Icons",
        # "material-icons"=>"https://fonts.googleapis.com/icon?family=Material+Icons"
    )
)

function setup()
    WebIO.setup()
    # TODO change urls to be specific versions, not "master" etc
    display(
        dom"script"(WebIO.jsstring(@js begin
            SystemJS.config($systemjs_config)
        end))
    )
end
