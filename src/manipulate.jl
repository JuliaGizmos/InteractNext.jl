export @manipulate, Manipulate

struct Manipulate
    widgets::Vector # of WebIO Widgets I guess
    outobs::Observable
end

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
    :(map($lambda, $(map(s->:(obs($s)), symbols)...)))
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
        Manipulate([$(widgets...)], $(esc(map_block(block, syms))))
    end
end

function WebIO.render(m::InteractNext.Manipulate)
    dom"div"(m.widgets..., WebIO.render(m.outobs))
end


widget(x::Range, label="") = slider(x; label=label)
