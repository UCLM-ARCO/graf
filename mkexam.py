#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

import os, sys
import libxml2, libxslt
import string
import urllib
from types import *


ROOT='/home/david/repos/graf'

#rootdir = os.path.join(os.getcwd(),'db')

#generar en XML el examen solicitado para el alumno peticionario
def generate_exam(examFname, sate_info, exam_part, solution):

    # FIXME: comprobar que existen estos campos
    user = sate_info['sate:user']
    password = sate_info['sate:pass']
#    course = sate_info['sate:course']
#    exam = sate_info['sate:exam']

    styledoc = libxml2.parseFile(os.path.join(ROOT, 'xsl', 'exam_gen.xsl'))
    style = libxslt.parseStylesheetDoc(styledoc)

    params = {}
    params['rootdir'] = '"' + os.getcwd() + '/"'
    #params['rootdir'] = '"' + '/home/dvilla/proy/graf/db/ARedes/' + '"'
    params['setuser'] = '"' + user + '"'
    params['setpass'] = '"' + password + '"'
#    params['setcourse'] = '"' + course + '"'
#    params['setexam'] = '"' + exam + '"'
    params['part'] = '"%d"' % exam_part

    if solution: params['solution'] = '"1"'


    try:
        doc = libxml2.parseFile(examFname)
    except libxml2.parserError, e:
        print >>sys.stderr, "ERROR: Al parsear el fichero '%s'" % (path)
        os.system('rxp -xs ' + path)
        sys.exit(2)

    result = style.applyStylesheet(doc, params)
    #dir(style)

    xmldoc = style.saveResultToString(result)

    print xmldoc

    style.freeStylesheet()
    doc.freeDoc()
    result.freeDoc()

    #FIXME: comprobar que la transformación fue correcta y generó el
    #fichero 'target'

    return xmldoc


def generate_latex_view(cad):

    styledoc = libxml2.parseFile(os.path.join(ROOT, 'xsl', 'latex_view.xsl'))
    style = libxslt.parseStylesheetDoc(styledoc)

    doc =  libxml2.parseMemory(cad, len(cad))
    xmldoc = style.applyStylesheet(doc, {})

    retval = style.saveResultToString(xmldoc)

    style.freeStylesheet()
    doc.freeDoc()
    xmldoc.freeDoc()

    return retval


def get_parts(fname):

    retval = []
    fd = open(fname)
    for line in fd:
        if line.count('<part'):
            n = line.index('name')+6
            title = line[n:]
            n = title.index('"')
            title = title[:n].replace(' ', '_')
            retval.append(title)
    fd.close()
    return retval


def string_before(cad, sub):
    n = cad.find(sub)
    if n == -1:
        return cad
    return cad[:n]


def main():


    solution = False

    if len(sys.argv) == 1:
        print 'Sintaxis: mkexam <clean | [-sol] file.exam.xml>'
        sys.exit(1)

    if sys.argv[1] == 'clean':
        os.system('rm *.ltx *.aux *.log *.pdf')
        return 1

    if sys.argv[1] == '-sol':
        solution = True
        args = sys.argv[2:]
    else:
        args = sys.argv[1:]

    examFname = args[0]


    info = {}
    info['sate:user'] = 'alumno'
    info['sate:pass'] = 'pass'
#    info['sate:course'] = asignatura
#    info['sate:exam'] = examen_id

    #examFname = os.path.join(rootdir, asignatura, 'exam', examen_id + '.xml')


    if not os.path.exists(examFname):
        print >>sys.stderr, "ERROR: No existe el fichero '%s'" % examFname
        return 1


    partes = get_parts(examFname)

    base = string_before(examFname, '.')

    #os.environ['TEXMFOUTPUT'] = os.path.join(os.getcwd(), 'output')

    ltx = []
    for p in range(len(partes)):
        xml_exam = generate_exam(examFname, info, p+1, solution)
        latex_exam = generate_latex_view(xml_exam)

        fname = "%s-%s.ltx" % (base, partes[p])
        ltx.append(fname)
        print 'Generating...', fname
        fd = open(fname, 'wt')
        fd.write(latex_exam)
        fd.close()


    print 'compiling docs...'
    for fname in ltx:
        print 'Compiling...', fname,
        retval = os.system('pdflatex --interaction=batchmode "%s" >> /dev/null' % fname)
        if retval:
            print ' [== ERROR ==] '
        else:
            os.system('pdflatex --interaction=batchmode "%s" >> /dev/null' % fname)
            print

    print 'FIN'


main()


