import datetime

import ssl

import OpenSSL

import pandas as pd

import subprocess

import nmap

nm = nmap.PortScanner()



nm['127.0.0.1']['tcp'].keys()


nm.scan('127.0.0.1', '21-443')

nm.all_hosts().all_pro

# run a loop to print all the found result about the ports

for host in nm.all_hosts():

  print('Host : %s (%s)' % (host, nm[host].hostname()))

  print('State : %s' % nm[host].state())

  for proto in nm[host].all_protocols():

    print('----------')

    print('Protocol : %s' % proto)



    lport = nm[host][proto].keys()

    print(lport)

    for port in lport:

      print('port : %s\tstate : %s' % (port, nm[host][proto][port]['state']))



#nm['127.0.0.1'].all_tcp()



data = pd.read_excel('C:/Users/Documents/certs/Copy of ValidationListing.xlsx', sheet_name='Sheet1')

data.drop_duplicates()



# cmd = "nmap -Pn --open --defeat-rst-ratelimit google.com"

#

# # returns output as byte string

# returned_output = subprocess.check_output(cmd)



def check():

  hostname = "google.com"

  port = 443



  cert = ssl.get_server_certificate(

    (hostname, port), ssl_version=ssl.PROTOCOL_TLSv1)

  # print(cert)

  x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert)

  # print(x509)

  expiry_date = x509.get_notAfter()



  #print(expiry_date)

  assert expiry_date, "Cert doesn't have an expiry date."



  ssl_date_fmt = r'%Y%m%d%H%M%SZ'

  expires = datetime.datetime.strptime(str(expiry_date)[2:-1], ssl_date_fmt)

  print(expires.strftime('%m/%d/%Y'))

  remaining = (expires - datetime.datetime.utcnow()).days

  print(remaining)

  # print(cert)

  # if remaining <= 60:

  #   print("ALERTING!")

  # else:

  #   print("Not alerting. You have " + str(remaining) + " days")



check()
