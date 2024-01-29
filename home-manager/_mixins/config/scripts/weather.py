#!/usr/bin/env nix-shell
#!nix-shell -i python -p python3 python310Packages.hjson python310Packages.requests


from ftplib import FTP
import xml.etree.ElementTree as ET
import json
import argparse
import re


def download_xml_from_bom_ftp(args, filename):
    try:
        if args.debug:
            print("[-] Opening connection to BOM")

        # Connect and Switch Directory
        ftp = FTP("ftp.bom.gov.au")
        ftp.login()
        ftp.cwd("anon/gen/fwo")

        if args.debug:
            print("[-] Starting download of latest observations")

        # Retrieve the file from the FTP server
        xml_content = ""

        def append_data(data):
            nonlocal xml_content
            xml_content += data.decode("utf-8")

        ftp.retrbinary("RETR " + filename, append_data)

        if args.debug:
            print("[+] Latest observations downloaded successfully!")

        return xml_content

    except Exception as e:
        print(f"[!] An error occurred while retrieving XML: {e}")

    finally:
        ftp.quit()


def map_icon_code_to_description(icon_code):
    icon_mapping = {
        '1': '☀️',  # Sunny
        '2': '🌙',  # Clear (Night)
        '3': '🌤️',  # Mostly sunny/partly cloudy
        '4': '☁️',  # Cloudy
        '6': '🌫️',  # Hazy
        '8': '🌧️',  # Light rain
        '9': '💨',  # Windy
        '10': '🌫️',  # Fog
        '11': '🌧️',  # Shower
        '12': '🌧️',  # Rain
        '13': '🌬️',  # Dusty
        '14': '❄️',  # Frost
        '15': '❄️',  # Snow
        '16': '⛈️',  # Storm
        '17': '🌧️',  # Light shower
        '18': '🌧️',  # Heavy shower
        '19': '🌀',  # Tropical Cyclone
    }

    return icon_mapping.get(icon_code, "Unknown icon")


def extract_forecast(args, xml_content):
    if args.debug:
        print("[-] Starting extraction of latest observation data")

    root = ET.fromstring(xml_content)

    for forecast_period in root.findall(".//forecast-period"):
        max_temp_element = forecast_period.find(
            './/element[@type="air_temperature_maximum"]'
        )
        icon_code_element = forecast_period.find(
            './/element[@type="forecast_icon_code"]'
        )
        precis_element = forecast_period.find('.//text[@type="precis"]')

        if all(
            [
                max_temp_element is not None,
                icon_code_element is not None,
                precis_element is not None,
            ]
        ):
            icon = map_icon_code_to_description(icon_code_element.text)

            if args.debug:
                print("[+] Successfully extracted Temp, Precis and Icon Code")

            return {
                "temperature": max_temp_element.text,
                "icon": icon,
                "precis": precis_element.text.rstrip("."),
            }


def print_waybar_json(args, forecast):
    if args.debug:
        print("[-] Converting observation data to waybar json")

    waybar_json = {
        "text": f"{forecast['icon']} {forecast['temperature']}°C {forecast['precis']}"
    }

    if args.debug:
        print("[+] Printing json dump")

    print(json.dumps(waybar_json))


def print_forecast(forecast):
    print("\n\n<---Forecast--->\n")
    print(f"Temperature: {forecast['temperature']}°C")
    print(f"Current Conditions: {forecast['precis']}")
    print(f"Icon: {forecast['icon']}")


def check_product_id_pattern(product_id):
    pattern = re.compile(r"^IDV\d{5}$")
    return bool(pattern.match(product_id))


def main():
    # Argument setup and management
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Get weather forecast from BOM and format it",
    )

    parser.add_argument("-d", "--debug", action="store_true", help="print debug info")

    parser.add_argument(
        "output",
        nargs="?",
        choices=["terminal", "waybar"],
        help="Format for the output, use terminal for testing",
    )

    parser.add_argument(
        "product_id",
        nargs="?",
        help="The product ID you want a forecast for, checkout the README for help",
    )

    args = parser.parse_args()

    if not args.output:
        print("Error: An output type is required, options: (terminal, waybar)")
        print("Use --help for help")
        exit()

    if not args.product_id:
        print("Error: A Product ID is required to get relevant weather data")
        print("Use --help for help")
        exit()

    if not check_product_id_pattern(args.product_id):
        print(
            "Error: Product ID's must match this format: 'IDVxxxxx' where 'x' is a number"
        )
        print("Use --help for help")
        exit()

    # Weather script
    ftp_filename = args.product_id + ".xml"

    if args.debug:
        print("[~] Debug mode active")

    if args.output == "terminal":
        xml_content = download_xml_from_bom_ftp(args, ftp_filename)

        if xml_content:
            forecast = extract_forecast(args, xml_content)
            print_forecast(forecast)
        else:
            print("[!] Failed to download XML file, check the product ID")

    if args.output == "waybar":
        xml_content = download_xml_from_bom_ftp(args, ftp_filename)

        if xml_content:
            forecast = extract_forecast(args, xml_content)
            print_waybar_json(args, forecast)
        else:
            print("[!] Failed to download XML file, check the product ID")


if __name__ == "__main__":
    main()
