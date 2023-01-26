#!/usr/bin/env python3
# adapted from code by @stephenhouser on github
# https://gist.github.com/stephenhouser/c5e2b921c3770ed47eb3b75efbc94799
import http.cookiejar
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

import requests
from bs4 import BeautifulSoup


def get_soup(url,header):
    return BeautifulSoup(urllib.request.urlopen(
        urllib.request.Request(url,headers=header)),
        'html.parser')

def bing_image_search(query):
    query= query.split()
    query='+'.join(query)
    url="http://www.bing.com/images/search?q=" + query + "&FORM=HDRSC2"

    #add the directory for your image here
    DIR="Pictures"
    header={'User-Agent':"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36"}
    soup = get_soup(url,header)
    image_result_raw = soup.find("a",{"class":"iusc"})

    m = json.loads(image_result_raw["m"])
    murl, turl = m["murl"],m["turl"]# mobile image, desktop image

    image_name = urllib.parse.urlsplit(murl).path.split("/")[-1]
    return (image_name, murl, turl)


def blank_to_underbar(s):
    s = re.sub(r"\s+", '_', s)
    return s

def download_image(url, filename):
    filename = blank_to_underbar(filename)
    urllib.request.urlretrieve(url, filename)
    print(filename)

if __name__ == "__main__":
    query = sys.argv[1]
    image_name, murl, turl = bing_image_search(query)
    download_image(turl, image_name)
