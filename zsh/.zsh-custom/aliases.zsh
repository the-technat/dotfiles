##################
# General
##################
alias ll="ranger"
alias l="ls -lahF --hyperlink=auto --color=auto"
alias switchyubikey="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"

##################
# Editing
##################
alias -s tf=vim
alias -s yaml=vim
alias -s go=vim
alias -s json=vim
alias -s md=vim
alias -g tfgen="terraform-docs md --output-file README.md"
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
alias kk="kubectl --kubeconfig ~/.kube/cucumber.kubeconfig"
alias kebug="kubectl run --rm -ti --image docker.io/nicolaka/netshoot debugbox$RANDOM -- bash"
function allns {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i

    if [ -z "$1" ]
    then
        kubectl get --ignore-not-found ${i}
    else
        kubectl -n ${1} get --ignore-not-found ${i}
    fi
  done
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


##################
# AWS
##################
nukeAccount () {
  name="$(date +%s)config.yaml"
  cat > /tmp/$name << EOF
    regions:
    - sa-east-1
    - us-east-1
    - eu-central-2
    - global

    account-blocklist:
    - "999999999999" # production

    accounts:
      "298410952490":
        filters:
          IAMUser:
          - "banana"
          - "aws_baseline"
          IAMUserPolicyAttachment:
          - "banana -> AdministratorAccess"
          - "aws_baseline -> AdministratorAccess"
          IAMUserAccessKey:
          - type: "glob"
            value: "banana -> *"
          - type: "glob"
            value: "aws_baseline -> *"
          IAMVirtualMFADevice:
          - type: "glob"
            value: "arn:aws:iam::298410952490:mfa/*"
          IAMLoginProfile:
          - type: "glob"
            value: "*banana*"
EOF
  aws-nuke --config /tmp/$name --no-dry-run
  rm /tmp/$name
}
