import argparse
import os
import sys
from tempfile import mkdtemp
import subprocess
import shutil
import utils

EPCOLLXML2VARIANTS_MODIFY_MODULES = "epcollxml2variants_modify_modules.xsl"
EPCOLLXML2VARIANTS_MODIFY_COLLXML = "epcollxml2variants_modify_collxml.xsl"

def create_variants_catalogs_with_modules(collection_dir, result_dir, variants):
    collection_file = utils.get_absolute_path(collection_dir, utils.COLLECTION_XML)
    doCopyModules = 1 if collection_dir != result_dir else 0
    if os.path.isfile(collection_file):
        collection_file_tmp = collection_file + '-tmp'
        shutil.copyfile(collection_file, collection_file_tmp)
        strCmd = ['java', '-jar',
                  utils.SAXON_JAR,
                  '-s:' + collection_file_tmp,
                  '-xsl:' + utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, EPCOLLXML2VARIANTS_MODIFY_MODULES),
                  'resultDir=' + result_dir.replace('\\', '/'),
                  'doCopyModules=' + str(doCopyModules),
                  'path_to_files_epxml_of_modules_in_col=' + os.path.abspath(collection_dir),
                  'variants=' + variants
        ]
        proc = subprocess.Popen(strCmd, stdout=subprocess.PIPE)
        proc.communicate()
        os.remove(collection_file_tmp)
        exit_code = proc.wait()
        if exit_code > 0:
            print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
            return -1

        print "[collxml2variants] Transformation completed"
    else:
        print "[PY_ERR][collxml2variants] Error: could not find: " + collection_dir

def add_custom_collxml_to_variants_catalogs(collection_dir, result_dir, variants):
    collection_file = utils.get_absolute_path(collection_dir, utils.COLLECTION_XML)
    doCopyModules = 1 if collection_dir != result_dir else 0
    if os.path.isfile(collection_file):
        collection_file_tmp = collection_file + '-tmp'
        shutil.copyfile(collection_file, collection_file_tmp)
        strCmd = ['java', '-jar',
                  utils.SAXON_JAR,
                  '-s:' + collection_file_tmp,
                  '-xsl:' + utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, EPCOLLXML2VARIANTS_MODIFY_COLLXML),
                  'resultDir=' + result_dir.replace('\\', '/'),
                  'doCopyModules=' + str(doCopyModules),
                  'path_to_files_epxml_of_modules_in_col=' + os.path.abspath(collection_dir),
                  'variants=' + variants
        ]
        proc = subprocess.Popen(strCmd, stdout=subprocess.PIPE)
        proc.communicate()
        os.remove(collection_file_tmp)
        exit_code = proc.wait()
        if exit_code > 0:
            print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
            return -1
        print "[collxml2variants] Transformation completed"
    else:
        print "[PY_ERR][collxml2variants] Error: could not find: " + collection_dir

        
def transform_collection_to_variants(args, output_dir):
    print "[collxml2variants] Transforming - create catalogs with modules "
    status = create_variants_catalogs_with_modules(args.input_dir, output_dir, args.variants)
    if status == -1:
        return status
    
    print "[collxml2variants] Transforming - add custom collxml do every catalogs with variants"
    status = add_custom_collxml_to_variants_catalogs(args.input_dir, output_dir, args.variants)
    if status == -1:
        return status


def rename_variant_dir(dir, src_dir_names, dest_dir_name):
    for src_dir_name in src_dir_names:
        if os.path.exists(os.path.join(dir, src_dir_name)):
            shutil.move(os.path.join(dir, src_dir_name), os.path.join(dir, dest_dir_name))
            return


def convert_old_variants_to_new_variants(dir):
    rename_variant_dir(dir, ['student-expanding', 'student-supplemental', 'student-canon'], 'student')
    rename_variant_dir(dir, ['teacher-expanding', 'teacher-supplemental', 'teacher-canon'], 'teacher')

    UNUSED_VARIANTS = set(['student-canon', 'student-expanding', 'student-supplemental', 'teacher-canon', 'teacher-expanding', 'teacher-supplemental'])
    for subdir in os.walk(dir).next()[1]:
        if subdir in UNUSED_VARIANTS:
            shutil.rmtree(os.path.join(dir, subdir))

    if os.path.exists(os.path.join(dir, 'student')):
        shutil.move(os.path.join(dir, 'student'), os.path.join(dir, 'student-canon'))
    if os.path.exists(os.path.join(dir, 'teacher')):
        shutil.move(os.path.join(dir, 'teacher'), os.path.join(dir, 'teacher-canon'))

def remove_incomplete_variant_dir(dir, src_dir_names):
    for src_dir_name in src_dir_names:
        if os.path.exists(os.path.join(dir, src_dir_name)):
            if not(os.path.exists(os.path.join(dir, src_dir_name, 'collection.xml'))):
                print "[collxml2variants] Removing incomplete variant dir %s" % (src_dir_name)
                shutil.rmtree(os.path.join(dir, src_dir_name))


def main():
    parser = argparse.ArgumentParser(
        description='[collxml2variants] Transforms collxml collection to variants. ',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Directory of the collection', required=True)
    parser.add_argument('-o', dest='output_dir', help='Target folder to store transformed collection', required=True)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2variants'))
    parser.add_argument('-v', dest='variants', help='Expected variants (sc se ss tc te ts) separated by [:]', default="sc:se:ss:tc:te:ts")

    print "[PY_VARIANTS] Transforming collxml2variants"
    args = parser.parse_args()

    status = transform_collection_to_variants(args, os.path.abspath(args.output_dir))
    if status == -1:
        shutil.rmtree(args.temp_dir, ignore_errors=True)
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_VARIANTS] Unsuccessful exit."
        sys.exit(1)

    convert_old_variants_to_new_variants(args.output_dir)

    remove_incomplete_variant_dir(args.output_dir, ['student-canon', 'teacher-canon'])

    shutil.rmtree(args.temp_dir, ignore_errors=True)
    print "[PY_VARIANTS] End of transforms collxml2variants."
        
if __name__ == '__main__':
    sys.exit(main())
