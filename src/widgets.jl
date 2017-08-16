export obs, slider, button, checkbox, textbox, make_widget

using DataStructures

include("widget_utils.jl")
include("options_widgets.jl")

"""
```
function slider(range::Range;
                value=medianelement(range),
                ob::Observable=Observable(value),
                label="", kwargs...)
```

Creates a slider widget which updates observable `ob` when the slider is changed:
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
                ob=nothing,
                label="", kwargs...)
    ob, value = init_wsigval(ob, value; typ=T, default=medianelement(range))
    push!(kwargs, (:min, first(range)), (:max, last(range)), (:interval, step(range)))
    push!(kwargs, (:ref, "slider"), ("v-model", "value"), (:style, "margin-top:30px"))
    attrdict = Dict(kwargs)
    haskey(attrdict, :value) && (ob[] = attrdict[:value]) # set the ob to the initial value if provided
    template = Node(:div)(label, Node(Symbol("vue-slider"); attributes=attrdict))
    make_widget(template, ob)
end

"""
`vslider(range::Range; kwargs...)`

Same as `slider` just with orientation set to "vertical"
"""
vslider(range; kwargs...) = slider(range; orientation="vertical", kwargs...)

"""
button(label=""; ob::Observable = Observable(0))

Note the label supports a special `clicks` variable that can be used like so:
e.g. button(label="clicked {{clicks}} times")
"""
function button(label=""; ob::Observable = Observable(0))
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>"md-raised md-primary")
    template = Node(Symbol("md-button"), attributes=attrdict)(label)
    button = make_widget(template, clicks; obskey=:clicks)
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
