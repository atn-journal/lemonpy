#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Adapted from https://realpython.com/python-send-email/ and https://stackoverflow.com/a/54853576

import smtplib
import ssl
from sys import argv
from email.message import EmailMessage

port = 587  # For starttls
smtp_server = "smtp.gmail.com"
sender_email = "@gmail.com"  # Enter your address
receiver_email = "@gmail.com"  # Enter receiver address
password = ""

if len(argv) == 3:
    subject = argv[1]
    msg = argv[2]
elif len(argv) == 2:
    subject = argv[1]
    msg = ":)"
else:
    subject = "Hola"
    msg = ":)"

em = EmailMessage()
em.set_content(msg)
em['To'] = receiver_email
em['From'] = sender_email
em['Subject'] = subject

context = ssl.create_default_context()
with smtplib.SMTP(smtp_server, port) as server:
    server.starttls(context=context)
    server.login(sender_email, password)
    server.send_message(em)
