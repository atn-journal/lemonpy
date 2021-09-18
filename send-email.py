#!/usr/bin/env python3

# Adapted from https://realpython.com/python-send-email/

import smtplib, ssl
from sys import argv

port = 465  # For SSL
smtp_server = "smtp.gmail.com"
sender_email = "@gmail.com"  # Enter your address
receiver_email = "@gmail.com"  # Enter receiver address
password = ""

if len(argv) == 3:
    subject = argv[1]
    body = argv[2]
elif len(argv) == 2:
    subject = argv[1]
    body = ":)"
else:
    subject = "Hola"
    body = ":)"

message = f"""\
Subject: {subject}

{body}"""

context = ssl.create_default_context()
with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)
