#!/usr/bin/env python3
"""
Certbot Certificate Monitor Script
Runs 'certbot certificates' command and extracts Certificate Name and Expiry Date
"""

import subprocess
import re
import sys
from datetime import datetime


# ----------------------------------------------------------------------
def run_certbot_certificates():
    """
    Execute 'certbot certificates' command and return the output
    """
    try:
        result = subprocess.run(
            ['certbot', 'certificates'],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running certbot command: {e}", file=sys.stderr)
        print(f"Return code: {e.returncode}", file=sys.stderr)
        print(f"Error output: {e.stderr}", file=sys.stderr)
        return None
    except FileNotFoundError:
        print("Error: certbot command not found. Please ensure certbot is installed.", file=sys.stderr)
        return None


# ----------------------------------------------------------------------
def parse_certificates(output):
    """
    Parse certbot output and extract certificate names with valid days
    Returns dictionary with Certificate Name as key and valid days as value
    If certificate is invalid, sets value to -1
    """
    dic_certificates = {}
    
    # Split output into lines
    lines = output.strip().split('\n')
    current_cert_name = None
    
    for line in lines:
        line = line.strip()
        
        # Look for Certificate Name
        if line.startswith('Certificate Name:'):
            current_cert_name = line.split(':', 1)[1].strip()
        
        # Look for Expiry Date and extract valid days
        elif line.startswith('Expiry Date:') and current_cert_name:
            expiry_info = line.split(':', 1)[1].strip()
            
            # Extract valid days using regex
            # Look for patterns like "(VALID: 89 days)" or "(INVALID)"
            valid_match = re.search(r'\(VALID:\s*(\d+)\s*days?\)', expiry_info, re.IGNORECASE)
            invalid_match = re.search(r'\(INVALID', expiry_info, re.IGNORECASE)
            
            if valid_match:
                # Extract the number of valid days
                valid_days = int(valid_match.group(1))
                dic_certificates[current_cert_name] = valid_days
            elif invalid_match:
                # Certificate is invalid
                dic_certificates[current_cert_name] = -1
            else:
                # If we can't determine validity, assume invalid
                dic_certificates[current_cert_name] = -1
            
            # Reset current_cert_name for next certificate
            current_cert_name = None
    
    return dic_certificates

# ----------------------------------------------------------------------
def format_output(dic_certificates):
    """
    Format and print the certificate information sorted by valid days (least to most)
    Input: dictionary with certificate names as keys and valid days as values
    """
    if not dic_certificates:
        print("No certificates found.")
        sys.exit(2) 
    
    # Sort dictionary by valid days (least to most, -1 values first)
    sorted_certificates = sorted(dic_certificates.items(), key=lambda x: x[1])
    
    for cert_name, valid_days in sorted_certificates:
        if valid_days == -1:
            print(f"Certificate: {cert_name}, EXPIRED")
            sys.exit(1)
        elif valid_days < 14:
            print(f"Warning: Less than 14 valid days for: {cert_name}")
            sys.exit(3)
        
    print(f"All certificates are valid with more than 30 days.")
    sys.exit(0)

# ----------------------------------------------------------------------
def main():
    """
    Main function to orchestrate the certificate checking process
    """

    # Run certbot command
    output = run_certbot_certificates()
    if output is None:
        sys.exit(1)

    # Parse the output
    certificates = parse_certificates(output)

    # Format and display results
    format_output(certificates)

    # Optional: Return certificates for programmatic use
    return certificates

if __name__ == "__main__":
    main()
    
    
    
    
    
