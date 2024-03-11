#!/bin/bash
set -e

shellOptions="-ex"

[ $# -eq 1 ] && function="$1" || function="__main__"

echo '#/bin/bash' > script.sh
echo 'set -e' >> script.sh
echo 'echo' >> script.sh
chmod +x script.sh

functionName="__main__"
echo "$functionName() {" >> script.sh
echo ":" >> script.sh

isCommand="false"

while IFS= read -r line; do
    if [ "$isCommand" = "true" ]; then

        if [ "$line" = "\`\`\`" ]; then
            # CODE BLOCK END
            isCommand="false"
            echo ")" >> script.sh
            echo "echo" >> script.sh

        else
            # CODE LINE
            echo "$line" >> script.sh
        fi
    else
        if [ "$line" = "\`\`\`bash" ]; then
            # CODE BLOCK START
            isCommand="true"
            echo "(" >> script.sh
            echo "set $shellOptions" >> script.sh
        
        elif [[ "$line" == \#* ]]; then
            # TITLE
            echo "printf \"\\e[1;34m$line\\e[0m\\n\"" >> script.sh
            # echo 'read -p "Press Enter to continue..."' >> script.sh

        elif [[ $line =~ ^\<\!\-\-\ FUNCTION\ ([a-z_]+)\ \-\-\>$ ]]; then
            # FUNCTION
            functionName="${BASH_REMATCH[1]}"
            echo "}" >> script.sh
            echo "$functionName() {" >> script.sh

        elif [[ $line =~ ^\<\!\-\-\ COMMAND\ (.*)\ \-\-\>$ ]]; then
            # COMMAND
            command="${BASH_REMATCH[1]}"
            echo "$command" >> script.sh

        elif [[ $line =~ ^\<\!\-\-\ CONFIG\ ([a-zA-Z]+)\:\ (.*)\ \-\-\>$ ]]; then
            # CONFIG
            parameterName="${BASH_REMATCH[1]}"
            parameterValue="${BASH_REMATCH[2]}"
            # echo "parameterName: $parameterName"
            # echo "parameterValue: $parameterValue"
            eval "$parameterName=\"$parameterValue\""
            # echo "${!parameterName}"
        fi
    fi
done < "README.md"

echo "}" >> script.sh

echo "$function" >> script.sh

bash script.sh
