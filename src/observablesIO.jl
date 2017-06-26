const mime_order = map(MIME, [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/markdown", "application/javascript", "text/plain" ])

function richest_mime(val)
    for mimetype in mime_order
        mimewritable(mimetype, val) && return mimetype
    end
    error("value not writable for any mimetypes")
end

richest_html(val) = reprmime(richest_mime(val), val)

# May have some use for this later
output_observables = Dict{Observable, Vector{Observable}}()

function Base.show(stream::IO, ::MIME{Symbol("text/html")}, obs::Observable)
    # setup output area which updates when `obs`'s value changes
    w = Widget()

    # will store the string of html which the `obs` value is converted to
    output_obs = Observable(w, "obs-output", "")

    # store the output observations TODO: needed?
    outvec = get!(output_observables, obs, Observable[])
    push!(outvec, output_obs)

    # ensure output_obs updates with the new html representation of obs when obs updates
    map!(richest_html, output_obs, obs)

    # ensure the output area updates when output_obs updates
    onjs(output_obs, @js (updated_htmlstr) -> begin
        @var el = this.dom.querySelector("#out")
        WebIO.setInnerHtml(el, updated_htmlstr)
    end)

    # create the output element
    Base.show(stream, MIME("text/html"), w(dom"div#out"()))

    # set initial html string value (triggers the map! and onjs above)
    output_obs[] = richest_html(obs[])
end
