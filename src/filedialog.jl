function filedialog(label=""; placeholder="", multiselect=false, accept="*")

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
