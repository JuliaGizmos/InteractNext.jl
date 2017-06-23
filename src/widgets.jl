export obs, slider

function vue(template, data=[]; kwargs...)
    id = WebIO.newid("vue-instance")

    wrapper = Widget(id,
        dependencies=[
            Dict("url"=>"https://unpkg.com/vue", "type"=>"js"),
            Dict("url"=>"https://gitcdn.xyz/repo/NightCatSama/vue-slider-component/master/dist/index.js", "type"=>"js"),
        ]
    )

    init = Dict()
    watches = Dict()

    for (k, v) in data
        skey = string(k)
        if isa(v, Observable)
            setobservable!(wrapper, skey, v)

            # forward updates from Julia to the Vue property
            onjs(v, @js (val) -> (debugger; this.vue[$skey] = val))

            # forward vue updates back to WebIO observable
            # which might send it to Julia
            watches[skey] = @js this.vue["\$watch"]($skey, function (newval, oldval)
                                            debugger
                                           $v[] = newval
                                       end)
            init[skey] = v[]
        else
            init[skey] = v
        end
    end

    options = merge(Dict("el"=>"#$id", "data"=>init), Dict(kwargs))

    ondependencies(wrapper, @js function (Vue, vueSlider)
            console.log(vueSlider)
            Vue.component("vue-slider", vueSlider)
            this.vue = @new Vue($options)
            $(values(watches)...)
          end)

    wrapper(dom"div"(template, id=id)) # FIXME why can't I set the ID on the class?
end

widgobs = Dict{Any, Observable}()
obs(widget) = widgobs[widget]

function slider(range, obs::Observable=Observable(medianelement(range));
        label="", kwargs...)
    on(identity, obs)
    push!(kwargs, (:min, first(range)), (:max, last(range)), (:interval, step(range)))
    push!(kwargs, (:ref, "slider"), ("v-model", "value"), (:style, "margin-top:30px"))
    kwdict = Dict(kwargs)
    haskey(kwdict, :value) && (obs[] = kwdict[:value])
    # template = @dom_str(string(label,"""vue-slider\[ref="slider",v-model=value,""",kwargstr(; kwargs...),"style=margin-top:30px\]"))()
    template = Node(:div)(label, Node(Symbol("vue-slider"), attributes=kwdict))
    make_widget(template, obs)
end

# differs from median(r) in that it always returns an element of the range
medianidx(r) = (1+length(r))>>1
medianelement(r::Range) = r[medianidx(r)]

function make_widget(template, obs::Observable; obskey=:value)
    widget = vue(template, [obskey=>obs])
    widgobs[widget] = obs
    widget
end

kwargstr(; kwargs...) = join(map(kw->string(kw[1],"=",kw[2]),kwargs), ",")
