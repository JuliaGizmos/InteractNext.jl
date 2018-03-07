export @manipulate

function make_widget(binding)
    if binding.head != :(=)
        error("@manipulate syntax error.")
    end
    sym, expr = binding.args
    Expr(:(=), esc(sym),
         Expr(:call, widget, esc(expr), string(sym)))
end

function display_widgets(widgetvars)
    map(v -> Expr(:call, esc(:display), esc(v)), widgetvars)
end

function map_block(block, symbols)
    lambda = Expr(:(->), Expr(:tuple, symbols...),
                  block)
    f = gensym()
    quote
        $f = $lambda
        ob = Observable{Any}($f($(map(s->:(observe($s)[]), symbols)...)))
        map!($f, ob, $(map(s->:(observe($s)), symbols)...))
        ob
    end
end

function symbols(bindings)
    map(x->x.args[1], bindings)
end

macro manipulate(expr)
    if expr.head != :for
        error("@manipulate syntax is @manipulate for ",
              " [<variable>=<domain>,]... <expression> end")
    end
    block = expr.args[2]
    if expr.args[1].head == :block
        bindings = expr.args[1].args
    else
        bindings = [expr.args[1]]
    end
    syms = symbols(bindings)

    widgets = map(make_widget, bindings)
    quote
        dom"div"($(widgets...), WebIO.render($(esc(map_block(block, syms)))))
    end
end

widget(x::Range, label="") = slider(x; label=label)
widget(x::Observable, label="") = x
widget(x::WebIO.Node{<:Any}, label="") = x
widget(x::WebIO.Scope, label="") = x
widget(x::AbstractVector, label="") = togglebuttons(x, label=label) # slider(x; label=label) ?
widget(x::Associative, label="") = togglebuttons(x, label=label)
widget(x::Bool, label="") = checkbox(x, label=label)
widget(x::AbstractString, label="") = textbox(x, label=label, typ=AbstractString)
# widget{T <: Number}(x::T, label="") = textbox(typ=T, value=x, label=label)
