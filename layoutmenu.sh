#!/bin/sh

cat <<EOF | xmenu
[]=   Tiled Layout				0
[M]   Monocle Layout			1
[@]   Spiral Layout				2
[\\]  Dwindle Layout			3
H[]   Deck Layout				4
TTT   Bstack Layout				5
===   Bstackhoriz Layout		6
HHH   Grid Layout				7
###   Nrowgrid Layout			8
---   Horizgrid Layout			9
:::   Gaplessgrid Layout		10
|M|   Centeredmaster Layout		11
>M>   Centeredfloatingmaster	12
><>   Floating Layout			13
EOF
