import sys

import requests
from bs4 import BeautifulSoup

url = sys.argv[1]
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36'}
response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.text, 'html.parser')
abstract = soup.find('meta', attrs={'name':'citation_abstract'})['content']
print(abstract)
