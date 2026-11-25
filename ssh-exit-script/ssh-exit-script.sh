#!/bin/bash

if [ -f ~/.bash_history ]; then
    rm -f ~/.bash_history
    echo "File ~/.bash_history deleted."
else
    echo "File ~/.bash_history not found."
fi

if [ -f ~/.zsh_history ]; then
    rm -f ~/.zsh_history
    echo "File ~/.zsh_history deleted."
else
    echo "File ~/.zsh_history not found."
fi

exit
