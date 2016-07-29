import argparse
import sys
import os
from tempfile import mkdtemp
from lxml import etree
import subprocess
from StringIO import StringIO
import zipfile
import time
import shutil
import zipfile
from qrcode import *

import utils
import collection2epcollxml
import collection2epxhtml

EPXHTML2PDF = utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, 'collection2pdf.xsl')
COLLECTION_HTML = 'collection.html'
QR_CODE_XPATH = etree.XPath('//x:div[@class=\'qr-code\' or @class=\'qr-code-gallery\']/x:img', namespaces=utils.NAMESPACES)
PDF_JS = 'css/pdf.js'

CONVERT_BIN = 'convert'

def _create_temp_directories(temp_dir):
    dirs = {}
    dirs['root'] = mkdtemp(suffix='-ep2pdf')
    if temp_dir:
        shutil.rmtree(dirs['root'], ignore_errors=True)
        dirs['root'] = temp_dir

    dirs['womi'] = os.path.join(dirs['root'], 'womi')
    if temp_dir:
        dirs['womi'] = os.path.join(temp_dir, 'womi')
    if not os.path.exists(dirs['womi']):
        os.makedirs(dirs['womi'])

    return dirs

def _copy_womis(womi_dir, dirs):
    for filename in os.listdir(womi_dir):
        if(filename.find('-pdf') != -1):
            absname = os.path.abspath(os.path.join(womi_dir, filename))
            arcname = os.path.join(dirs['womi'], filename)
            shutil.copyfile(absname, arcname)

def _check_arguments(args):
    if not os.path.exists(args.input_dir) or not os.path.isfile(os.path.join(args.input_dir, utils.COLLECTION_XML)):
        print >> sys.stderr, "[PY_ERR][PY_PDF] -i input_dir must be directory containing collection.xml file in={inp}".format(inp=args.input_dir) 
        exit(1)
    
    if not os.path.exists(args.womi_dir):
        print >> sys.stderr, "[PY_ERR][PY_PDF] -w womi_dir: \"%s\" does not exist" % args.womi_dir
        exit(1)

    if args.print_styles is not None:
        css = args.print_styles.split(':')
        for c in css:
            if not os.path.isfile(c):
                print >> sys.stderr, "[PY_ERR][PY_PDF] \"%s\" must be css file" % c
                exit(1)

