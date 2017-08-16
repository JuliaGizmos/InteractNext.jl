export obs, slider, button, togglebuttons, checkbox, textbox, make_widget

using DataStructures

include("widget_utils.jl")

"""
```
function slider(range::Range;
                value=medianelement(range),
                obs::Observable=Observable(value),
                label="", kwargs...)
```

Creates a slider widget which updates observable `obs` when the slider is changed:
```
s = slider(1:10; label="slide on", value="7")
slider_obs = obs(s)
```

Slider uses the Vue Slider Component from https://github.com/NightCatSama/vue-slider-component
you can pass any properties you wish to set as keyword arguments, e.g.
To make a vertical slider you can use
```
s = slider(1:10; label="level", value="3", orientation="vertical")
```

N.b. there is also a shorthand for that particular case - `vslider`
"""
function slider{T}(range::Range{T};
                value=nothing,
                obs=nothing,
                label="", kwargs...)
    obs, value = init_wsigval(obs, value; typ=T, default=medianelement(range))
    push!(kwargs, (:min, first(range)), (:max, last(range)), (:interval, step(range)))
    push!(kwargs, (:ref, "slider"), ("v-model", "value"), (:style, "margin-top:30px"))
    attrdict = Dict(kwargs)
    haskey(attrdict, :value) && (obs[] = attrdict[:value]) # set the obs to the initial value if provided
    template = Node(:div)(label, Node(Symbol("vue-slider"); attributes=attrdict))
    make_widget(template, obs)
end

"""
`vslider(range::Range; kwargs...)`

Same as `slider` just with orientation set to "vertical"
"""
vslider(range; kwargs...) = slider(range; orientation="vertical", kwargs...)

"""
button(label=""; obs::Observable = Observable(0))

Note the label supports a special `clicks` variable that can be used like so:
e.g. button(label="clicked {{clicks}} times")
"""
function button(label=""; obs::Observable = Observable(0))
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>"md-raised md-primary")
    template = Node(Symbol("md-button"), attributes=attrdict)(label)
    button = make_widget(template, clicks; obskey=:clicks)
end

"""
togglebuttons(labels_values::Associative;
              value = first(values(labels_values)),
              obs::Observable = Observable(value))

e.g. togglebuttons(Dict("good"=>1, "better"=>2, "amazing"=>9001))
"""
function togglebuttons(labels_values::Associative;
        obs::Observable = nothing,
        value = nothing,
        multiselect=false)
    default = multiselect ? [] : first(values(labels_values))
    obs, value = init_wsigval(obs, value; default=default)
    btns =
        [Node(Symbol("md-button"),
            attributes=Dict("value"=>string(value), "id"=>i, "v-on:click"=>
                    multiselect ? "selected.push($value)" : "selected=$value")
        )(label)
            for (i,(label, value)) in enumerate(labels_values)]
    attrdict = Dict{String, Any}()
    !multiselect && (attrdict["md-single"] = true)
    template = Node(Symbol("md-button-toggle"); attributes=attrdict)(btns...)
    toglbtns = InteractNext.make_widget(template, obs; obskey=:selected)
end

togglebuttons(vals::AbstractArray,
              selected::Observable = Observable{Any}(first(vals))) =
    togglebuttons(OrderedDict(zip(string.(vals), vals)), selected)

"""
```
checkbox(checked=false;
         label="",
         obs::Observable = Observable(checked))
```

e.g. `checkbox("be my friend?", checked=false)`
"""
function checkbox(checked=nothing;
                  label="",
                  obs=nothing)
    obs, value = init_wsigval(obs, checked; default=false)
    attrdict = Dict("v-model"=>"checked", "class"=>"md-primary")
    template = Node(Symbol("md-checkbox"), attributes=attrdict)(label)
    checkbox = make_widget(template, obs; obskey=:checked)
end

"""
```
textbox(label="";
        obs::Observable = Observable(""))
```

Create a text input area with an optional `label`

e.g. `textbox("enter number:")`
"""
function textbox(label=""; obs::Observable = Observable(""), placeholder="")
    template = dom"md-input-container"(
                 dom"label"(label),
                 dom"""md-input[v-model=text, placeholder=$placeholder]"""(),
               )
    textbox = make_widget(template, obs; obskey=:text)
end
