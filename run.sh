#!/bin/bash
set -e

shellOptions="-ex"

if [ $# -eq 1 ]; then
    selected_cmd=$1
    selected_target=""

elif [ $# -eq 2 ]; then
    selected_cmd=$1
    selected_target=$2

else
    echo "Usage:"
    echo
    current_cmd=""
    while IFS= read -r line; do
        
        if [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]]; then
            cmd="${BASH_REMATCH[1]}"
            echo "./run.sh $cmd"
            current_cmd=$cmd
        
        elif [[ $line =~ ^\<\!\-\-\ TARGET\ (.*)\ \-\-\>$ ]]; then
            target="${BASH_REMATCH[1]}"
            echo "./run.sh $current_cmd $target"
        fi
    done < "README.md"
    exit 0
fi

echo '#/bin/bash' > script.sh
echo 'set -e' >> script.sh
echo 'echo' >> script.sh
chmod +x script.sh

current_cmd=""
current_target=""

is_inside_script_block="false"

is_on_target() {
    if [ "$current_cmd" = "$selected_cmd" ]; then
        if [ "$selected_target" = "" ] || [ "$selected_target" = "$current_target" ]; then
            return 0; # yes
        fi
    fi
    return 1; # no
}

while IFS= read -r line; do

    # Is inside of a script block
    if [ "$is_inside_script_block" = "true" ]; then

        # Script block end (line=```)
        if [ "$line" = "\`\`\`" ]; then
            is_inside_script_block="false"
            echo ")" >> script.sh
            echo "echo" >> script.sh

        # Script line
        else
            echo "$line" >> script.sh
        fi

    # Is outside of a script block
    else

        # Script block begin (line=```bash)
        if [ "$line" = "\`\`\`bash" ] && is_on_target; then
            is_inside_script_block="true"
            echo "(" >> script.sh
            echo "set $shellOptions" >> script.sh

        # EXEC
        elif [[ $line =~ ^\<\!\-\-\ EXEC\ (.*)\ \-\-\>$ ]] && is_on_target; then
            # add_title
            command="${BASH_REMATCH[1]}"
            echo "(" >> script.sh
            echo "set $shellOptions" >> script.sh
            echo "$command" >> script.sh
            echo ")" >> script.sh
            echo "echo" >> script.sh

        # COMMAND
        elif [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]]; then
            current_cmd="${BASH_REMATCH[1]}"

        # TARGET
        elif [[ $line =~ ^\<\!\-\-\ TARGET\ (.*)\ \-\-\>$ ]]; then
            current_target="${BASH_REMATCH[1]}"
            current_target_level=""

        # Title
        elif [[ "$line" == \#* ]]; then

            if [ "$current_target" != "" ]; then

                str=$line
                level=0

                while [[ "$str" =~ ^# ]]; do
                    ((++level))
                    str="${str#'#'}" # Remove the first '#' character
                done

                if [ "$current_target_level" = "" ]; then
                    current_target_level=$level

                elif [ "$current_target_level" -ge "$level" ]; then
                    current_target=""
                fi
            fi

            if is_on_target; then
                echo "printf \"\\e[1;34m$line\\e[0m\\n\"" >> script.sh
                # echo 'read -p "Press Enter to continue..."' >> script.sh
            fi

        # elif [[ $line =~ ^\<\!\-\-\ CONFIG\ ([a-zA-Z]+)\:\ (.*)\ \-\-\>$ ]]; then
        #     # CONFIG
        #     parameterName="${BASH_REMATCH[1]}"
        #     parameterValue="${BASH_REMATCH[2]}"
        #     # echo "parameterName: $parameterName"
        #     # echo "parameterValue: $parameterValue"
        #     eval "$parameterName=\"$parameterValue\""
        #     # echo "${!parameterName}"
        fi
    fi
done < "README.md"

bash script.sh
