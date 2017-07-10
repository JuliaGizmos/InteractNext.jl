using Requires

@require PlotlyJS begin
    PlotlyJS.js_default[] = :embed
    println("InteractNext: PlotlyJS enabled")
end
