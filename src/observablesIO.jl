const mime_order = map(MIME, [ "text/html", "text/latex", "image/svg+xml", "image/png", "image/jpeg", "text/markdown", "application/javascript", "text/plain" ])

function richest_mime(val)
    for mimetype in mime_order
        mimewritable(mimetype, val) && return mimetype
    end
    error("value not writable for any mimetypes")
end

richest_html(val) = reprmime(richest_mime(val), val)

"""
toNode(obs::Observable)

Returns a WebIO Node whose contents are the richest version of the observable's
value, and which updates to display the observable's current value
"""
function WebIO.render(obs::Observable)
    # setup output area which updates when `obs`'s value changes
    w = Widget()

    # get the richest representation of obs's current value (as a string)
    # html_contents_str = richest_html(obs[])

    # Avoid nested <script> issues by initialising as an empty node and updating later
    node = w(dom"div#out"())
    # node = w(dom"div#out"(; attributes=Dict(:setInnerHtml=>html_contents_str)))

    # will store the string of html which the `obs` value is converted to
    output_obs = Observable(w, "obs-output", "")

    # ensure output_obs updates with the new html representation of obs when obs updates
    map!(richest_html, output_obs, obs)

    # ensure the output area updates when output_obs updates (after obs updates)
    output_updater = @js (updated_htmlstr) -> begin
        @var el = this.dom.querySelector("#out")
        WebIO.attrUtils.setInnerHtml(el, updated_htmlstr)
    end
    onjs(output_obs, output_updater)

    # ensure the output area updates on initial load
    on(w, "widget_created") do args...
        output_obs[]=richest_html(obs[])
    end

    # return the wrapped node
    node
end
