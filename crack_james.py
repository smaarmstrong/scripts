import itertools
import subprocess
import time

def generate_variations(password):
    variations = [password]
    variations.append(password.lower())
    variations.append(password.upper())

    if password.endswith('@'):
        variations.append(password[:-1] + '!')
    if password.find('22@') != -1:
        variations.append(password.replace('22@', '23@'))
    if password.find('24@!') != -1:
        variations.append(password.replace('24@!', '24!@'))

    # Add simple number variations
    try:
      num = int(password[-3:-1])
      variations.append(password[:-3] + str(num+1) + password[-1:])
      variations.append(password[:-3] + str(num-1) + password[-1:])

    except:
      pass

    # Add case variations
    for i in range(1, len(password) - 1):
      temp = list(password)
      if temp[i].isalpha():
        temp[i] = temp[i].upper() if temp[i].islower() else temp[i].lower()
        variations.append("".join(temp))

    return variations

def attempt_unlock(password, drive_letter="C:"): #Change Drive letter as needed.
    try:
        command = f'manage-bde -unlock {drive_letter} -password "{password}"'
        process = subprocess.run(command, shell=True, capture_output=True, text=True)

        if "The password was correct." in process.stdout:
            print(f"Success! Password found: {password}")
            return True
        else:
            print(f"Failed: {password}")
            return False

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

base_passwords = ["CameraFilm12@", "WaterOrange130!*", "20Downsway22@", "20Downsway24@!"]

start_time = time.time()
total_attempts = 0

for password in base_passwords:
    for variation in generate_variations(password):
        total_attempts += 1
        if attempt_unlock(variation):
            end_time = time.time()
            elapsed_time = end_time - start_time
            print(f"Time taken: {elapsed_time:.2f} seconds")
            exit()

end_time = time.time()
elapsed_time = end_time - start_time
print(f"Password not found after {total_attempts} attempts. Time taken: {elapsed_time:.2f} seconds")
