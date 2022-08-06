##################
# General
##################
alias ll="ranger"
alias l="ls -lahF --hyperlink=auto --color=auto" 

##################
# Editing
##################
alias -s tf=vim
alias -s yaml=vim
alias -s go=vim
alias -s json=vim
alias -s md=vim
alias -g tfgen="terraform-docs md ./ --output-file README.md"
alias -g gss="git status -s"

##################
# Kitty related
##################
alias ssh="kitty +kitten ssh"
alias icat="kitty +kitten icat"
alias hg="kitty +kitten hyperlinked_grep"
alias diff="kitty +kitten diff"

##################
# Kubernetes
##################
alias kak="kubectl apply -k"
alias kaf="kubectl apply -f"
k3ddd () {
  # requires net-tools
  name=$1
  IP=$(ifconfig wlp0s20f3 | grep inet | grep -v inet6 | awk '{print $2}')
  k3d cluster create $name -a 2 --api-port $IP:6550 -p 443:443@loadbalancer -p 80:80@loadbalancer
}

##################
# PGP 
##################
encrypt () {
  output="${1}".$(date +%s).enc
  gpg --encrypt --armor \
    --output ${output} \
    -r 0x22391B207DAD6969 \
    -r technat@technat.ch \
    "${1}" && echo "${1} -> ${output}"
}

decrypt () {
        output=$(echo "${1}" | rev | cut -c16- | rev)
        gpg --decrypt --output ${output} "${1}" && echo "${1} -> ${output}"
}
