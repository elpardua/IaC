#!/usr/bin/env python

from sys import argv

instanceid = str(argv [1])
tagn = str(argv [2])
tago = str(argv [3])

maindoc = """<!DOCTYPE html>

<body style="background-color:#0B1728">
	<header class="header sticky-">
					<a class="logo nt-logo" href="https://flugel.it/">
							<div class="logo__img bg-none nt-img-logo">
			    				<img class="static-logo" src="data:image/png;base64,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%3D%3D" width="115" height="37">
		    				</div>												
			        </a>
	</header>			
			
        <div style="position:absolute; width:100%; border: 0px;top:50%; left:0; text-align:center;"><h1 style="color:#FFCC00; position=absolute; top=50%" align="center">
"""

variablefield="Greetings, this is " + instanceid + " instance replying behind the ALB. My tags are " + tagn + " and " + tago 

end="""</h1></div>

</body>"""

file = open("/usr/share/nginx/html/index.html", "w")
file.write (maindoc + variablefield + end)
file.close ()
