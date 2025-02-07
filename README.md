# maschine-plus-create-previews

> [!WARNING]  
> Copy the folders you want to test this with to a new location. Run the script on these test folders and check the output. Do not run this script directly on the entire Maschine+ SD card. Only use this on your own user content on your computer and then transfer the files to the Maschine+ SD card.

## Maschine+ Prehear Function

The Maschine+ requires a `.preview` hidden folder containing `.ogg` files of the same name as the audio files in the parent folder. This is necessary for the "Prehear" function to work as a user browses through sounds.

### Folder Structure for Prehear

Before running the script:

```
Audio Files Directory
├── file1.wav
├── file2.aif
├── file3.mp3
└── file4.m4a
```

After running the script:

```
Audio Files Directory
├── file1.wav
├── file2.aif
├── file3.mp3
├── file4.m4a
└── .preview
    ├── file1.ogg
    ├── file2.ogg
    ├── file3.ogg
    └── file4.ogg
```

The `.preview` folder will be created automatically by the script, and it will contain the generated `.ogg` preview files.

## Prerequisites

- `ffmpeg` must be installed. You can install it using Homebrew:
  ```sh
  brew install ffmpeg
  ```

## Usage

Run the script with the directory you want to scan as an argument. If no directory is provided, it defaults to the current directory.

```sh
chmod +x process.ch
./process.sh [directory]
```

### Example

```sh
./process.sh /path/to/audio/files
```

## Features

- Scans for audio files (`.wav`, `.aif`, `.aiff`, `.mp3`, `.m4a`)
- Generates 4-second preview clips in OGG format
- Skips files if a preview already exists
- Displays a progress bar
- Logs processing details to a log file

## Script Details

### Color Definitions

The script uses color codes for terminal output:

- `GREEN`: Success messages
- `BLUE`: Informational messages
- `RED`: Error messages
- `YELLOW`: Highlighted messages
- `CYAN`: Skipped messages
- `NC`: No color

### Logging

Logs are saved to a temporary file in `/tmp` with a unique name based on the process ID.

### Functions

- `log_message()`: Logs messages with a timestamp.
- `display_message()`: Displays and logs messages.
- `progress_bar()`: Displays a progress bar.
- `process_single_file()`: Processes a single audio file to generate a preview.
- `main()`: Main function that scans the directory, processes files, and displays results.

### Exit Codes

- `0`: Success
- `1`: Error (e.g., `ffmpeg` not installed, no audio files found)

## Log File

The log file location is displayed at the end of the script execution. It contains detailed information about the processed files.

## License

This project is licensed under the MIT License.