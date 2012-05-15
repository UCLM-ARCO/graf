#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import logging
import argparse

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
    parser = argparse.ArgumentParser()
    parser.add_argument('--answers', action='store_true',
                        help='Generate solved exam')
    parser.add_argument('--clean', action='store_true',
                        help='remove generated files')
    parser.add_argument('exam',
                        help='your-file.exam.xml')

    config = parser.parse_args()

    if config.clean:
        logging.info("Cleaning previously generated files")
        os.system('rm -v *.tex *.aux *.log *.pdf *.out')

    if not os.path.exists(config.exam):
        logging.error("ERROR: No existe el fichero '%s'" % config.exam)
        return 1

    process_parts(config.exam, config.answers)


def process_parts(exam, answers):
    info = {}
    info['sate:user'] = 'alumno'
    info['sate:pass'] = 'pass'
#    info['sate:course'] = asignatura
#    info['sate:exam'] = examen_id

    base = string_before(exam, '.')
    exam_parts = get_parts(exam)

    tex_filenames = []
    for p, part in enumerate(exam_parts):
        xml_exam = generate_exam(exam, info, p + 1, answers)
        latex_exam = generate_latex_view(xml_exam)

        fname = base
        if part:
            fname += '-%s' % part
        fname += '.tex'

        tex_filenames.append(fname)

        logging.info('rendering %s (%s)...', exam, part)
        with file(fname, 'wt') as fd:
            fd.write(latex_exam)

    for fname in tex_filenames:
        retval = os.system('MAIN=%s make -f /usr/include/arco/latex.mk' % fname)
        if retval:
            print ' [== ERROR ==] '

    print 'done'


main()
