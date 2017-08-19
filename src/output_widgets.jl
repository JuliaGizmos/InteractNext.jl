export latex

latex(ob::Observable{<:AbstractString}; label="") = latex_widg(label, ob)
latex(value; label="") = katex_widg(label, Observable(stringmime("text/latex", value)))

function katex_widg(label, ob::Observable{<:AbstractString})
    id = WebIO.newid("tex")
    template = dom"div"(label, dom"span#$id[v-html=mathhtml]"(""))
    computed = Dict("mathhtml"=>@js function()
        # render latex after DOM has been updated
        this["\$nextTick"](function ()
            @var el = this["\$el"].querySelector("#"+$id)
            katex.renderMathInElement(el, d("delimiters"=> [
              d(left=>"\$\$", right=>"\$\$", display=>true),
              d(left=>"\$", right=>"\$", display=>false),
              d(left=>"\\[", right=>"\\]", display=>true),
              d(left=>"\\(", right=>"\\)", display=>false)
            ]))
        end)
        return this.latex_str
    end)
    make_widget(template, ob;
                obskey=:latex_str, watch_obs=false, computed=computed)
end
