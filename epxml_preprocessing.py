import argparse
import os
import sys
from tempfile import mkdtemp
import subprocess
import shutil
import utils
from lxml import etree
import hashlib
import re
from copy import copy
from io import open
import epomath

EPXML_PREPROCESSING = "epxml_preprocessing.xsl"

def transform_epxml_preprocessing(collection_dir, result_dir):
    collection_file = utils.get_absolute_path(collection_dir, utils.COLLECTION_XML)
    doCopyModules = 1 if collection_dir != result_dir else 0
    if os.path.isfile(collection_file):
        strCmd = ['java', '-jar',
                  utils.SAXON_JAR,
                  '-s:' + collection_file,
                  '-xsl:' + utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, EPXML_PREPROCESSING),
                  'resultDir=' + result_dir.replace('\\', '/'),
                  'doCopyModules=' + str(doCopyModules),
                  'path_to_files_epxml_of_modules_in_col=' + os.path.abspath(collection_dir)
        ]
        proc = subprocess.Popen(strCmd, stdout=subprocess.PIPE)
        proc.communicate()
        exit_code = proc.wait()
        if exit_code > 0:
            print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
            return -1

        if not os.path.exists(os.path.join(result_dir, utils.COLLECTION_XML)):
            shutil.copy(collection_file, utils.get_absolute_path(result_dir, utils.COLLECTION_XML))

    else:
        print "[PY_EPXML_PREPROC] Error: could not find: " + collection_dir

def addMathElementAroundMathmlInModuleContent(mathml, mathDigest, alt_text):
    mathml_temp = mathml
    math_element = etree.Element('{http://epodreczniki.pl/}mathElement')
    math_element.attrib['id'] = mathDigest
    math_element.attrib['alttext'] = alt_text
    mathml.addnext(math_element)
    math_element.append(mathml_temp)

def generate_mapping_file_mathml_digest(input_dir_with_epxhtml, output):
    print "[Py] \tProcessing module - create file with mapping digest<->mathml"
    MODULE_ID_XPATH = etree.XPath('//col:module/@document', namespaces=utils.NAMESPACES)

    try:
        collxml_file = utils.get_absolute_path(input_dir_with_epxhtml, 'collection.xml')

        if os.path.isfile(collxml_file):
            collxml_xml = etree.parse(collxml_file)
            if collxml_xml != "":
                if not os.path.exists(output):
                    os.makedirs(output)

                file_all_mathml_digest = open(os.path.join(output, 'mathml_digest.xml'), "w", encoding='utf-8')
                file_all_mathml_digest.write(unicode('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>', "utf-8"))
                file_all_mathml_digest.write(unicode("<root>", "utf-8"))

                number_of_modules = len(MODULE_ID_XPATH(collxml_xml))
                for module_position, module_id in enumerate(MODULE_ID_XPATH(collxml_xml)):
                    input_module_file = utils.get_absolute_path(input_dir_with_epxhtml, module_id+'/index.epxml')
                    if os.path.isfile(input_module_file):
                        modulexml = etree.parse(input_module_file)
                        if modulexml != "":
                            mathmls = modulexml.findall('//mml:math', namespaces=utils.NAMESPACES)
                            for math_position, mathml in enumerate(mathmls):
                                mathContent = copy(mathml)

                                math_content_value = re.sub('\s+', ' ', etree.tostring(mathContent, with_tail=False, encoding='UTF-8')).strip()

                                mmd5 = hashlib.md5()
                                mmd5.update(math_content_value)
                                mathDigest = mmd5.hexdigest()

                                alt_text = generate_alt_text(mathContent, mathDigest)

                                file_all_mathml_digest.write(u"<mathElement id=\"%s\">" % (mathDigest))
                                file_all_mathml_digest.write(unicode(math_content_value, "utf-8"))
                                file_all_mathml_digest.write(u"</mathElement>")

                                addMathElementAroundMathmlInModuleContent(mathml, mathDigest, alt_text)

                            if not os.path.exists(os.path.join(output,module_id)):
                                os.makedirs(os.path.join(output,module_id))
                            with open(os.path.join(output,module_id,'index.epxml'), 'w', encoding='utf-8') as f:
                                f.write(etree.tostring(modulexml, pretty_print=True, encoding='unicode'))

                file_all_mathml_digest.write(unicode("</root>", "utf-8"))
    except Exception as e:
        print "[PY_ERR] error (generate_mapping_file_mathml_digest) %s" % e
        sys.exit(1)
    finally:
        try:
            file_all_mathml_digest.close()
        except Exception as errorFin:
            print "[PY_ERR] error (generate_mapping_file_mathml_digest) in finally %s" % (errorFin)
            sys.exit(1)


def generate_alt_text(mathContent, mathDigest):
    try:
        math = epomath.MathTranslator()
        math.load(epomath.MathInput.MATHML, mathContent)
        return math.getOutput(epomath.MathOutput.MATHSPEAK, 'pl_PL', epomath.mathspeak.Verbosity.VERBOSE)
    except Exception as e:
        print "[PY_ERR][epomath] error generating alt text for %s: %s" % (mathDigest, e)
        return ""


def main():
    parser = argparse.ArgumentParser(
        description='[PY_EPXML_PREPROC] EPXML preprocessing',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Directory of the collection \'s variants', required=True)
    parser.add_argument('-o', dest='output_dir', help='Target folder to store transformed epxml preprocessing files', required=True)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-epxml_preprocessing'))

    print "[PY_EPXML_PREPROC] Transforming epxml preprocessing"
    args = parser.parse_args()
    if(args.input_dir == args.output_dir):
        print >> sys.stderr, "[py] -o output_dir must be different than -i input_dir;"
        print >> sys.stderr, "STATUS_FATAL::0::Output dir must be different than input dir"
        exit(1)

    temp_dir = os.path.abspath(args.temp_dir)
    input_dir=os.path.abspath(args.input_dir)
    output_dir = os.path.abspath(args.output_dir)
    status = transform_epxml_preprocessing(args.input_dir, temp_dir)
    if status == -1:
        shutil.rmtree(args.output_dir, ignore_errors=True)
        shutil.rmtree(args.temp_dir, ignore_errors=True)
        print "[PY_ERR][PY_EPXML_PREPROC] Unsuccessful exit."
        sys.exit(1)

    print "[PY_EPXML_PREPROC] generate mapping file mathml digest"
    generate_mapping_file_mathml_digest(temp_dir, output_dir)

    if not(os.path.exists(os.path.join(output_dir,'collection.xml'))):
        if os.path.exists(os.path.join(temp_dir,'collection.xml')):
            shutil.copy(os.path.join(temp_dir,'collection.xml'),output_dir)
        else:
            shutil.copy(os.path.join(input_dir,'collection.xml'),output_dir)

    shutil.rmtree(args.temp_dir, ignore_errors=True)
    print "[PY_EPXML_PREPROC] End transforming epxml preprocessing"

if __name__ == '__main__':
    sys.exit(main())
