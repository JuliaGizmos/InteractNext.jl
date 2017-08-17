export obs

function vue(template, data=Dict(), run_postdeps=(@js function() end); kwargs...)
    id = WebIO.newid("vue-instance")

    wrapper = Widget(id,
        # The urls for these deps are defined in setup.jl
        dependencies=widget_deps
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

    onjs(wrapper, "preDependencies", @js function (ctx)
        SystemJS.config($systemjs_config)
    end)

    options = merge(Dict("el"=>"#$id", "data"=>init), Dict(kwargs))

    ondependencies(wrapper, @js function (Vue, VueSlider, VueMaterial)
        Vue.component("vue-slider", VueSlider)
        Vue.use(VueMaterial)
        this.vue = @new Vue($options)
        $(values(watches)...)
        ($run_postdeps).apply(this.vue)
    end)

    wrapper(dom"div"(template; id=id))
end

# store mapping from widgets to observables
widgobs = Dict{Any, Observable}()
# users access a widget's Observable via this function
obs(widget) = widgobs[widget]

function make_widget(template, wobs::Observable;
                     obskey=:value, realobs=wobs, data=Dict(), kwargs...)
    on(identity, wobs) # ensures updates propagate back to julia
    data[obskey] = wobs
    widget = vue(template, data; kwargs...)
    widgobs[widget] = realobs
    widget
end

kwargstr(; kwargs...) = join(map(kw->string(kw[1],"=",kw[2]),kwargs), ",")

"""Helps init widget's value and observable depending on which ones were set"""
function init_wsigval(obs, value; default=value, typ=typeof(default))
    if obs == nothing
        if value == nothing
            value = default
        end
        _typ = typ === Void ? typeof(value) : typ
        obs = Observable{_typ}(value)
    else
        # obs was set
        if value == nothing
            value = obs[]
        else
            #signal set and value set
            obs[] = value
        end
    end
    obs, value
end

# Get median elements of ranges, used for initialising sliders.
# Differs from median(r) in that it always returns an element of the range
medianidx(r) = (1+length(r)) ÷ 2
medianelement(r::Union{Range, Array}) = r[medianidx(r)]
medianelement(r::Associative) = collect(values(r))[medianidx(values(r))]

inverse_dict(d::Associative) = Dict(zip(values(d), keys(d)))
