#!/usr/bin/python

import libxml2
import libxslt
import cgi
import os
import sys
import string
import urllib
from types import *


def generate_html_exam_view(xmldoc, readonly):

    #outfile = os.path.splitext(file)[0] + '.html'
    
    styledoc = libxml2.parseFile('xsl/exam_html_view-gen.xsl')
    style = libxslt.parseStylesheetDoc(styledoc)

    params = {}
    if readonly: params['readonly'] = '"1"'


    doc = libxml2.parseDoc(xmldoc)
    result = style.applyStylesheet(doc, params)
    
    htmldoc = style.saveResultToString(result)
    style.freeStylesheet()
    doc.freeDoc()
    result.freeDoc()

    return htmldoc

f = open(sys.argv[1])
content = f.read()
f.close()
print generate_html_exam_view(content, None)
