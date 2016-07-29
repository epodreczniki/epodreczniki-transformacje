import argparse
import os
import sys
from tempfile import mkdtemp
import subprocess
import shutil
import utils

EPCOLLXML2EPCOLLXML = "epcollxml2epcollxml.xsl"


def transform_collxml_to_epcollxml(collection_dir, result_dir, womi_dir):
    print "[PY_EPCOLLXML] Transform collection"
    collection_file = utils.get_absolute_path(collection_dir, utils.COLLECTION_XML)
    doCopyModules = 1 if collection_dir != result_dir else 0

    if os.path.isfile(collection_file):
        collection_file_tmp = collection_file + '-tmp'
        shutil.copyfile(collection_file, collection_file_tmp)
        strCmd = ['java', '-jar',
                  utils.SAXON_JAR,
                  '-s:' + collection_file_tmp,
                  '-xsl:' + utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, EPCOLLXML2EPCOLLXML),
                  'resultDir=' + os.path.abspath(result_dir).replace('\\', '/'),
                  'doCopyModules=' + str(doCopyModules),
                  'womiLocalPath=' + os.path.abspath(womi_dir),
                  'path_to_files_epxml_of_modules_in_col=' + os.path.abspath(collection_dir)
        ]
        proc = subprocess.Popen(strCmd, stdout=subprocess.PIPE)
        proc.communicate()
        os.remove(collection_file_tmp)

        exit_code = proc.wait()
        if exit_code > 0:
            print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
            return -1
        print "[PY_EPCOLLXML] Transformation completed"
    else:
        print "[PY_ERR][PY_EPCOLLXML] Error: could not find: " + collection_dir


def main():
    parser = argparse.ArgumentParser(
        description='[PY_EPCOLLXML] Transforms collxml collection with epxml modules to xhtml files. ',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Directory of the collection \'s variants', required=True)
    parser.add_argument('-o', dest='output_dir', help='Target folder to store transformed collection variants', required=True)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2epxml'))
    parser.add_argument('-w', dest='womi_dir', help='Path to womi directory', required=True)

    print "[PY_EPCOLLXML] Transforming collxml to epxml"
    args = parser.parse_args()
    if(args.input_dir == args.output_dir):
        print >> sys.stderr, "[PY_ERR][PY_EPCOLLXML] -o output_dir must be different than -i input_dir"
        print >> sys.stderr, "[PY_ERR]STATUS_FATAL::0::Output dir must be different than input dir"
        sys.exit(1)

    status = transform_collxml_to_epcollxml(args.input_dir, args.output_dir, args.womi_dir)
    shutil.rmtree(args.temp_dir, ignore_errors=True)
    if status == -1:
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_EPCOLLXML] Unsuccessful exit."
        sys.exit(1)

    print "[PY_EPCOLLXML] End transforming collxml to epxml"

if __name__ == '__main__':
    sys.exit(main())
