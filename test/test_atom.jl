# Atom
using InteractNext
using DataStructures
using PlotlyJS
using CSSUtil

function WebIO.render(x)
    dom"div"(; setInnerHtml=InteractNext.richest_html(x))
end

WebIO.render(::Void) = dom"span"()

x = 0:0.1:30
p = plot(x, [])

freqs = OrderedDict(zip(["pi/4", "π/2", "3π/4", "π"], [π/4, π/2, 3π/4, π]))

mp = @manipulate for freq1 in freqs, freq2 in slider(0.01:0.1:4π; label="freq2")
    y = @. sin(freq1*x) * sin(freq2*x)
    restyle!(p, y=[y])
end
w = get_page()
p.view.w = w
body!(w, vbox(mp, p))
#---

#---

using InteractNext
using PlotlyJS
x = 0:0.1:30
y = sin.(1.0.*x .+ pi)
p = plot(x, y)
mp = @manipulate for freq in [0.1, 1.0, 2.0, 4.0], phase in 0:0.1:2pi
    y = sin.(freq.*x .+ phase)
    deletetraces!(p, 1)
    addtraces!(p, scatter(;x=x, y=y, mode="lines"))
end
display.([mp,p]);
#---
# bad and slow
using InteractNext
using PlotlyJS
x = 0:0.1:30
mp = @manipulate for freq in [0.1, 1.0, 2.0], phase in 0:0.1:2pi
    y = sin.(freq.*x .+ phase)
    plot(x, y)
end
