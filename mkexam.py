#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import logging
import random

import libxml2
import libxslt

from commodity.os_ import resolve_path
logging.getLogger().setLevel(logging.DEBUG)


random.seed(os.getpid())


def f_random(ctx):
    return str(random.randint(1, 1000))


def f_exists(ctx, fname):
    return os.path.exists(fname)


def f_max_len(ctx, items):
    print("MAX_LEN", items)
    item0 = items[0]
    print(dir(item0))
    print(str(item0))
    return "no"


libxslt.registerExtModuleFunction(
    "random", "http://arco.esi.uclm.es/commodity", f_random)
libxslt.registerExtModuleFunction(
    "file-exists", "http://arco.esi.uclm.es/commodity", f_exists)
libxslt.registerExtModuleFunction(
    "max-len", "http://arco.esi.uclm.es/commodity", f_max_len)


XSL_DIR = resolve_path('xsl',
                       ['/usr/lib/graf', os.path.dirname(os.path.normpath(__file__))])[0]

logging.info("graf xsl dir: %s", XSL_DIR)


# generar en XML el examen solicitado para el alumno peticionario
def generate_exam(exam_fname, exam_part, answers):

    # FIXME: comprobar que existen estos campos
    styledoc = libxml2.parseFile(os.path.join(XSL_DIR, 'exam_gen.xsl'))
    style = libxslt.parseStylesheetDoc(styledoc)

    params = dict(
        rootdir = '"' + os.getcwd() + '/"',
        part    = '"%d"' % exam_part)

    if answers:
        params['answers'] = '"1"'

    try:
        doc = libxml2.parseFile(exam_fname)
    except libxml2.parserError, e:
        logging.error("parsing file '%s'" % e)
        sys.exit(2)

    result = style.applyStylesheet(doc, params)
    xmldoc = style.saveResultToString(result)

    style.freeStylesheet()
    doc.freeDoc()
    result.freeDoc()

    # FIXME: comprobar que la transformación fue correcta y generó el
    # fichero 'target'

    return xmldoc


def generate_latex_view(cad):
    styledoc = libxml2.parseFile(os.path.join(XSL_DIR, 'latex_view.xsl'))
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
    parser.add_argument('-a', '--answers', action='store_true',
                         help='Generate solved exam')
    parser.add_argument('--clean', action='store_true',
                        help='remove generated files')
    parser.add_argument('exam', nargs='?',
                        help='your-file.exam.xml')

    config = parser.parse_args()

    if config.clean:
        logging.info("Cleaning previously generated files")
        os.system('rm -v *.tex *.aux *.log *.pdf *.out *~ 2> /dev/null')

        if not config.exam:
            return 0

    if not config.exam:
        parser.print_help()
        return 1

    if not os.path.exists(config.exam):
        logging.error("ERROR: No existe el fichero '%s'" % config.exam)
        return 1

    process_parts(config.exam, False)
    if config.answers:
        logging.info("Generating solution")
        process_parts(config.exam, True)


LAST_TEX = 'last.tex'

def process_parts(exam, answers):
    base = string_before(exam, '.')
    exam_parts = get_parts(exam)

    tex_filenames = []
    for p, part in enumerate(exam_parts):
        xml_exam = generate_exam(exam, p + 1, answers)
        with file('temp', 'wt') as fd:
            fd.write(xml_exam)

        latex_exam = generate_latex_view(xml_exam)

        fname = base
        if part:
            fname += '-%s' % part
        if answers:
            fname += '.solved'

        fname += '.tex'

        tex_filenames.append(fname)

        if os.path.exists(LAST_TEX):
            os.remove(LAST_TEX)

        os.symlink(fname, LAST_TEX)

        logging.info('rendering %s (%s)...', exam, part)
        with file(fname, 'wt') as fd:
            fd.write(latex_exam)

    for fname in tex_filenames:
        retval = os.system('MAIN=%s make -f /usr/include/arco/latex.mk' % fname)
        if retval:
            print ' [== ERROR ==] '

    logging.info('done')


main()
