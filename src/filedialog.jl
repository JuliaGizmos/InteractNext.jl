"""
`filepicker(label=""; placeholder="", multiselect=false, accept="*")`

Create a widget to select files.

If `multiselect=true` the observable will hold an array containing the paths of all
selected files. Use `accept` to only accept some formats, e.g. `accept=".csv"`
"""
function filepicker(label=""; placeholder="", multiselect=false, accept="*")

    if multiselect
        onFileUpload = js"""function (event){
            var fileArray = Array.from(event)
            return this.path = fileArray.map(function (el) {return el.path;});
        }
        """
        path = Observable(String[])
    else
        onFileUpload = js"""function (event){
            return this.path = event[0].path
        }
        """
        path = Observable("")
    end
    m_str = multiselect ? ",multiple=true" : ""
    template = dom"md-input-container"(
        dom"label"(label),
        dom"md-file[v-on:selected=onFileUpload,placeholder=$placeholder$m_str,accept=$accept]"(),
    )

    filewidget = vue(template, ["path"=>path], methods = Dict("onFileUpload" => onFileUpload))
    primary_obs!(filewidget, "path")
    slap_material_design!(filewidget)
end
