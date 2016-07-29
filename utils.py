import os

from lxml import etree

NAMESPACES = {
    'c': 'http://cnx.rice.edu/cnxml',
    'svg': 'http://www.w3.org/2000/svg',
    'pmml2svg': 'https://sourceforge.net/projects/pmml2svg/',
    'mml': 'http://www.w3.org/1998/Math/MathML',
    'col': 'http://cnx.rice.edu/collxml',
    'md': 'http://cnx.rice.edu/mdml',
    'ep': 'http://epodreczniki.pl/',
    'x': 'http://www.w3.org/1999/xhtml'}


def get_absolute_path(dir, file):
    return os.path.join(os.getcwd(), dir, file)

def get_absolute_path_dir(dir):
    return os.path.join(os.getcwd(), dir)

MODULES_XPATH = etree.XPath('//col:module/@document', namespaces=NAMESPACES)
COLID_XPATH = etree.XPath('/col:collection/col:metadata/md:content-id/text()', namespaces=NAMESPACES)

DEFAULT_XSL_DIRECTORY = 'xsl'
DEFAULT_LIB_DIRECTORY = 'lib'
DEFAULT_WOMI_DIRECTORY = 'womi'
DEFAULT_RESULT_DIRECTORY = 'result'
DEFAULT_RECIPIENT_CONTENT = 'student-canon'
DEFAULT_OUTPUT_FORMAT = 'classic'
DEFAULT_FILENAME = 'filename'

COLLECTION_XML = 'collection.xml'
SAXON_PATH = 'saxon9he.jar'
SAXON_JAR = get_absolute_path(DEFAULT_LIB_DIRECTORY, SAXON_PATH)

def get_module_ids(collection_xml):
    modules=MODULES_XPATH(collection_xml)
    all_module_files=list(modules)
    for module in modules:
        if '_about_' in module and '_about_licenses' not in module:
            all_module_files.append(module+'_mobile_app')

    return all_module_files


def get_collection_id(collection_xml):
    return COLID_XPATH(collection_xml)[0]


def parse_collection_file(collection_dir):
    return etree.parse(os.path.join(collection_dir, COLLECTION_XML))

def check_if_variant_exists_in_param(curr_variant, param):
    if((curr_variant[0]+curr_variant.split('-')[1][0]) in param):
        return True
    else:
        return False

def sizeof_fmt(num):
    for x in ['bytes','KB','MB','GB','TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0
