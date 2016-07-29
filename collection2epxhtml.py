import argparse
import os
import sys
from tempfile import mkdtemp
import subprocess
import shutil
import time

import utils

CNXML_RENDER_XSL = "cnxml_render.xsl"

def process_module(collection_dir, result_dir):
    sys.stdout.flush()
    collection_file = os.path.join(collection_dir, utils.COLLECTION_XML)
    str_cmd = ['java', '-jar',
              utils.SAXON_JAR,
              '-s:' + collection_file,
              '-xsl:' + os.path.join(utils.DEFAULT_XSL_DIRECTORY, CNXML_RENDER_XSL),
              'resultDir=' + result_dir.replace('\\', '/'),
              'path_to_files_epxml_of_modules_in_col=' + os.path.abspath(collection_dir)
    ]
    proc = subprocess.Popen(str_cmd)
    proc.communicate()

    exit_code = proc.wait()
    if exit_code > 0:
        print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
        return -1

    if os.path.exists(os.path.join(result_dir,'err_missing_glossary_ref')):
        print "[PY_ERR] Collection contains missing glossary references."
        return -1

    print "[PY_EPXHTML] Transformation completed"

def transform_to_epxhtml(collection_dir, output_dir):
    print "[PY_EPXHTML] Transforming collection to XHTML"
    status = process_module(collection_dir, output_dir)
    if status == -1:
        return -1
    if not os.path.exists(os.path.join(output_dir, utils.COLLECTION_XML)):
        shutil.copy(os.path.join(collection_dir, utils.COLLECTION_XML), os.path.join(output_dir, utils.COLLECTION_XML))
    if os.path.exists(os.path.join(collection_dir, "mappingGlossary.xml")) and not os.path.exists(os.path.join(output_dir, "mappingGlossary.xml")):
        shutil.copy(os.path.join(collection_dir, "mappingGlossary.xml"), os.path.join(output_dir, "mappingGlossary.xml"))


def main():
    parser = argparse.ArgumentParser(
        description='[PY_EPXHTML] Transforms collxml collection with epxml modules to xhtml files. ',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Directory of the collection', required=True)
    parser.add_argument('-o', dest='output_dir', help='Target folder to store transformed collection', required=True)
    parser.add_argument('-w', dest='womi_dir', help='Path to womi directory', default=utils.DEFAULT_WOMI_DIRECTORY)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2epxhtml'))
    args = parser.parse_args()

    if os.path.exists(os.path.join(args.output_dir,'err_missing_glossary_ref')):
        os.remove(os.path.join(args.output_dir,'err_missing_glossary_ref'))

    print "[PY_EPXHTML] Transforming epcollxml2epxhtml"
    status = transform_to_epxhtml(args.input_dir, os.path.abspath(args.output_dir))

    shutil.rmtree(args.temp_dir, ignore_errors=True)
    if status == -1:
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_EPXHTML] Unsuccessful exit."
        sys.exit(1)

    print "[PY_EPXHTML] End transforming epcollxml2epxhtml"

if __name__ == '__main__':
    sys.exit(main())
