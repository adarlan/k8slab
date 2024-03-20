#!/bin/bash
set -e

shellOptions="-ex"

if [ $# -eq 1 ]; then
    target=$1
    target_status=off
else
    echo "Usage:"
    while IFS= read -r line; do
        if [[ $line =~ ^\<\!\-\-\ BEGIN\ (.*)\ \-\-\>$ ]]; then
            option="${BASH_REMATCH[1]}"
            echo "  ./run.sh $option"
        fi
    done < "README.md"
fi

echo '#/bin/bash' > script.sh
echo 'set -e' >> script.sh
echo 'echo' >> script.sh
chmod +x script.sh

is_inside_script_block="false"

printf_title=""
press_enter_to_continue="false"
add_title() {
    [ "$printf_title" != "" ] && echo $printf_title >> script.sh
    printf_title=""
    if [ "$press_enter_to_continue" = "true" ]; then
        # echo 'read -p "Press Enter to continue..."' >> script.sh
        press_enter_to_continue="false"
    fi
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
        if [ "$line" = "\`\`\`bash" ] && [ "$target_status" = "on" ]; then
            add_title
            is_inside_script_block="true"
            echo "(" >> script.sh
            echo "set $shellOptions" >> script.sh

        # Title
        elif [[ "$line" == \#* ]]; then
            if [[ $line =~ ^\#\#\ .*$ ]]; then
                press_enter_to_continue="true"
            fi
            printf_title="printf \"\\e[1;34m$line\\e[0m\\n\""

        # <!-- BEGIN target -->
        elif [[ $line =~ ^\<\!\-\-\ BEGIN\ $target\ \-\-\>$ ]]; then
            target_status=on

        # <!-- END target -->
        elif [[ $line =~ ^\<\!\-\-\ END\ $target\ \-\-\>$ ]]; then
            target_status=off

        # <!-- COMMAND command -->
        elif [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]] && [ "$target_status" = "on" ]; then
            add_title
            command="${BASH_REMATCH[1]}"
            echo "(" >> script.sh
            echo "set $shellOptions" >> script.sh
            echo "$command" >> script.sh
            echo ")" >> script.sh
            echo "echo" >> script.sh

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
