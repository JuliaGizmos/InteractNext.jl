export latex

latex(ob::Observable{<:AbstractString}; label="") = latex_widg(label, ob)
latex(value; label="") = latex_widg(label, Observable(stringmime("text/latex", value)))

function latex_widg(label, ob::Observable{<:AbstractString})
    template = dom"div"(label, " {{ latex_str }}")
    render_latex_watch = Dict("latex_str"=> Dict(
        "handler"=>(@js function (newval, oldval)
            # render latex after DOM has been updated
            this["\$nextTick"](function ()
                katex.renderMathInElement(this["\$el"], d("delimiters"=> [
                  d(left=>"\$\$", right=>"\$\$", display=>true),
                  d(left=>"\$", right=>"\$", display=>false),
                  d(left=>"\\[", right=>"\\]", display=>true),
                  d(left=>"\\(", right=>"\\)", display=>false)
                ]))
            end)
        end),
        "immediate"=>true # run on first load
    ))
    make_widget(template, ob; obskey=:latex_str, watch=render_latex_watch)
end
