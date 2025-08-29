import pandas as pd
import gzip
import json
import base64
from dataclasses import dataclass
from typing import Optional, Dict, Any
import io
import sys
import argparse
import os
import glob

@dataclass
class BetRowData:
    """Python equivalent of the Kotlin/Java data class"""
    state: Optional[Dict[str, Any]] = None
    result: Optional[Dict[str, Any]] = None
    payout_request: Optional[Dict[str, Any]] = None
    payout_response: Optional[Dict[str, Any]] = None

def find_latest_result_file() -> str:
    """
    Find the latest modified file containing 'result' in its name
    """
    # Search for files containing 'result' in current directory
    pattern = "*result*.csv"
    files = glob.glob(pattern)

    if not files:
        # Also try without .csv extension in case it's different
        pattern = "*result*"
        files = glob.glob(pattern)
        # Filter for likely CSV files
        files = [f for f in files if f.endswith(('.csv', '.txt', '.tsv'))]

    if not files:
        raise FileNotFoundError("No files found containing 'result' in the filename")

    # Sort by modification time (newest first)
    files.sort(key=os.path.getmtime, reverse=True)

    latest_file = files[0]
    print(f"Found latest result file: {latest_file}")
    print(f"Modified: {os.path.getmtime(latest_file)}")

    return latest_file

def decompress_gzip_data(compressed_data: str) -> str:
    """
    Decompress GZIP data from string format.
    Handles both base64 encoded and raw binary data.
    """
    try:
        # Try to decode as base64 first
        try:
            binary_data = base64.b64decode(compressed_data)
        except:
            # If base64 fails, assume it's already binary
            binary_data = compressed_data.encode('latin-1') if isinstance(compressed_data, str) else compressed_data

        # Decompress the data
        decompressed = gzip.decompress(binary_data)
        return decompressed.decode('utf-8')

    except Exception as e:
        print(f"Error decompressing data: {e}")
        return ""

def parse_json_safely(json_string: str) -> Optional[Dict[str, Any]]:
    """
    Safely parse JSON string, return None if parsing fails
    """
    if not json_string or json_string.strip() == "":
        return None

    try:
        return json.loads(json_string)
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        return None

def extract_bet_data_from_json(json_data: Dict[str, Any]) -> BetRowData:
    """
    Extract bet data from the parsed JSON into BetRowData structure
    """
    bet_data = BetRowData()

    # Extract each field if it exists in the JSON
    bet_data.state = json_data.get('state')
    bet_data.result = json_data.get('result')
    bet_data.payout_request = json_data.get('payoutRequest')
    bet_data.payout_response = json_data.get('payoutResponse')

    return bet_data

def process_csv_with_gzip_data(input_csv_path: str, output_csv_path: str, key_column: str = 'key_data'):
    """
    Main function to process CSV file with GZIP compressed data

    Args:
        input_csv_path: Path to input CSV file
        output_csv_path: Path to output CSV file
        key_column: Name of the column containing GZIP compressed data
    """
    try:
        # Read the CSV file
        print(f"Reading CSV file: {input_csv_path}")
        df = pd.read_csv(input_csv_path)

        if key_column not in df.columns:
            raise ValueError(f"Column '{key_column}' not found in CSV. Available columns: {list(df.columns)}")

        # Initialize new columns
        df['state'] = None
        df['result'] = None
        df['payout_request'] = None
        df['payout_response'] = None

        # Process each row
        for index, row in df.iterrows():
            try:
                compressed_data = row[key_column]

                if pd.isna(compressed_data) or compressed_data == "":
                    print(f"Row {index}: No data to process")
                    continue

                # Decompress the data
                decompressed_json = decompress_gzip_data(compressed_data)

                if not decompressed_json:
                    print(f"Row {index}: Failed to decompress data")
                    continue

                # Parse JSON
                json_data = parse_json_safely(decompressed_json)

                if json_data is None:
                    print(f"Row {index}: Failed to parse JSON")
                    continue

                # Extract bet data
                bet_data = extract_bet_data_from_json(json_data)

                # Convert to JSON strings for CSV storage (or keep as dict if preferred)
                df.at[index, 'state'] = json.dumps(bet_data.state) if bet_data.state else None
                df.at[index, 'result'] = json.dumps(bet_data.result) if bet_data.result else None
                df.at[index, 'payout_request'] = json.dumps(bet_data.payout_request) if bet_data.payout_request else None
                df.at[index, 'payout_response'] = json.dumps(bet_data.payout_response) if bet_data.payout_response else None

                # Clear the original compressed data after successful processing
                df.at[index, key_column] = None

                print(f"Row {index}: Successfully processed")

            except Exception as e:
                print(f"Row {index}: Error processing row - {e}")
                continue

        # Save the processed data
        print(f"Saving processed data to: {output_csv_path}")
        df.to_csv(output_csv_path, index=False)
        print("Processing completed successfully!")

        # Print summary
        non_null_counts = {
            'state': df['state'].notna().sum(),
            'result': df['result'].notna().sum(),
            'payout_request': df['payout_request'].notna().sum(),
            'payout_response': df['payout_response'].notna().sum()
        }

        print("\nSummary:")
        print(f"Total rows processed: {len(df)}")
        for field, count in non_null_counts.items():
            print(f"Rows with {field} data: {count}")

    except Exception as e:
        print(f"Error processing CSV file: {e}")
        raise

def process_single_compressed_data(compressed_data: str) -> BetRowData:
    """
    Helper function to process a single compressed data entry
    Useful for testing or processing individual entries
    """
    decompressed_json = decompress_gzip_data(compressed_data)
    json_data = parse_json_safely(decompressed_json)

    if json_data:
        return extract_bet_data_from_json(json_data)
    else:
        return BetRowData()

def main():
    """Main function with command line argument parsing"""
    parser = argparse.ArgumentParser(description='Process CSV file with GZIP compressed JSON data')
    parser.add_argument('-o', '--output', help='Path to output CSV file (default: adds _processed to input filename)')
    parser.add_argument('-c', '--column', default='data', help='Name of column containing GZIP data (default: data)')

    args = parser.parse_args()

    # Automatically find the latest result file
    try:
        input_file = find_latest_result_file()
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)

    # Set output file name if not provided
    if args.output:
        output_file = args.output
    else:
        # Generate output filename by adding _processed before file extension
        if '.' in input_file:
            name_part, ext = input_file.rsplit('.', 1)
            output_file = f"{name_part}_processed.{ext}"
        else:
            output_file = f"{input_file}_processed.csv"

    print(f"Input file: {input_file}")
    print(f"Output file: {output_file}")
    print(f"Key data column: {args.column}")
    print("-" * 50)

    # Process the CSV file
    try:
        process_csv_with_gzip_data(input_file, output_file, args.column)
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found. Please check the file path.")
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

# Example usage
if __name__ == "__main__":
    main()