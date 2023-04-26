#!/bin/sh
set -eu

# ----------------------------------------
# VARIABLES
# ----------------------------------------

COMMAND=''
#TYPE=''
#INBNAME=''
#OUTBNAME=''

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

show_usage_and_exit() {
	>&2 cat <<- EOF
	Manage TLS certificates.
	
	Usage:
	
	    certificate.sh [-C | -R] [-t <type>] [-i <infile>] [-o <outfile>]
	
	Arguments:

	    -C    Creates a new certificate
	    -R    Read existing certificate
	    -t <type>       Type of the certificate to be generated (R: root, F: final)
	    -i <infile>     Name of the input certificate file
	    -o <outfile>    Name of the output certificate file
	
	Examples:
	
	    # Generate root CA certificate and private key (my_root_ca.key and my_root_ca.crt)
	    certificate.sh -C -t R -o my_root_ca.crt
	
	    # Generate final TLS certificate and private key (my_domain.key and my_domain.crt)
	    certificate.sh -C -t F -i my_root_ca.crt -o my_domain.crt
	
	    # Print the content of a certificate
	    certificate.sh -R -i my_domain.crt
	
	Notes:
	    
	    * OpenSSL needs to be installed in order to use this script.
	    * The generated certificate will always have the ".crt" extension.
	EOF
	exit 1
}

# Generates a private key and self signed certificate to be used as root CA.
#
# args:
# - file_name: The basename of the output file. It will generate a {file_name}.key and {file_name}.crt.
generate_root_certificate() {
	# Use OpenSSL to generate a key and self signed certificate
	local file_name="${1%.*}"
	openssl req -x509 -newkey rsa:2048 -sha256 -days 6400 \
		-keyout "${file_name}.key" -out "${file_name}.crt"
}

# Generates a private key and certificate, signed by a CA, to be used for TLS.
#
# args:
# - ca_file: The basename of the CA certificate file (without extension).
# - file_name: The basename of the output file. It will generate a {file_name}.key and {file_name}.crt.
generate_final_certificate() {
	# Use OpenSSL to generate the key and csr
	local ca_file="${1%.*}"
	local file_name="${2%.*}"
	mkdir -p demoCA/newcerts
	touch demoCA/index.txt
	openssl req -newkey rsa:2048 -sha256 \
		-keyout "${file_name}.key" -out "${file_name}.csr"
	# Use OpenSSL to sign the csr using the CA certificate
	openssl ca -days 3600 -rand_serial -notext -policy policy_anything -outdir /tmp \
		-keyfile "${ca_file}.key" -cert "${ca_file}.crt" \
		-in "${file_name}.csr" -out "./${file_name}.crt"
}

print_certificate() {
	local file_name="$1"
	openssl x509 -text -noout -in "${file_name}"
}

# ----------------------------------------
# SCRIPT
# ----------------------------------------

# Read arguments
while getopts 'CRt:i:o:s:' opt; do
	case $opt in
		C) COMMAND=CREATE ;;
		R) COMMAND=READ ;;
		t) TYPE="${OPTARG}" ;;
		i) INBNAME="${OPTARG}" ;;
		o) OUTBNAME="${OPTARG}" ;;
		*) show_usage_and_exit ;;
	esac
done

# Execute command
case $COMMAND in
	CREATE)
		case $TYPE in
			R) generate_root_certificate "${OUTBNAME}" ;;
			F) generate_final_certificate "${INBNAME}" "${OUTBNAME}" ;;
			*) show_usage_and_exit ;;
		esac
		;;
	READ)
		print_certificate "${INBNAME}"
		;;
	*)
		show_usage_and_exit
		;;
esac

