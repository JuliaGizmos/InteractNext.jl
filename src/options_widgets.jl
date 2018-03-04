export togglebuttons, radiobuttons, dropdown

"""
```
togglebuttons(labels_values::Associative;
              selected = medianelement(values(labels_values)),
              ob::Observable = Observable(value),
              multiselect=false)

Creates a set of toggle buttons whose labels will be the keys of labels_values.
When selected the widget's observable `ob` will hold the corresponding value
of the last selected button.

If `multiselect=true` the observable will hold an array containing the values
corresponding to all selected buttons
```
e.g. `togglebuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function togglebuttons(labels_values::Associative;
                       multiselect=false, label="",
                       selected = multiselect ?
                           Vector{Int}() : medianelement(1:length(labels_values)))

    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    buttons =
        dom"md-button[v-on:click=select_fn(value), :key=idx,
                      :class={'md-toggle': is_selected(value)}]"(
            "{{label}}",
            # commas in attribute values (value, label, idx), don't parse well
            # in the dom"...", so we'll use the `attributes` kwarg
            attributes=Dict("v-for"=>"(value, label, idx) in labels_values"),
            style=Dict(:textTransform=>"none")
        )

    select_fn = @js function (val)
        if (this.single_select)
            this.selected = val
        else
            this.selected.indexOf(val) === -1 ?
                this.selected.push(val) : # push if not in list
                this.selected.splice(this.selected.indexOf(val), 1) # remove if in list
        end
    end
    is_selected = @js function(val)
        @var res
        if (this.single_select)
            res = (this.selected === val)
        else
            res = (this.selected.indexOf(val) >= 0)
        end
        return res
    end

    template = dom"div"(
        wdglabel(label),
        dom"md-button-toggle[class=md-raised md-primary, :md-single=single_select, :md-manual-toggle=manual_toggle]"(buttons),
        style=Dict(:display=>"inline-flex")
    )

    vals = collect(values(labels_values))
    labels_idxs = Dict(zip(keys(labels_values), 1:length(labels_values)))
    ob2 = Observable{Any}(vals[selected[]])
    on(selected) do x
        ob2[] = vals[x]
    end

    toglbtns = vue(template, ["selected" => selected,
                              :single_select=>!multiselect,
                              :manual_toggle=>true,
                              :labels_values=>labels_idxs],
                   methods=Dict("select_fn"=>select_fn,
                                "is_selected"=>is_selected))
    primary_obs!(toglbtns, ob2)
    slap_material_design!(toglbtns)
end

"""
togglebuttons(values::AbstractArray; kwargs...)
creates togglebuttons with labels `string.(values)`

see togglebuttons(labels_values::Associative; ...) for more details
"""
togglebuttons(vals::AbstractArray; kwargs...) =
    togglebuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
radiobuttons(labels_values::Associative;
              value = first(values(labels_values)),
              ob::Observable = Observable(value),
              label="")
```
e.g. `radiobuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function radiobuttons(labels_values::Associative;
                      selected=first(values(labels_values)), label="")
    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    buttons =
        dom"md-radio[v-model=radio, :md-value=value, :key=idx, class=md-primary]"(
            "{{btnlabel}}",
            # commas in attribute values (value, btnlabel, idx), don't parse well
            # in the dom"...", so we'll use the `attributes` kwarg
            attributes=Dict("v-for"=>"(value, btnlabel, idx) in labels_values")
        )
    template = dom"div"(wdglabel(label), buttons)
    radiobtns = vue(template, ["radio" => selected,
                               :labels_values=>labels_values])
    radiobtns["selected"] = selected
    primary_obs!(radiobtns, "radio")
    slap_material_design!(radiobtns)
end

"""
radiobuttons(values::AbstractArray; kwargs...)
creates radiobuttons with labels `string.(values)`

see radiobuttons(labels_values::Associative; ...) for more details
"""
radiobuttons(vals::AbstractArray; kwargs...) =
    radiobuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
dropdown(labels_values::Associative;
         value = first(values(labels_values)),
         label = "select",
         ob::Observable = Observable(value),
         multiselect = false)
```
Creates a dropdown menu whose item labels will be the keys of labels_values.
When an item is selected, the widget's observable `ob` will hold the
value of the selected item.

If `multiselect=true` the observable will hold an array containing the values
of all selected items

e.g. `dropdown(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`

"""
function dropdown(labels_values::Associative;
                  label="select",
                  multiselect=false,
                  selected=multiselect ?
                      valtype(labels_values)[] :
                      first(values(labels_values)),
                  modelkey="dropd",
                  kwargs...)
    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    menu_items = map(enumerate(labels_values)) do i_label_value
        i,(itemlabel, value) = i_label_value
        dom"""md-option[key=$i, value=$value]"""(itemlabel)
    end
    multi_str = multiselect ? ", multiple=true" : ""
    template = dom"md-input-container"(
                   dom"label"(wdglabel(label)),
                   dom"md-select[v-model=$modelkey$multi_str]"(menu_items...)
               )
    dropmenu = vue(template, [modelkey => selected], kwargs...)
    dropmenu["selected"] = dropmenu[modelkey]
    primary_obs!(dropmenu, "selected")
    slap_material_design!(dropmenu)
end

"""
dropdown(values::AbstractArray; kwargs...)
creates dropdown with labels `string.(values)`

see dropdown(labels_values::Associative; ...) for more details
"""
dropdown(vals::AbstractArray; kwargs...) =
    dropdown(OrderedDict(zip(string.(vals), vals)); kwargs...)
