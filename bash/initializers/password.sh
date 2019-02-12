# https://blog.sleeplessbeastie.eu/2016/04/11/how-to-generate-random-password-using-command-line/

# amended to copy to pasteboard because no one has time to select and copy;
# also removes trailing newline
generate_password() {
  ARG1=${1:-20}
  ((test -n "$ARG1" && test "$ARG1" -ge 0) && \
    openssl rand -base64 $ARG1 | colrm $(expr $ARG1 + 1)) | tr -d '\n' | pbcopy;
  echo $(pbpaste);
};

alias pass=generate_password
