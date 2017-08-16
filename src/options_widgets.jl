export togglebuttons, radiobuttons

"""
```
togglebuttons(labels_values::Associative;
              value = first(values(labels_values)),
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
                       ob = nothing, value=nothing, multiselect=false)
    defaultval = multiselect ? [] : first(values(labels_values))
    ob, value = init_wsigval(ob, value; default=defaultval)
    btns = map(enumerate(labels_values)) do i_label_value
        i,(label, value) = i_label_value
        select_fn = "selected=$value"
        multiselect && (select_fn =
            """ if (selected.indexOf($value) == -1){ selected.push($value) }
        else { selected.splice(selected.indexOf($value), 1) }; """
        )
        dom"""md-button[value=$value, id=$i]"""(label;
                                        attributes=Dict("v-on:click"=>select_fn))
    end
    attrdict = Dict{String, Any}()
    !multiselect && (attrdict["md-single"] = true)
    template = Node(Symbol("md-button-toggle"); attributes=attrdict)(btns...)
    toglbtns = InteractNext.make_widget(template, ob; obskey=:selected)
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
              ob::Observable = Observable(value))
```
e.g. `radiobuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function radiobuttons(labels_values::Associative;
                       ob = nothing, value=nothing)
    defaultval = first(values(labels_values))
    ob, value = init_wsigval(ob, value; default=defaultval)
    btns = map(enumerate(labels_values)) do i_label_value
        i,(label, value) = i_label_value
        dom"""md-radio[v-model=radio, md-value=$value, class=md-primary]"""(label)
    end
    template = dom"div"(btns...)
    radiobtns = InteractNext.make_widget(template, ob; obskey=:radio)
end

"""
radiobuttons(values::AbstractArray; kwargs...)
creates radiobuttons with labels `string.(values)`

see radiobuttons(labels_values::Associative; ...) for more details
"""
radiobuttons(vals::AbstractArray; kwargs...) =
    radiobuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)
