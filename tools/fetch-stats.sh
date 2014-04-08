#!/bin/bash
set -e
source $(dirname $0)/loxone-settings.txt
(
cd $(dirname $0)/../stats
rm -f index.html *.xml
wget http://$LOXUSER:$LOXPASS@$LOXHOST/stats/index.html
wget -Fi index.html -B http://$LOXUSER:$LOXPASS@$LOXHOST/stats/
rm -f styles.css
)
