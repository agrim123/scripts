#!/bin/bash

c=('/usr/share/cowsay/cows/*.cow')
cows=( $c )
random_cow=${cows[$RANDOM % ${#cows[@]} ]}
cow_file_name=${random_cow[@]}
cow_name=${cow_file_name/\/usr\/share\/cowsay\/cows\// }
cow=${cow_name/.cow/ }

# Display cow with message
# my_file contains store of message that you want to display
shuf -n 1 my_file | cowsay -f $cow
