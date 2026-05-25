import re

RULES = [
    ('greeting', re.compile(r"(hi|hello|hey|salut|salam)", re.I)),
    ('goodbye', re.compile(r"(bye|goodbye|au\s+revoir|beslema)", re.I)),
    ('ask_hours', re.compile(r"(hours|opening|open|close|time|schedule)", re.I)),
    ('ask_contact', re.compile(r"(contact|email|phone|tel|number)", re.I)),
    ('ask_location', re.compile(r"(where|location|address|map)", re.I)),
]