def _check_exists_of_output_dir(output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

def call_prince(prince_path, result_dir, style_file, output_file):
    cmd = [prince_path, result_dir + '/' + COLLECTION_HTML,
        '-s ' + style_file,
        '-o ' + output_file,
        '--script=' + PDF_JS]
    proc = subprocess.Popen(cmd)
    proc.communicate()
    exit_code = proc.wait()
    if exit_code > 0:
        print "[PY_ERR] Error in PrinceXML [exit code: %s]." % str(exit_code)
        return -1;
    return None;

def transform_collection(input_dir_with_epxhtml, result_dir, css, womi_dir):
    print "[PY_PDF] Transform collection"
    input_dir = os.path.abspath(input_dir_with_epxhtml)
    result_dir = os.path.abspath(result_dir)
    str_cmd = ['java', '-jar',
               utils.SAXON_JAR,
               '-s:' + input_dir + "/collection.xml",
               '-xsl:' + EPXHTML2PDF,
               'resultDir=' + result_dir.replace('\\', '/'),
               'epxhtml_path=' + input_dir,
               'color_stylesheet=' + css,
               'womiLocalPath=' + os.path.abspath(womi_dir),
               'outputFormat=' + 'pdf'
    ]
    proc = subprocess.Popen(str_cmd)
    proc.communicate()
    exit_code = proc.wait()
    if exit_code > 0:
        print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
        return -1

def generate_qr_code(result_dir):
    collection_html = etree.parse(os.path.join(result_dir,  COLLECTION_HTML))
    qr_divs = QR_CODE_XPATH(collection_html)
    for qr_div in qr_divs:
        file = qr_div.get('src')
        href = qr_div.get('data-href')
        qr = QRCode(version=1, error_correction=ERROR_CORRECT_L ,box_size=3, border=1,)
        qr.add_data(href)
        qr.make()
        im = qr.make_image()
        im.save(os.path.join(result_dir, file))

def transform_to_pdf(args, variant):

    _check_exists_of_output_dir(os.path.join(args.output_dir, variant))
    
    dirs = _create_temp_directories(args.temp_dir)
    _copy_womis(args.womi_dir, dirs)
    result_dir = dirs['root']
    
    input_dir_path = args.input_dir

    temp_dir_after_variants = mkdtemp(suffix='-coll2pdf_2')
    if args.mode == 'o':
        status = transform_collection(input_dir_path, result_dir, args.print_styles, args.womi_dir)
    elif args.mode == 'x':
        collection2epxhtml.transform_to_epxhtml(input_dir_path, args.temp_dir)   
        status = transform_collection(args.temp_dir, result_dir, args.print_styles, args.womi_dir)
    else:
        collection2epcollxml.transform_collxml_to_epcollxml(input_dir_path, temp_dir_after_variants, args.womi_dir)
        collection2epxhtml.transform_to_epxhtml(temp_dir_after_variants, args.temp_dir)
        status = transform_collection(args.temp_dir, result_dir, args.print_styles, args.womi_dir)

    if status == -1:
        shutil.rmtree(temp_dir_after_variants, ignore_errors=True)
        shutil.rmtree(dirs['root'], ignore_errors=True)
        shutil.rmtree(args.temp_dir, ignore_errors=True)
        return status

    output_file = os.path.join(args.output_dir, variant) + '/' + variant + '.pdf'

    print "[PY_PDF] Generating QRCODE"
    generate_qr_code(result_dir)

    print "[PY_PDF] Calling PrinceXML - converting to " + output_file
    status = call_prince(args.prince_path, result_dir, args.print_styles, output_file)

    shutil.rmtree(temp_dir_after_variants, ignore_errors=True)
    shutil.rmtree(dirs['root'], ignore_errors=True)
    shutil.rmtree(args.temp_dir, ignore_errors=True)

    return status

def main():
    parser = argparse.ArgumentParser(
        description='[PY_PDF] Transforms collxml collection with epxml modules to PDF',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Path to directory with input collxml file', required=True)
    parser.add_argument('-w', dest='womi_dir', help='Path to womi directory', required=True)
    parser.add_argument('-s', dest='print_styles', help='Print styles to use (name of CSS files in css dir)', required=True)
    
    parser.add_argument('-o', dest='output_dir', help='Path to result directory', default=utils.DEFAULT_RESULT_DIRECTORY)
    parser.add_argument('-pp', dest='prince_path', help='Path to PrinceXML binary', default='prince')
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2pdf'))
    parser.add_argument('-m', dest='mode', help='o - only pdf, x - xhtml + pdf, c - collxml + epxhtml + pdf', default='o')
    parser.add_argument('-r', dest='recipient', help='Recipient of current content of modules (eq. student-canon)', default=utils.DEFAULT_RECIPIENT_CONTENT)

    print "[PY_PDF] Transforming collxml2pdf"
    args = parser.parse_args()
    if(args.mode == 'a'):
        print >> sys.stderr, "[PY_ERR][PY_PDF] Bad parameter 'mode' value"
        sys.exit(1)

    args.input_dir = os.path.join(args.input_dir, args.recipient)
    
    _check_arguments(args)
    status = transform_to_pdf(args, args.recipient)
    shutil.rmtree(args.temp_dir, ignore_errors=True)
    if status == -1:
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_PDF] Unsuccessful exit."
        sys.exit(1)

    print "[PY_PDF] End of transforms collxml2pdf."

if __name__ == '__main__':
    sys.exit(main())

