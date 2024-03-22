#!/bin/bash
set -e

shellOptions="-ex"

if [ $# -eq 0 ]; then
    echo "Usage:"
    echo
    while IFS= read -r line; do
        if [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]]; then
            cmd="${BASH_REMATCH[1]}"
            echo "./run.sh $cmd"
        fi
    done < "README.md"
    exit 0
else
    selected_command=$@
fi

echo '#/bin/bash' > script.sh
echo 'set -e' >> script.sh
echo 'echo' >> script.sh
chmod +x script.sh

current_command=""
is_inside_script_block="false"

is_on_target() {
    if [ "$current_command" = "$selected_command" ]; then
        return 0; # yes
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
            echo "set -ex" >> script.sh

        # EXEC
        elif [[ $line =~ ^\<\!\-\-\ EXEC\ (.*)\ \-\-\>$ ]] && is_on_target; then
            # add_title
            command="${BASH_REMATCH[1]}"
            echo "(" >> script.sh
            echo "set -ex" >> script.sh
            echo "$command" >> script.sh
            echo ")" >> script.sh
            echo "echo" >> script.sh

        # COMMAND
        elif [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]]; then

            [ "$current_command" != "$selected_command" ] \
            && current_command="${BASH_REMATCH[1]}" \
            && current_command_level=""

        # Title
        elif [[ "$line" == \#* ]]; then

            if [ "$current_command" != "" ]; then

                str=$line
                level=0
                while [[ "$str" =~ ^# ]]; do
                    ((++level))
                    str="${str#'#'}" # Remove the first '#' character
                done

                if [ "$current_command_level" = "" ]; then
                    current_command_level=$level

                elif [ "$current_command_level" -ge "$level" ]; then
                    current_command=""
                fi
            fi

            if is_on_target; then
                echo "printf \"\\e[1;34m$line\\e[0m\\n\"" >> script.sh
                # echo 'read -p "Press Enter to continue..."' >> script.sh
            fi
        fi
    fi
done < "README.md"

bash script.sh
