export slider, vslider, button, checkbox, textbox

using DataStructures, JSON

include("widget_utils.jl")
include("options_widgets.jl")
include("output_widgets.jl")

"""
```
function slider(vals; # Range or Vector or Associative
                value=medianelement(range),
                ob::Observable=Observable(value),
                label="", kwargs...)
```

Creates a slider widget which can take on the values in `vals`, and updates
observable `ob` when the slider is changed:
```
# slider from Range
s1 = slider(1:10; label="slide on", value="7")
slider_obs = obs(s1)

# slider from Array
lyrics = ["When","I","wake","up","yes","I ","know","I'm","gonna","be"]
s2 = slider(lyrics; label="Proclaim", value="7")
slider_obs = obs(s2)

# slider from Associative
# The slider will have keys(d) for its labels, while obs(s3) will hold d[selected]

using DataStructures
lyrics = ["When","I","wake","up","yes","I ","know","I'm","gonna","be"]
d = OrderedDict(zip(lyrics, 1:length(lyrics))
s3 = slider(d); label="No true Scotsman", value="7")
slider_obs = obs(s3)
```

Slider uses the Vue Slider Component from https://github.com/NightCatSama/vue-slider-component
you can pass any properties you wish to set using kwargs, e.g.
To make a vertical slider you can use
```
s = slider(1:10; label="level", value="3", direction="vertical")
```
N.b. there is also a shorthand for that particular case - `vslider`

If the propname is supposed to be kebab-cased (has a `-` in it), write it as
camelCased. e.g. to set the `piecewise-label` property to `true`, use
```
s = slider(1:10; piecewiseLabel=true)
```

"""
function slider{T}(vals::Union{Range{T}, Vector{T}, Associative{<:Any, T}};
                value=nothing,
                ob=nothing,
                label="", kwargs...)
    ob = Observable{T}(medianelement(vals))

    kwdata = Dict{Propkey, Any}(kwargs)

    # add the label to the component's data
    kwdata[:label] = label

    extra_vbinds = Dict()

    if vals isa Range
        for (key, value) in
        ((:min, first(vals)), (:max, last(vals)), (:interval, step(vals)))
            # set the data to be added to the Vue instance with the same key
            kwdata[key] = value
        end
    else
        # Vector or Associative
        if vals isa Vector
            vlabels = eltype(vals) <: AbstractFloat ?
                map(x->round(x, 2)|>string, vals) : string.(vals)
            vals = OrderedDict(zip(vlabels, vals))
        end

        # selection slider labels are the keys
        kwdata[:formatter] = @js function(v)
            if (v % 1 === 0) v = v + ".0" end # js removes decimal points on Ints
            $(inverse_dict(vals))[v]
        end
        # selection slider vals are the values
        svals = values(vals) |> collect
        kwdata[:piecewise] = true
        length(svals) < 10 && (kwdata[:piecewiseLabel] = true)
        # using WebIO.jsexpr here allows the slider to potentially have
        # functions as values, which could be interesting.
        extra_vbinds["data"] = "vals"=>WebIO.jsexpr(svals)
    end

    isvert = get(kwdata, :direction, "horizontal") == "vertical"
    extra_styles = if isvert
        kwdata[:dotSize] = 12
        Dict("width"=>"12px", :height=>"300px", Symbol("margin-left")=>"50px",
        :padding=>"0.1px")
    else
        Dict(:width=>"60%", Symbol("margin-top")=>"40px", :padding=>"2px")
    end

    labelwdg = if get(kwdata, :piecewiseLabel, false)
        extra_styles[Symbol("margin-bottom")] = "25px"
        wdglabel(label; padt=32, style=Dict(Symbol("vertical-align")=>"top"))
    else
        wdglabel(label)
    end

    vbindprops, data = kwargs2vueprops(kwdata; extra_vbinds=extra_vbinds)

    prop_str = props2str(vbindprops, Dict("ref"=>"slider", "v-model"=>"value"))

    template = dom"div"(
        labelwdg,
        dom"vue-slider[$prop_str]"(
            style=merge(Dict(:display=>"inline-block"), extra_styles)
        )
    )
    data["value"] = ob
    s = vue(template, data)
    import!(s, "https://nightcatsama.github.io/" *
               "vue-slider-component/dist/index.js")

    onimport(s, @js function (Vue, vueSlider)
            Vue.component("vue-slider", vueSlider)

    end)

    on(identity, s["value"])
    s
end

"""
`vslider(data; kwargs...)`

Same as `slider` just with direction set to "vertical"
"""
vslider(data; kwargs...) = slider(data; direction="vertical", kwargs...)

"""
button(text=""; ob::Observable = Observable(0))

Note the button text supports a special `clicks` variable, e.g.:
`button("clicked {{clicks}} times")`
"""
function button(text=""; ob::Observable = Observable(0), label="")
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>"md-raised md-primary")
    template = dom"div"(
        wdglabel(label),
        dom"md-button"(text, attributes=attrdict)
    )
    button = vue(template, ["clicks" => ob]; obskey=:clicks)
    import!(button, "https://gitcdn.xyz/cdn/JobJob/" *
                    "vue-material/js-dist/dist/vue-material.js")
    import!(button, "https://gitcdn.xyz/cdn/JobJob/" *
                    "vue-material/css-dist/dist/vue-material.css")
    on(identity, button["clicks"])
    onimport(button, @js function (Vue, VueMaterial)
        Vue.use(VueMaterial)
    end)
    button
end

"""
```
checkbox(checked=false;
         label="",
         ob::Observable = Observable(checked))
```

e.g. `checkbox("be my friend?", checked=false)`
"""
function checkbox(checked=nothing;
                  label="",
                  ob=nothing)
    ob, value = init_wsigval(ob, checked; default=false)
    attrdict = Dict("v-model"=>"checked", "class"=>"md-primary")
    template = Node(Symbol("md-checkbox"), attributes=attrdict)(label)
    checkbox = make_widget(template, ob; obskey=:checked)
end

"""
```
textbox(label="";
        ob::Observable = Observable(""))
```

Create a text input area with an optional `label`

e.g. `textbox("enter number:")`
"""
function textbox(label=""; ob::Observable = Observable(""), placeholder="")
    template = dom"md-input-container"(
                 dom"label"(label),
                 dom"""md-input[v-model=text, placeholder=$placeholder]"""(),
               )
    textbox = make_widget(template, ob; obskey=:text)
end

function wdglabel(text; padt=5, padr=10, padb=0, padl=0, style=Dict())
    fullstyle = Dict(:padding=>"$(padt)px $(padr)px $(padb)px $(padl)px")
    merge!(fullstyle, style)
    dom"label[class=md-subheading]"(text;
        style=fullstyle
    )
end
