#!/bin/bash
# Copyright (C) 2013 Remy van Elst
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

declare -a allowed_commands=('^ls -[l|d|a]$' 'ls -la' 'w' 'uptime' 'pwd' 'uname -a') 
orig="$SSH_ORIGINAL_COMMAND"
logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: SSH Connection: '$SSH_CONNECTION'";
logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: SSH Username: '$USER'";
logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: SSH Client: '$SSH_CLIENT'";
logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: Sent SSH command: '$SSH_ORIGINAL_COMMAND'";
logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: SSH Shell: '$SHELL'";

element_in_array () {
  local var
  for var in "${@:2}"; do 
    if [[ $1 =~ $var ]]; then
        return 0; 
    fi
  done
  return 1
}

element_in_array "$orig" "${allowed_commands[@]}"
command_allowed="$?"


if [[ "$orig" == "" ]]; then
        logger -i -p local0.error -t "RESTRICTED_SSH" "ERROR: Interactive shell not allowed."
        echo "Interactive shell not allowed.";
        exit 1;
elif [[ $command_allowed -eq 0 ]]; then
        logger -i -p local0.info -t "RESTRICTED_SSH" "INFO: Command \"$orig\" is allowed."
        eval "$orig"
        exit
elif [[ $command_allowed -eq 1 ]]; then
        logger -i -p local0.error -t "RESTRICTED_SSH" "ERROR: Command \"$orig\" is not allowed."
        echo "Command \"$orig\" is not allowed."
        exit 1
fi
    
