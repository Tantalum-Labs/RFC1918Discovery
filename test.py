import os

AWS_ACCESS_KEY_ID="AKIAEXAMPLEKEY12345678"
AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

user_input = input("Enter command: ")
os.system("echo " + user_input)  # 🚨 CodeQL will flag this as command injection

