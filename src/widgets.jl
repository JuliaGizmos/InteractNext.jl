export obs, slider, button

function vue(template, data=[], run_ondeps=(@js ""); kwargs...)
    id = WebIO.newid("vue-instance")

    wrapper = Widget(id,
        # The urls for these deps are defined in setup.jl
        dependencies=[
            Dict("url"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/master/dist/vue-material.css", "type"=>"css"), # only gets loaded once - not for all widgets - see https://github.com/JuliaGizmos/WebIO.jl/blob/master/assets/basics/node.js#L206
            Dict("url"=>"vue", "type"=>"js"),
            Dict("url"=>"vue-slider", "type"=>"js"),
            Dict("url"=>"vue-material", "type"=>"js"),
        ]
    )

    init = Dict()
    watches = Dict()

    for (k, v) in data
        skey = string(k)
        if isa(v, Observable)
            setobservable!(wrapper, skey, v)

            # forward updates from Julia to the Vue property
            # onjs(v, @js (val) -> (debugger; this.vue[$skey] = val))
            onjs(v, @js (val) -> (this.vue[$skey] = val))

            # forward vue updates back to WebIO observable
            # which might send it to Julia
            watches[skey] = @js this.vue["\$watch"]($skey, function (newval, oldval)
                    # debugger
                    $v[] = newval
                end)
            init[skey] = v[]
        else
            init[skey] = v
        end
    end

    options = merge(Dict("el"=>"#$id", "data"=>init), Dict(kwargs))

    ondependencies(wrapper, @js function (Vue, VueSlider, VueMaterial)
        Vue.component("vue-slider", VueSlider)
        Vue.use(VueMaterial)
        this.vue = @new Vue($options)
        $(values(watches)...)
        $run_ondeps
    end)

    wrapper(dom"div"(template, id=id)) # FIXME why can't I set the ID on the class?
end

function slider(range, obs::Observable=Observable(medianelement(range));
        label="", kwargs...)
    push!(kwargs, (:min, first(range)), (:max, last(range)), (:interval, step(range)))
    push!(kwargs, (:ref, "slider"), ("v-model", "value"), (:style, "margin-top:30px"))
    kwdict = Dict(kwargs)
    haskey(kwdict, :value) && (obs[] = kwdict[:value])
    template = Node(:div)(label, Node(Symbol("vue-slider"), attributes=kwdict))
    make_widget(template, obs)
end

# differs from median(r) in that it always returns an element of the range
medianidx(r) = (1+length(r))>>1
medianelement(r::Range) = r[medianidx(r)]

"""
button(label="", clicks::Observable = Observable(0))

e.g. button(label="clicked {{clicks}} times")
"""
function button(label="", clicks::Observable = Observable(0))
    kwdict = Dict("v-on:click"=>"clicks += 1")
    template = Node(Symbol("md-button"), attributes=kwdict)(label)
    button = InteractNext.make_widget(template, clicks; obskey=:clicks)
end

# store mapping from widgets to observables
widgobs = Dict{Any, Observable}()
# users access a widget's Observable via this function
obs(widget) = widgobs[widget]

function make_widget(template, obs::Observable; obskey=:value)
    on(identity, obs) # ensures updates propagate back to julia
    widget = vue(template, [obskey=>obs])
    widgobs[widget] = obs
    widget
end

kwargstr(; kwargs...) = join(map(kw->string(kw[1],"=",kw[2]),kwargs), ",")
