#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "File $file not found."
    exit 1
fi

echo "#/bin/bash" > run.script.sh
echo "set -ex" > run.script.sh
chmod +x run.script.sh

isCommand="false"

while IFS= read -r line; do
    if [ "$isCommand" = "true" ]; then
        if [ "$line" = "\`\`\`" ]; then
            isCommand="false"
        else
            echo "$line" >> run.script.sh
        fi
    else
        if [ "$line" = "\`\`\`bash" ]; then
            isCommand="true"
        elif [[ "$line" == \#* ]]; then
            echo "printf \"\\n$line\\n\\n\"" >> run.script.sh
        fi
    fi
done < "$file"
