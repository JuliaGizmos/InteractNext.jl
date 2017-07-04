const mime_order = map(MIME, [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/markdown", "application/javascript", "text/plain" ])

function richest_mime(val)
    for mimetype in mime_order
        mimewritable(mimetype, val) && return mimetype
    end
    error("value not writable for any mimetypes")
end

richest_html(val) = reprmime(richest_mime(val), val)

"""
WebIO.render(obs::Observable)

Returns a WebIO node whose contents are the richest version of the observable's
value, and which updates to display the observable's current value
"""
function WebIO.render(obs::Observable)
    # setup output area which updates when `obs`'s value changes
    w = Widget()

    # get the richest representation of obs current value (as a string)
    html_contents_str = richest_html(obs[])

    node = w(dom"div#out"(; attributes=Dict(:setInnerHtml=>html_contents_str)))

    # will store the string of html which the `obs` value is converted to
    output_obs = Observable(w, "obs-output", html_contents_str)

    # ensure output_obs updates with the new html representation of obs when obs updates
    map!(richest_html, output_obs, obs)

    # ensure the output area updates when output_obs updates (after obs updates)
    onjs(output_obs, @js (updated_htmlstr) -> begin
        @var el = this.dom.querySelector("#out")
        WebIO.attrUtils.setInnerHtml(el, updated_htmlstr)
    end)

    # return the wrapped node
    node
end
