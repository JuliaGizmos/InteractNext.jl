const mime_order = map(MIME, [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/markdown", "application/javascript", "text/plain" ])

function richest_mime(val)
    for mimetype in mime_order
        mimewritable(mimetype, val) && return mimetype
    end
    error("value not writable for any mimetypes")
end

richest_html(val) = reprmime(richest_mime(val), val)

# these are used to update output areas wherever the observable is displayed
output_observables = Dict{Observable, Vector{Observable}}()

function Base.show(stream::IO, ::MIME{Symbol("text/html")}, obs::Observable)
    w = Widget()
    htmlout = richest_html(obs[])
    # setup output area updating when the shown observable's value changes
    output_obs = Observable(w, "obs-output", htmlout)
    output_observables[obs] = [output_obs]
    onjs(output_obs, @js (val) -> begin
        this.dom.querySelector("#out").innerHTML = val
    end)
    # update the new output_obs whenever obs updates
    map!(richest_html, output_obs, obs)

    # write the html to the stream
    write(stream, stringmime("text/html", w(dom"div#out"(htmlout))))
end
