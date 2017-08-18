export obs

const noopjs = (@js function() end)

const vue_deps = [Dict("url"=>"vue", "type"=>"js")]
# Run before dependencies are loaded to set up js paths
const systemjs_config_vue = Dict(
    "paths"=>Dict("vue"=>"https://gitcdn.xyz/repo/vuejs/vue/v2.4.2/dist/vue.js")
)
const vue_predeps_fn = @js function ()
    SystemJS.config($systemjs_config_vue)
end

"""

`kwargs` can be used to pass extra options to the Vue(...) function. E.g.
`vue(...; methods=Dict(:sayhello=>@js function(){ alert("hello!") }))`

JS widget creation callback functions:
`run_predeps()`: runs before dependencies are loaded, so can be used to specify
dependency paths for example.
`run_ondeps(Vue, Dep_Modules...)`: runs after dependencies are loaded, but
before the Vue instance is created. Can be used to initialise component
libraries for the Vue instance. Arguments passed to run_ondeps are the Vue instance,
then any module objects of the JS libs specified in dependencies.
`run_post(Vue, Dep_Modules...)`: runs after the Vue instance is created.

For all the above JS functions `this` is set to the Widget instance. In run_post
this.vue will refer to the current Vue instance.
"""
function vue(template, data=Dict(); dependencies=vuedep,
             run_predeps=vue_predeps_fn, run_ondeps=noopjs, run_post=noopjs,
             kwargs...)
    id = WebIO.newid("vue-instance")

    wrapper = Widget(id,
        dependencies=dependencies
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

    # Run before dependencies are loaded, e.g. to set up SystemJS config
    onjs(wrapper, "preDependencies", run_predeps)

    ondeps_fn = @js function (Vue)
        # `this` is set to the JS Widget instance, if other deps have been
        # specified then
        ($run_ondeps).apply(this, arguments)
        this.vue = @new Vue($options)
        $(values(watches)...)
        ($run_post).apply(this, arguments)
    end

    ondependencies(wrapper, ondeps_fn)

    wrapper(dom"div"(template; id=id))
end

# store mapping from widgets to observables
widgobs = Dict{Any, Observable}()
# users access a widget's Observable via this function
obs(widget) = widgobs[widget]

function make_widget(template, wobs::Observable;
                     obskey=:value, realobs=wobs, data=Dict(),
                     run_predeps=predeps_fn, run_ondeps=ondeps_fn, kwargs...)
    on(identity, wobs) # ensures updates propagate back to julia
    data[obskey] = wobs
    widget = vue(template, data; dependencies=widget_deps,
                 run_predeps=run_predeps, run_ondeps=run_ondeps, kwargs...)
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
