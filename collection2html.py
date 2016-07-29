import argparse
import sys
import os
import subprocess
import utils
import shutil
import collection2epcollxml
import collection2epxhtml
from tempfile import mkdtemp

EPXHTML2HTML = utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, 'collection2html.xsl')

def _check_arguments(args):
    if not os.path.exists(args.input_dir) or not os.path.isfile(os.path.join(args.input_dir, utils.COLLECTION_XML)):
        print >> sys.stderr, "[PY_ERR][PY_HTML] -i input_dir must be directory containing collection.xml file"
        exit(1)
              
    if not os.path.exists(args.womi_dir):
        print >> sys.stderr, "[PY_ERR][PY_HTML] -w womi_dir: \"%s\" does not exist" % womi_dir
        exit(1)

def _check_exists_of_output_dir(output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

def transform_epxhtml_to_html(input_dir_with_epxhtml, result_dir, womi_dir, variant):
    input_dir = os.path.abspath(input_dir_with_epxhtml)
    result_dir = os.path.abspath(result_dir)
    str_cmd = ['java', '-jar',
               utils.SAXON_JAR,
               '-s:' + input_dir + "/collection.xml",
               '-xsl:' + EPXHTML2HTML,
               'resultDir=' + result_dir.replace('\\', '/'),
               'epxhtml_path=' + input_dir,
	           'womiLocalPath=' + os.path.abspath(womi_dir),
               'outputFormat=' + 'classic', 
               'variant=' + variant 
    ]
    proc = subprocess.Popen(str_cmd)
    proc.communicate()

    exit_code = proc.wait()
    if exit_code > 0:
        print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
        return -1
    
def transform_to_html(args, variant):
    _check_exists_of_output_dir(os.path.join(args.output_dir,variant))
    input_dir_path = args.input_dir
    
    temp_dir_after_variants = mkdtemp(suffix='-coll2html_2')
    
    if args.mode == 'o':
        status = transform_epxhtml_to_html(input_dir_path, args.output_dir, args.womi_dir, variant)
    elif args.mode == 'x':
        collection2epxhtml.transform_to_epxhtml(input_dir_path, args.temp_dir)   
        status = transform_epxhtml_to_html(args.temp_dir, args.output_dir, args.womi_dir, variant)
    else:
        collection2epcollxml.transform_collxml_to_epcollxml(input_dir_path, args.temp_dir, args.womi_dir)
        collection2epxhtml.transform_to_epxhtml(args.temp_dir, temp_dir_after_variants)
        status = transform_epxhtml_to_html(temp_dir_after_variants, args.temp_dir, args.output_dir, args.womi_dir, variant) 

    shutil.rmtree(temp_dir_after_variants, ignore_errors=True)
    return status
		
def process_output_htmls(result_dir):
    print "[HTML] Stripping DOCTYPE declarations from HTML files"
    for root, dirs, files in os.walk(result_dir):
        if root.find('OEBPS') != -1:
            continue

        htmls = [file for file in files if file.endswith(".html")]
        for output_html in htmls:
            strip_doctype(os.path.join(root, output_html))

def strip_doctype(html):
    content = None
    with open(html, 'r') as f:
        first_line = f.readline()
        if not first_line.startswith('<!DOCTYPE'):
            return

        content = f.readlines()

    if content:
        with open(html, 'w') as f:
            f.writelines(content)

def main():
    parser = argparse.ArgumentParser(
        description='[HTML] Transforms CollXML collection with epXHTML modules to HTML',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Path to directory with input collxml file', required=True)
    parser.add_argument('-e', dest='epxml_dir', help='Path to directory with input epxml file')
    parser.add_argument('-w', dest='womi_dir', help='Path to womi directory', required=True)
    
    parser.add_argument('-o', dest='output_dir', help='Path to result directory', default=utils.DEFAULT_RESULT_DIRECTORY)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2html'))
    parser.add_argument('-m', dest='mode', help='o - only html, x - xhtml + html, c or empty - collxml + epxhtml + html', choices=['o', 'x', 'c'])
    parser.add_argument('-r', dest='recipient', help='Recipient of current content of modules (eq. student-canon)', default=utils.DEFAULT_RECIPIENT_CONTENT)

    print "[PY_HTML] Transforming collxml2html"
    args = parser.parse_args()
    if(args.mode == 'a'):
        print >> sys.stderr, "Bad parameter 'mode' value"
        sys.exit(1)
    
    if(args.mode != 'c'):
        args.input_dir = os.path.join(args.input_dir, args.recipient)
    
    _check_arguments(args)
    status = transform_to_html(args, args.recipient)
    if status == -1:
        shutil.rmtree(args.temp_dir, ignore_errors=True)
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_HTML] Unsuccessful exit."
        sys.exit(1)

    process_output_htmls(args.output_dir)

    shutil.rmtree(args.temp_dir, ignore_errors=True)
    print "[PY_HTML] End of transforms collxml2html."

if __name__ == '__main__':
    sys.exit(main())
