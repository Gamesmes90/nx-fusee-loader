import shutil
import requests
import sys
import zipfile
import re
import os


# Downloads the latest hekate release from CTCaer's github
def main():
    # Get latest release
    url = "https://api.github.com/repos/CTCaer/hekate/releases/latest"
    response = requests.get(url)
    data = response.json()
    assets = data["assets"]

    # Find zip file matching the pattern
    pattern = r'^hekate_ctcaer_\d+\.\d+\.\d+\_Nyx_\d+\.\d+\.\d+\.zip$'
    for asset in assets:
        if re.match(pattern, asset["name"]):
            print(f"Downloading {asset['name']}")
            download_url = asset["browser_download_url"]
            break
    else:
        print("hekate_ctcaer_X.X.X_Nyx_X.X.X.zip not found in assets")
        sys.exit(1)

    try:
        # Download hekate
        response = requests.get(download_url)
        with open("hekate.zip", "wb") as f:
            f.write(response.content)

        # Extract hekate
        with zipfile.ZipFile("hekate.zip", "r") as zip_ref:
            zip_ref.extractall("hekate")

        # Delete zip file
        os.remove("hekate.zip")

        # Remove bootloader folder
        shutil.rmtree("hekate/bootloader")

        # Rename hekate bin file to hekate.bin so it can be used with other scripts easily
        shutil.move(f"hekate/hekate_ctcaer_{data['tag_name'].replace('v', '')}.bin", "hekate/hekate.bin")

        print("hekate downloaded successfully")
    except Exception as e:
        print(f"Error downloading hekate: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()