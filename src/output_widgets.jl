export latex

function latex(formula)
    if !(formula isa Observable)
        formula = Observable(formula)
    end
    tex = vue(dom"div.katex"("{{formula}}"), ["formula" => formula])
    import!(tex, ["https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0-alpha/katex.min.js",
                  "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0-alpha/katex.min.css"])
    tex
end
