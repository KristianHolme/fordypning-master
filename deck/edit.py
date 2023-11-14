multiplier = 1.01324996582e+15  # Change this to the desired multiplier

# Open the file with numbers
with open('PERM.inc', 'r') as file:
    # Optionally, open a new file to write the results
    outname = 'PERM2.inc'
    with open(outname, 'w') as output_file:
        # Loop through each line in the file
        for line in file:
            # Convert the line to a number (float or int)
            try:
                number = float(line.strip())
                
                # Multiply the number by the multiplier
                result = number * multiplier
                
                # Print or write the result
                print(result)
                output_file.write(f"{result}\n")
            except ValueError:
                result = line.strip()
                output_file.write(f"{result}\n")

print(f"Multiplication complete. Results are saved in {outname}.")