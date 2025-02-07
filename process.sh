#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
CYAN='\033[0;36m'

# Set up logging
LOG_FILE="/tmp/audio_preview_$$.log"
touch "$LOG_FILE"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
}

display_message() {
    echo -e "$1"
    log_message "$1"
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r[${BLUE}"
    printf "%${completed}s" | tr ' ' '█'
    printf "${NC}"
    printf "%${remaining}s" | tr ' ' '░'
    printf "] ${percentage}%% ($current/$total)"
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &>/dev/null; then
    display_message "${RED}Error: ffmpeg is not installed. Please install it using 'brew install ffmpeg'${NC}"
    exit 1
fi

# Process a single file without background processes
process_single_file() {
    local file="$1"
    local dir
    local filename
    local output_name
    local preview_dir
    local output_file

    # Handle paths
    dir="$(dirname "$file")"
    filename="$(basename "$file")"
    output_name="${filename%.*}.ogg"
    preview_dir="$dir/.preview"
    output_file="$preview_dir/$output_name"

    # Check if preview already exists
    if [ -f "$output_file" ]; then
        echo "SKIP: $file"
        return
    fi

    # Create preview directory
    mkdir -p "$preview_dir"

    # Create preview
    if ffmpeg -i "$file" -t 4 -c:a libvorbis -q:a 4 "$output_file" -y 2>/dev/null; then
        echo "SUCCESS: $file"
    else
        echo "FAIL: $file"
    fi
}

# Main script
main() {
    local start_dir="$1"
    local temp_file
    local total_files
    local processed=0
    local successful=0
    local failed=0
    local skipped=0

    if [ -z "$start_dir" ]; then
        start_dir="."
    fi

    display_message "${BLUE}Scanning for audio files in: ${YELLOW}$start_dir${NC}"

    # Create temporary file
    temp_file=$(mktemp)

    # Find audio files, explicitly excluding .preview directories
    find "$start_dir" \
        -type d -name ".preview" -prune -o \
        -type f \( -iname "*.wav" -o -iname "*.aif" -o -iname "*.aiff" -o -iname "*.mp3" -o -iname "*.m4a" \) \
        -print0 >"$temp_file"

    # Count files
    total_files=$(tr -dc '\0' <"$temp_file" | wc -c)

    if [ $total_files -eq 0 ]; then
        display_message "${RED}No audio files found!${NC}"
        rm "$temp_file"
        exit 1
    fi

    display_message "${BLUE}Found ${YELLOW}$total_files${BLUE} audio files to process${NC}"
    display_message "Starting preview generation..."
    echo

    # Process files
    while IFS= read -r -d $'\0' file; do
        result=$(process_single_file "$file")

        case "$result" in
        SUCCESS*)
            ((successful++))
            echo -e "\r${GREEN}✓${NC} ${result#SUCCESS: }"
            ;;
        FAIL*)
            ((failed++))
            echo -e "\r${RED}✗${NC} ${result#FAIL: }"
            ;;
        SKIP*)
            ((skipped++))
            echo -e "\r${CYAN}•${NC} ${result#SKIP: }"
            ;;
        esac

        ((processed++))
        progress_bar $processed $total_files
        echo -en "\033[K"

        log_message "Processed ($processed/$total_files): $file - $result"
    done <"$temp_file"

    # Clean up
    rm "$temp_file"

    echo
    echo
    display_message "${BLUE}Preview generation complete!${NC}"
    display_message "${GREEN}Successfully processed: $successful${NC}"
    display_message "${CYAN}Skipped (already exists): $skipped${NC}"
    display_message "${RED}Failed: $failed${NC}"
    display_message "Log file location: $LOG_FILE"
}

# Run the script
main "$1"
