#!/bin/bash

# Global Vars
HOSTS=()
PORTS=()
CASES_COUNT=0
RESULTS=()

# 입력 csv 형식
host_ip_csv_processor() {
    
    local file="$1"

    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "File $file not found."
        return 1
    fi

    # Read the file line by line
    while IFS=',' read -r host port
    do
	HOSTS+=("$host")
	PORTS+=("$port")
    done < "$file"

    CASES_COUNT=${#HOSTS[@]}
}

# check hosts and ports
check() {

    for (( i=0; i<$CASES_COUNT; i++ )); do
	local host=${HOSTS[$i]}
	local port=${PORTS[$i]}
        
	check_one $host $port
    done
}

# check host and port
check_one() {

    if nc -zvw1 "$1" "$2" &> /dev/null; then
        RESULTS+=("OPEN")
    else
        RESULTS+=("CLOSED")
    fi
}

# print result
print_result() {
    local host_max_length=$(calc_host_max_length)
    
    print_table_header $host_max_length

    for (( i=0; i<$CASES_COUNT; i++ )); do
        local port=${PORTS[$i]}

        print_one_result $host_max_length ${HOSTS[$i]} ${PORTS[$i]} ${RESULTS[$i]}
    done

}

# calc host max length
calc_host_max_length() {
    max_length=0

    # Loop through the list of hostnames
    for hostname in "${HOSTS[@]}"; do
        # Calculate the length of the current hostname
        length=${#hostname}
    
        # Compare with the current max_length and update if necessary
        if (( length > max_length )); then
            max_length=$length
        fi
    done
    
    echo $max_length
}

print_table_header() {
    printf "%-$1s %-10s %-10s\n" "Host" "Port" "Status"
    printf "%-$1s %-10s %-10s\n" "----" "----" "------"
}

print_one_result() {
    printf "%-$1s %-10s %-10s\n" $2 $3 $4
}

# driver
host_ip_csv_processor $1
check
print_result
