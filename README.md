********************************************************************************
********************************************************************************
WORK IN PROGRESS
================
I'm currently setting this project up, and it's not yet ready for a wider audience. If you beta-test it, please keep it private for now. I would like to finish some things before I "release" it.
********************************************************************************
********************************************************************************

Loxgraph
========

Loxgraph is a solution to display graphs for statistics on a [Loxone Miniserver](http://www.loxone.com/enuk/products/miniserver/miniserver.html).
No separate computer/server/RasPi or internet connection is needed. Loxgraph is basically a JavaScript/HTML single-page application that gets served directly from the web server built into the Loxone Miniserver.

Demo
----

[Loxgraph Demo with Sample Data](https://eik3.github.io/loxgraph/)

Screenshot
----------

![Loxgraph Screenshot](http://eik3.de/t/loxgraph-screenshot-1.png "Loxgraph Screenshot")

Installation
------------

1. Connect to your Miniserver with a FTP Client
1. Create the directory `/user/common/loxgraph`
1. Copy all files into `/user/common/loxgraph/`

Usage
-----

1. Open the Web Interface of your Loxone and append `/loxgraph` to the URL
1. Log in with your Loxone credentials

To zoom a graph, select an horizontal or vertical area. Double-click to reset zoom.
To pan, hold `shift` and drag with the mouse.
To smoothen a graph (e.g. temperature), play with the value in the lower left corner of each graph.

Contributions welcome!
----------------------

*TODO describe how to set up dev. env, code style etc*

Contact
-------

- chat: [#loxone on Freenode IRC](https://webchat.freenode.net/?channels=loxone)
- email: to protect from spammers, it's behind a [reCAPTCHA](https://www.google.com/recaptcha/mailhide/d?k=014_uSCEY1lRzKiRIO0JdoOQ==&c=-Hb3oZeGhF0pEX1WwSPbaUMcW1Ee5RN79h3Vd4COoes=)
- [open an Issue](https://github.com/eik3/loxgraph/issues/new)

License
-------

[MIT](https://github.com/eik3/loxgraph/blob/master/LICENSE)
