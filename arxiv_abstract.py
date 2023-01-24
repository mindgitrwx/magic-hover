import sys

import requests
from bs4 import BeautifulSoup

url = sys.argv[1]
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')
abstract = soup.find('meta', attrs={'name':'citation_abstract'})['content']
print(abstract)
