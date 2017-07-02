using InteractNext

s1 = slider(1:20)
#---

sobs = obs(s1)
display.([s1, sobs]);
#---
button1 = button("button one {{clicks}}")
#---
num_clicks = obs(button1)
button2 = button("button two {{clicks}}", num_clicks)
#---
display.([button1, button2, num_clicks]);
#---
button1
#---
using WebIO
WebIO.setup()
dom"div"(
    dom"div"("Hello, World!"),
    dom"div"("Hello, World!"),
    dom"div"("Hello, World!")
)
#---
using WebIO

wrapper = Widget()
wrapper(dom"div"("Hello, World!"))
#---
using Vue
WebIO.setup()

template = dom"p[v-if=visible]"("{{message}}")
ob = Observable("hello")
vue(template, [:message=>ob, :visible=>true])
#---
ob[] = "suckit"

#---
display(MIME("text/html"), "hello")
#---
using WebIO
WebIO.setup()
# dom"div"("allo allo")
dom"script"("""console.log("hello")""")
#---
using Blink
# using Juno
# w = Juno.Atom.blinkplot()
w = Window()
code = """
<script>console.log("hello, this is your console speaking")</script>
<div>yup</div>
"""
@js(w, Blink.fill("body", $code))
#---
using Blink
w = Window()
using InteractNext
s1 = slider(1:20)
sobs = obs(s1)
body!(w, dom"div"(s1, sobs))
#---
using Blink, InteractNext
w = Window()
body!(w, dom"div"()) # required to load webio_bundle
ob = Observable(10)
body!(w, ob)
#---
ob[] = 20
#---
using Blink, InteractNext
w = Window()
buttondiv = Node(:div, "<button>a button?</button>")
body!(w,buttondiv)
