# InteractNext

InteractNext is a lot like [Interact.jl](https://github.com/JuliaGizmos/Interact.jl), except it runs not just in IJulia, but also in the [Atom/Juno IDE](https://github.com/JunoLab/Juno.jl), in a desktop window with [Blink.jl](https://github.com/JunoLab/Blink.jl), and served in a webpage via [Mux.jl](https://github.com/JuliaWeb/Mux.jl).

Over time it should also hopefully support anywhere Julia can be used to show html/css/js, and feature more widgets than Interact supported, enabling the creation of more detailed and flexible UIs from within Julia.

### Install

Currently InteractNext is not in metadata, and neither are a few packages it is built on, so for now installation is:
```
Pkg.checkout("Observables")
Pkg.clone("https://github.com/JuliaGizmos/WebIO.jl")
Pkg.clone("https://github.com/JuliaGizmos/Vue.jl")
Pkg.clone("https://github.com/JuliaGizmos/InteractNext.jl")
```
If you have those packages already, you'll want to ensure they're on master too, since they're under development atm, so

Unfortunately, until a proper WebIO release is made, we will need to run a couple of further steps. Firstly [node.js](https://nodejs.org/en/) will need to be installed. And then, run these at a Julia prompt:
```
using WebIO
WebIO.devsetup()
WebIO.bundlejs(watch=false)
```

N.b. the above are just a one-off requirement to install WebIO's javascript files. See [WebIO](https://github.com/JuliaGizmos/WebIO.jl) for more details

### Use in IJulia

```
using InteractNext

@manipulate for i in 1:10, greeting in ["Hello", "Howdy", "G'day"]
    "$greeting $i times"
end
```

### Use in Blink

```
using InteractNext
using Blink
using PlotlyJS
mp = @manipulate for k in 1:20
    x = 0:0.1:30
    y = sin.(k*x)
    plot(x, y)
end;
w = Window()
body!(w, mp)
```

### Use in Mux

```
using Mux
using InteractNext, PlotlyJS

function myapp(req)
    x = 0:0.1:30
    @manipulate for k in 1:20
        y = sin.(k*x)
        plot(x, y)
    end
end

webio_serve(page("/", req -> myapp(req)))
```

### Use in Atom/Juno

```
using InteractNext
using PlotlyJS
x = 0:0.1:30
mp = @manipulate for k in 1:20
    y = sin.(k*x)
    plot(x, y)
end
```
