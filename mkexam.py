#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import logging

import libxml2
import libxslt


def f_random(ctx):
    return 0
#    return str(random.randint(1,1000))


def f_exists(ctx, fname):
    return os.path.exists(fname)


libxslt.registerExtModuleFunction(
    "random", "http://arco.esi.uclm.es/commodity", f_random)
libxslt.registerExtModuleFunction(
    "file-exists", "http://arco.esi.uclm.es/commodity", f_exists)


ROOT = os.path.dirname(__file__)
print "graf dir:", ROOT


#generar en XML el examen solicitado para el alumno peticionario
def generate_exam(examFname, sate_info, exam_part, print_answers):

    # FIXME: comprobar que existen estos campos
    user = sate_info['sate:user']
    password = sate_info['sate:pass']
#    course = sate_info['sate:course']
#    exam = sate_info['sate:exam']

    styledoc = libxml2.parseFile(os.path.join(ROOT, 'xsl', 'exam_gen.xsl'))
    style = libxslt.parseStylesheetDoc(styledoc)

    params = {}
    params['rootdir'] = '"' + os.getcwd() + '/"'
    params['setuser'] = '"' + user + '"'
    params['setpass'] = '"' + password + '"'
#    params['setcourse'] = '"' + course + '"'
#    params['setexam'] = '"' + exam + '"'
    params['part'] = '"%d"' % exam_part

    if print_answers:
        params['print_answers'] = '"1"'

    try:
        doc = libxml2.parseFile(examFname)
    except libxml2.parserError, e:
        logging.error("ERROR: Al parsear el fichero '%s'" % e)
#        os.system('rxp -xs ' + path)
        sys.exit(2)

    result = style.applyStylesheet(doc, params)
    xmldoc = style.saveResultToString(result)

#    print xmldoc

    style.freeStylesheet()
    doc.freeDoc()
    result.freeDoc()

    #FIXME: comprobar que la transformación fue correcta y generó el
    #fichero 'target'

    return xmldoc


def generate_latex_view(cad):

    styledoc = libxml2.parseFile(os.path.join(ROOT, 'xsl', 'latex_view.xsl'))
    style = libxslt.parseStylesheetDoc(styledoc)

    doc = libxml2.parseMemory(cad, len(cad))
    xmldoc = style.applyStylesheet(doc, {})

    retval = style.saveResultToString(xmldoc)

    style.freeStylesheet()
    doc.freeDoc()
    xmldoc.freeDoc()

    return retval


# FIXME: rehacer con lxml
def get_parts(fname):

    retval = []
    fd = open(fname)
    for line in fd:
        if '<part' in line:
            try:
                n = line.index('name') + 6
                title = line[n:]
                n = title.index('"')
                title = title[:n].replace(' ', '_')
                retval.append(title)
            except ValueError:
                retval.append('')
    fd.close()
    return retval


def string_before(cad, sub):
    n = cad.find(sub)
    if n == -1:
        return cad
    return cad[:n]


def main():
    print_answers = False

    if len(sys.argv) == 1:
        print 'Sintaxis: mkexam <clean | [--answers] file.exam.xml>'
        sys.exit(1)

    if sys.argv[1] == 'clean':
        os.system('rm *.tex *.aux *.log *.pdf *.out')
        return 1

    if sys.argv[1] == '--answers':
        print_answers = True
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

    tex = []
    for p, part in enumerate(partes):
        xml_exam = generate_exam(examFname, info, p + 1, print_answers)
        latex_exam = generate_latex_view(xml_exam)

        fname = base
        if part:
            fname += '-%s' % part
        fname += '.tex'

        tex.append(fname)
        print 'rendering %s (%s)...' % (examFname, part)
        fd = open(fname, 'wt')
        fd.write(latex_exam)
        fd.close()

    for fname in tex:
        retval = os.system('MAIN=%s make -f /usr/include/arco/latex.mk' % fname)
#        retval = os.system('rubber --pdf "%s" >> /dev/null' % fname)
        if retval:
            print ' [== ERROR ==] '

    print 'done'


main()
