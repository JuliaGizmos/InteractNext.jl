import WebIO: render, richest_html

"""
WebIO.render(obs::Observable)

Returns a WebIO Node whose contents are the richest version of the observable's
value, and which updates to display the observable's current value
"""
function render(obs::Observable)
    # setup output area which updates when `obs`'s value changes
    w = Scope()

    # get the richest representation of obs's current value (as a string)
    html_contents_str = richest_html(obs[])

    # Avoid nested <script> issues by initialising as an empty node and updating later
    node = w(dom"div#out"(; setInnerHtml=html_contents_str))

    # will store the string of html which the `obs` value is converted to
    output_obs = Observable(w, "obs-output", html_contents_str)

    # ensure output_obs updates with the new html representation of obs when obs updates
    map!(richest_html, output_obs, obs)

    # ensure the output area updates when output_obs updates (after obs updates)
    output_updater = @js (updated_htmlstr) -> begin
        @var el = this.dom.querySelector("#out")
        WebIO.propUtils.setInnerHtml(el, updated_htmlstr)
    end
    onjs(output_obs, output_updater)

    # return the wrapped node
    node
end
