# Define the list of wordlist files
wordlists = []
while True:
    filename = input("Enter file name or 's' to submit: ")
    if filename == 's':
        break
    wordlists.append(filename)

output_file = 'output.txt'

# Read all lines from each wordlist file into a list of lists
lines = []

for wordlist in wordlists:
    with open(wordlist, 'r', encoding='utf-8', errors='ignore') as f:
        lines.append(f.readlines())

# Determine the maximum number of lines across all wordlists
max_lines = max(len(wordlist_lines) for wordlist_lines in lines)

# Open the output file to write the combined lines
with open(output_file, 'w', encoding='utf-8') as out_file:
    # Iterate through each line index up to the maximum number of lines
    for i in range(max_lines):
        for wordlist_lines in lines:
            if i < len(wordlist_lines):
                out_file.write(wordlist_lines[i].strip() + '\n')

print(f"Lines have been written to {output_file}")

# grep -v '^#' output.txt | tr ' ' '\n' | awk '!seen[$0]++' > outputfile.txt