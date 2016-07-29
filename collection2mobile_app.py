#!/usr/bin/env python
# -*- coding: utf-8 -*-
# coding: utf-8

import argparse
import sys
import os
from tempfile import mkdtemp
from lxml import etree
import subprocess
from StringIO import StringIO
import zipfile
import shutil
import md5
import re
import json
import time
import cairosvg
from xml import sax
from io import open

sys.path.insert(0, os.getcwd() +'/SVGMath')
import math2svg
import xml_corrector
from svgmath.mathhandler import MathHandler
from svgmath.tools.saxtools import XMLGenerator

import utils
import collection2epcollxml
import collection2epxhtml
import importlib

DIR_PACKAGE_MOBILE_APP=utils.get_absolute_path_dir('package_mobile_app')
EPXHTML2MOBILEAPP = utils.get_absolute_path(utils.DEFAULT_XSL_DIRECTORY, 'collection2mobile_app.xsl')
SVGMATH_CONFIG = "SVGMath/svgmath.xml"
CONVERT_BIN = 'convert'

MATH_XPATH = etree.XPath('//mml:math', namespaces=utils.NAMESPACES)
SVG_XPATH = etree.XPath('//svg:svg', namespaces=utils.NAMESPACES)
SVG_HEIGHT_XPATH = etree.XPath('@height', namespaces=utils.NAMESPACES)
SVG_WIDTH_XPATH = etree.XPath('@width', namespaces=utils.NAMESPACES)
XPATH_NODE = etree.XPath('//node')

SVG_MATH_ID_XPATH = etree.XPath('parent::node()/@id', namespaces=utils.NAMESPACES)
MODULE_ID_XPATH = etree.XPath('//col:module/@document', namespaces=utils.NAMESPACES)
PMML_METADATA_XPATH = etree.XPath('svg:metadata/pmml2svg:baseline-shift/text()', namespaces=utils.NAMESPACES)

ADDITIONAL_FILES_MAIN = ['icons/awesome-icons.zip', 'icons/nav.zip', 'css/css.css', 'css/ep.modern.css', 'icons/img.zip',
                         'tooltips/showDlgModeInfo.html', 'js/js.zip', 'womi/briefcase.svg']
ADDITIONAL_FILES_WOMI = ['womi/icon-womi-sound.svg', 'womi/womi_play.svg','womi/womi_placeholder.svg']
ADDITIONAL_FILES_FONTS= ['font/font-awesome-4.0.3.zip', 'font/opensans.zip', 'font/playfairdisplay.zip']
ADDITIONAL_FILES_ICONS= ['icons/standard-2-przyroda.zip', 'icons/standard-2-uwr.zip', 'icons/standard-2-matematyka.zip']

MOBILEAPP_MIMETYPE = 'application/zip'
DIR_MAIN = 'content'
DIR_EQUATIONS_MATH = 'm'
DIR_WOMI = 'womi'
DIR_WOMI_THUMBNAILS = 'womi_thumbnails'
DIR_JS = 'js'
DIR_FONT = 'font'
DIR_ICONS = 'icons'
DIR_TOOLTIPS = 'tooltips'
ZIPPER = 'zip'

mathmlFoundInEngineExercises=""
path_changed_womi_engine_files = None

WOMI_DIR_PATH = ""

def _create_temp_directories():
    dirs = {}
    dirs['root'] = mkdtemp(suffix='-ep2mobile-app')

    dirs['content'] = os.path.join(dirs['root'], DIR_MAIN)
    os.makedirs(dirs['content'])

    dirs['math'] = os.path.join(dirs['content'], DIR_EQUATIONS_MATH)
    os.makedirs(dirs['math'])

    dirs['womi'] = os.path.join(dirs['content'], DIR_WOMI)
    os.makedirs(dirs['womi'])

    dirs['js'] = os.path.join(dirs['content'], DIR_JS)
    os.makedirs(dirs['js'])

    dirs['font'] = os.path.join(dirs['content'], DIR_FONT)
    os.makedirs(dirs['font'])

    dirs['icons'] = os.path.join(dirs['content'], DIR_ICONS)
    os.makedirs(dirs['icons'])

    return dirs

def _check_arguments(args):
    if not os.path.exists(args.input_dir) or not os.path.isfile(os.path.join(args.input_dir, utils.COLLECTION_XML)):
        print >> sys.stderr, "[PY_ERR][PY_MOBILE_APP] -i input_dir must be directory containing collection.xml file"
        sys.exit(1)

    if not os.path.exists(args.womi_dir):
        print >> sys.stderr, "[PY_ERR][PY_MOBILE_APP] -w womi_dir: \"%s\" does not exist" % args.womi_dir
        sys.exit(1)

    if not os.path.exists(args.style_catalog):
        print >> sys.stderr, "[PY_ERR][PY_MOBILE_APP] -sc style_catalog: \"%s\" does not exist" % (args.style_catalog)
        sys.exit(1)

def _check_exists_of_output_dir(output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

def svg2png(xml, **params):
    size = len(SVG_XPATH(xml))
    if size > 0:
        start = time.time()
        for position, svg_img in enumerate(SVG_XPATH(xml)):
            str_image_name = "%s.png" % (str(SVG_MATH_ID_XPATH(svg_img)[0]))
            with open(os.path.join(params['png_dir'], str_image_name), 'wb') as f2:
                try :
                    cairosvg.svg2png(bytestring=etree.tostring(svg_img, with_tail=False),write_to=f2, dpi=200)
                except ZeroDivisionError:
                    print 'Division by zero in: ', str_image_name, ' (empty mathml)'
                except Exception as detail:
                    print "[PY_ERR] error in: ", str_image_name, '. ' + str(detail)
                    sys.exit(1)
    return xml

def display_progress(percent):
    sys.stdout.write("{z:0{digits}n}%".format(z=percent, digits=3))
    sys.stdout.write("\b\b\b\b")
    sys.stdout.flush()

def bundle_zip(output_mobileapp_file, dirs, womi_dir, print_styles, style_catalog, resolution, list_changed_womi_engine_id_file, path_changed_womi_engine):
    try:
        print '[py] pack data for %s resolution' % resolution

        mime_file = _write_mimetype(dirs['root'] + '-mime-' + resolution)

        zip = zipfile.ZipFile(output_mobileapp_file, 'w', compression=zipfile.ZIP_STORED)
        zip.write(mime_file, os.path.basename(mime_file))
        zip.close()
        zip = zipfile.ZipFile(output_mobileapp_file, 'a', compression=zipfile.ZIP_DEFLATED)
        abs_src = os.path.abspath(dirs['root'])
        if os.path.exists(dirs['womi_thumbnails']):
            for filename in os.listdir(dirs['womi_thumbnails']):
                absname = os.path.join(dirs['womi_thumbnails'], filename)
                arcname = os.path.join(DIR_MAIN, DIR_WOMI, filename.lower())
                zip.write(absname, arcname)

        for dirname, subdirs, files in os.walk(dirs['root']):
            if 'womi_thumbnails' not in dirname:
                for filename in files:
                    if filename == 'showDlgModeInfo.html':
                        absname = os.path.abspath(os.path.join(dirname, filename))
                        arcname = os.path.join(DIR_MAIN, DIR_TOOLTIPS, filename)
                        zip.write(absname, arcname)
                    elif filename != 'gallery_womi.xml':					 
                        absname = os.path.abspath(os.path.join(dirname, filename))
                        arcname = absname[len(abs_src) + 1:]
                        zip.write(absname, arcname)

        abs_src = os.path.abspath(womi_dir)

        for filename in os.listdir(os.path.join(womi_dir, 'mobile-app', resolution)):
            absname = os.path.abspath(os.path.join(womi_dir, 'mobile-app', resolution, filename))
            arcname = os.path.join(DIR_MAIN, DIR_WOMI, filename.lower())
            zip.write(absname, arcname)

        womiId=''
        abs_src = os.path.abspath(os.path.join(womi_dir, 'mobile-app/womi_engine'))
        for dirname, subdirs, files in os.walk(os.path.join(womi_dir, 'mobile-app/womi_engine')):
            for filename in files:
                if filename.endswith('.json') or filename.endswith('.html'):
                    womiId =os.path.split(dirname)[1]
                    if (womiId in list_changed_womi_engine_id_file) and (os.path.exists(os.path.join(path_changed_womi_engine, womiId, filename))):
                        absname = os.path.abspath(os.path.join(path_changed_womi_engine, womiId, filename))
                        arcname = os.path.join(DIR_MAIN, DIR_WOMI, womiId, filename)
                    else:
                        absname = os.path.abspath(os.path.join(dirname, filename))
                        arcname = os.path.join(DIR_MAIN, DIR_WOMI, absname[len(abs_src) + 1:])
                else:
                    absname = os.path.abspath(os.path.join(dirname, filename))
                    arcname = os.path.join(DIR_MAIN, DIR_WOMI, absname[len(abs_src) + 1:])

                zip.write(absname, arcname)

        if len(list_changed_womi_engine_id_file) > 0:
            for womiId in list_changed_womi_engine_id_file:
                path_womi_img = os.path.join(path_changed_womi_engine, womiId, 'img')

                if(os.path.isdir(path_womi_img)):
                    if not os.path.isdir(os.path.join(DIR_MAIN, DIR_WOMI, womiId, 'img')):
                        os.makedirs(os.path.join(DIR_MAIN, DIR_WOMI, womiId, 'img'))

                    for filename in os.listdir(path_womi_img):
                        absname = os.path.abspath(os.path.join(path_womi_img, filename))
                        arcname = os.path.join(DIR_MAIN, DIR_WOMI, womiId, 'img', filename)
                        zip.write(absname, arcname)

        for filename in os.listdir(style_catalog):
            absname = os.path.abspath(os.path.join(style_catalog, filename))
            arcname = os.path.join(DIR_MAIN, filename)
            zip.write(absname, arcname)

        zip.close()

        shutil.rmtree(dirs['root'] + '-mime-' + resolution, ignore_errors=True)
    except Exception as e:
        print "[PY_ERR] error in fun 'bundle_zip' - "+str(e)
        sys.exit(1)

def _write_mimetype(directory):
    os.makedirs(directory)
    mime_filename = os.path.join(directory, 'mimetype')
    with open(mime_filename, 'w', encoding='utf-8') as f:
        f.write(unicode(MOBILEAPP_MIMETYPE))

    return mime_filename

def getCurrSubject(path_collxml):
    XPATH_STYLESHEET = etree.XPath('//col:metadata/ep:e-textbook/ep:stylesheet/text()', namespaces=utils.NAMESPACES)
    XPATH_SUBJECT = etree.XPath('//col:metadata/md:subjectlist/md:subject/text()', namespaces=utils.NAMESPACES)
    currSubjects=""

    collxml_file = utils.get_absolute_path(path_collxml, 'collection.xml')
    if os.path.isfile(collxml_file):
        collxml_xml = etree.parse(collxml_file)
        if collxml_xml != "":
            xpath_result = XPATH_SUBJECT(collxml_xml)
            if len(xpath_result) > 0:
                for i in xpath_result:
                    currSubjects += i.encode('UTF-8').lower()+','

    print "[py] currSubjects="+currSubjects
    return currSubjects

def get_dir_stylesheet(currSubjects):
    dir_stylesheet = ""
    if currSubjects == "":
        dir_stylesheet='general'
    if currSubjects != "":
        if any(x in currSubjects for x in ['biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'fizyka', 'geografia', 'przyroda', 'zajęcia komputerowe', 'informatyka']):
            dir_stylesheet = 'up'
        elif any(x in currSubjects for x in ['historia','język polski', 'wiedza o społeczeństwie']):
            dir_stylesheet = 'uwr'
        elif any(x in currSubjects for x in ['matematyka']):
            dir_stylesheet = 'mat'
        else:
            dir_stylesheet = 'general'

    print '[py] dir_stylesheet='+dir_stylesheet
    return dir_stylesheet

def _remove_temp_directories(dir_name):
    import shutil

    shutil.rmtree(dir_name, ignore_errors=True)

def download_data(itemPath, item, resultDir,collWithGeogebraExercises):
    try:
        if not os.path.exists(itemPath):
            print "[ERR] download_data: directory of '%s' not exists" % itemPath
        else:
            if '.zip' in item:
                if 'nav.zip' in item:
                    resultDir = os.path.join(resultDir, 'awesome-icons')

                with zipfile.ZipFile(itemPath, "r") as z:
                    z.extractall(resultDir)

                if ('js.zip' in item) and (collWithGeogebraExercises==0):
                    shutil.rmtree(os.path.join(resultDir, 'js/3rdparty/geogebra'))

            else:
                if '/' in item:
                    item = item.split('/', 1)[1]
                if 'briefcase.svg' in item:
                    resultDir = os.path.join(resultDir, 'awesome-icons')

                shutil.copy(itemPath, resultDir)
    except Exception as e:
        print "[PY_ERR] error in fun 'download_data' - "+str(e)
        sys.exit(1)

def checkIfCollectionContainsGeogebraTypeExercise():
    for dirname, subdirs, files in os.walk(WOMI_DIR_PATH):
        for filename in files:
            if 'geogebra.html' in filename:
                return 1
    return 0

def download_fonts_and_scripts(dirs,currSubjects, collWithGeogebraExercises):
    try:
        print '[py] download fonts and scripts'

        font_dir = os.path.abspath(dirs['font'])
        icons_dir = os.path.abspath(dirs['icons'])
        content_dir = os.path.abspath(dirs['content'])
        womi_dir = os.path.abspath(dirs['womi'])

        for item in ADDITIONAL_FILES_MAIN:
            download_data(os.path.join(DIR_PACKAGE_MOBILE_APP,item),item, content_dir,collWithGeogebraExercises)

        for item in ADDITIONAL_FILES_FONTS:
            download_data(os.path.join(DIR_PACKAGE_MOBILE_APP,item),item, font_dir,collWithGeogebraExercises)

        for item in ADDITIONAL_FILES_WOMI:
            download_data(os.path.join(DIR_PACKAGE_MOBILE_APP,item),item, womi_dir,collWithGeogebraExercises)

        special_icons_dir=""
        if any(x in currSubjects for x in ['biologia', 'chemia', 'edukacja dla bezpieczeństwa', 'fizyka', 'geografia', 'przyroda', 'zajęcia komputerowe', 'informatyka']):
            special_icons_dir = 'icons/standard-2-przyroda.zip'
        elif any(x in currSubjects for x in ['historia','język polski', 'wiedza o społeczeństwie']):
            special_icons_dir = 'icons/standard-2-uwr.zip'
        elif any(x in currSubjects for x in ['matematyka']):
            special_icons_dir = 'icons/standard-2-matematyka.zip'
        print "[py] curr_icons_dir="+special_icons_dir
        download_data(os.path.join(DIR_PACKAGE_MOBILE_APP,special_icons_dir),special_icons_dir, icons_dir,collWithGeogebraExercises)

    except Exception as e:
        print "[PY_ERR] error in fun 'download_fonts_and_scripts' - "+str(e)
        sys.exit(1)

def addMathElement(mathml, md5_id, svg_output_value, is_valid_mathml):
    try:
        if is_valid_mathml ==1:
            parsed= etree.XML(svg_output_value)
            math_element = etree.Element('img')
            math_element.attrib['src'] = "m/%s.png" % md5_id
            math_element.attrib['style']="width: %s; height: %s" % (str(SVG_WIDTH_XPATH(parsed)[0]), str(SVG_HEIGHT_XPATH(parsed)[0]))

            mathDiv = etree.Element('div')
            mathDiv.attrib['class'] = "img"
            mathDiv.append(math_element)
        else:
            mathDiv = etree.Element('div')
            mathDiv.attrib['class'] = "mathErr"
            mathDiv.text=unicode("Wystąpił błąd w przetwarzaniu wzoru.",'utf-8')

        mathml.addnext(mathDiv)

        parent = mathml.getparent()
        parent.remove(mathml)
    except Exception as e:
        print "[PY_ERR] error in fun 'addMathElement' at id=%s, with err=%s" % (md5_id,str(e))
        sys.exit(1)

def check_if_mathml_valid(mathml_string,module_id,womi_id):
    try:
        math_handler = getMathHandler(StringIO())
        source = StringIO(mathml_string)
        parser = sax.make_parser()
        parser.setFeature(sax.handler.feature_namespaces, 1)
        parser.setContentHandler(math_handler)
        parser.parse(source)
        return True
    except Exception as e:
        print "[PY_WARR][PY_MOBILE_APP] valid problem in fun 'check_if_mathml_valid' in (m,w)=[%s/%s], err=%s, [mathmlStr=%s]" % (module_id,womi_id,str(e),mathml_string)
        return False

def math2svg(handler, mathml_string,md5_id,module_id,womi_id):
    mathEx=re.findall(r'(&[a-zA-Z]+;)',mathml_string)
    math2svgData=xml_corrector.replaceHtmlEntityToNumericString(mathml_string,set(mathEx))

    if not(check_if_mathml_valid(math2svgData,module_id,womi_id)):
        return False
    else:
        try:
            math2svgData = math2svgData.replace('&#160;', '&#19968;')
            source = StringIO(math2svgData)
            parser = sax.make_parser()
            parser.setFeature(sax.handler.feature_namespaces, 1)
            parser.setContentHandler(handler)
            parser.parse(source)
            return True
        except Exception as e:
            print "[PY_ERR][PY_MOBILE_APP] Error in mathml with md5_id=%s [loc(m,w)=%s/%s], [mathmlStr=%s]" % (md5_id,module_id,womi_id,mathml_string)
            print "[PY_ERR][PY_MOBILE_APP] "+str(e)
            sys.exit(1)
            return False

def create_md5_from_mathml(mathml_string):
    math_content_value = re.sub('\s+', ' ', mathml_string).strip()
    m = md5.new()
    m.update(math_content_value)
    return m.hexdigest()

def getMathHandler(all_svg_file):
    config = open(SVGMATH_CONFIG, "r", encoding='utf-8')
    sax_output = XMLGenerator(all_svg_file, 'utf-8')
    handler = MathHandler(sax_output, config)
    return handler

def generate_mathml_md5_map(input_dir_with_epxhtml, output, dirs):
    try:
        print "[Py] \tProcessing module - create md5 from mathml"

        collxml_file = utils.get_absolute_path(input_dir_with_epxhtml, 'collection.xml')
        tmp_dir = os.path.abspath(dirs['content'])

        if os.path.isfile(collxml_file):
            collxml_xml = etree.parse(collxml_file)
            if collxml_xml != "":
                with open(os.path.join(output, 'collection.xml'), 'w', encoding='utf-8') as f:
                    f.write(etree.tostring(collxml_xml, pretty_print=True, encoding='unicode'))

                if os.path.exists(os.path.join(input_dir_with_epxhtml, "mappingGlossary.xml")) and os.path.exists(os.path.join(input_dir_with_epxhtml, "mappingGlossary.xml")):
                    shutil.copy(os.path.join(input_dir_with_epxhtml, "mappingGlossary.xml"), os.path.join(output, "mappingGlossary.xml"))

                all_svg_file = open(os.path.join(tmp_dir, 'svg.html'), "w", encoding='utf-8')
                all_svg_file.write(unicode("<svgs>", "utf-8"))

                svg_output= StringIO()
                math_handler = getMathHandler(svg_output)
                svg_output_value=''

                start = time.time()
                number_of_modules = len(MODULE_ID_XPATH(collxml_xml))
                math_flag = 0;
                for module_position, module_id in enumerate(MODULE_ID_XPATH(collxml_xml)):
                    if '_about_' in module_id and '_about_licenses' not in module_id:
                        module_filename = module_id + '_mobile_app.xhtml'
                    else:
                        module_filename = module_id + '.xhtml'
                    input_module_file = utils.get_absolute_path(input_dir_with_epxhtml, module_filename)
                    if os.path.isfile(input_module_file):
                        modulexml = etree.parse(input_module_file)
                        if modulexml != "":
                            mathmls = modulexml.findall('//mml:math', namespaces=utils.NAMESPACES)
                            number_of_mathmls = len(mathmls)
                            module_range = 100.0 / float(number_of_modules);
                            if number_of_mathmls > 0 and math_flag == 0:
                                sys.stdout.write("[mobile-app] \tProcessing mathmls to svgs: ")
                                math_flag = 1
                            display_progress(int((float(module_position + 1) / float(number_of_modules)) * 100))
                            for math_position, mathml in enumerate(mathmls):
                                display_progress(int((float(module_position + 1) / float(number_of_modules)) * 100) + int((float(math_position + 1) / float(number_of_mathmls)) * module_range))

                                mathml_string = etree.tostring(mathml, with_tail=False)
                                md5_id=create_md5_from_mathml(mathml_string)
                                isValidMathml=math2svg(math_handler, mathml_string, md5_id,module_id,'')

                                svg_output_value=svg_output.getvalue()
                                all_svg_file.write(unicode("<mathElement id=\"%s\">" % md5_id, "utf-8"))
                                if isValidMathml:
                                    all_svg_file.write(unicode(svg_output_value, "utf-8"))
                                else:
                                    all_svg_file.write(unicode("Wystąpił błąd w przetwarzaniu wzoru.", "utf-8"))

                                all_svg_file.write(unicode("</mathElement>", "utf-8"))
                                svg_output.seek(0)
                                svg_output.truncate(0)

                                addMathElement(mathml, md5_id, svg_output_value,isValidMathml)

                            with open(os.path.join(output, module_filename), 'w', encoding='utf-8') as f:
                                f.write(etree.tostring(modulexml, pretty_print=True, encoding='unicode'))

                svg_output.close()
                all_svg_file.write(unicode("</svgs>", "utf-8"))
                all_svg_file.close()
                sys.stdout.write("\nTime math2svg: ")
                print(time.time() - start)
    except Exception as e:
        print "[PY_ERR] error in fun 'generate_mathml_md5_map' in module_id=%s, with err=%s, mathml_string=[%s]" % (module_id,str(e),mathml_string)
        sys.exit(1)

def get_womi_file_extension(womiId):
    try:
        global WOMI_DIR_PATH

        with open(os.path.join(WOMI_DIR_PATH,str(womiId)+'-manifest.json'), "r", encoding='utf-8') as json_file:
            json_string = json_file.read()
            json_file.close()
            json_obj = json.loads(json_string, encoding='utf-8')

        ext = str(json_obj['parameters']['mobile']['mimeType'].split("image/",1)[1])

        if 'svg' in ext:
            return 'png'
        elif 'jpeg' in ext:
            return 'jpg'
        else:
            return ext.split('+',1)[0]
    except Exception as e:
        print "[PY_ERR] error in fun 'get_womi_file_extension' in womiId=%s with err=%s" % (womiId,str(e))
        sys.exit(1)

def process_exist_imgs(node, item, womiId):
    try:
        ind_img = re.finditer("<img",node[item])
        for idx, data in enumerate(ind_img):
            loc_img = womiId+"/"+node["images"][idx]
            if ('womi#' in loc_img):
                loc_imgId = loc_img.split("womi#",1)[1]
                loc_img = loc_imgId+"."+get_womi_file_extension(loc_imgId)

            node[item] = node[item].replace('<img', '<img class=\"ex-block\" src=\"womi/{d}\"'.format(d=loc_img), 1)
        return node
    except Exception as e:
        print "[PY_ERR] error in fun 'process_exist_imgs' in womiId=%s with err=%s" % (womiId,str(e))
        sys.exit(1)

def process_mathml(node, item, womiId):
    try:
        if(re.search("</math>", node[item]) == None):
            node[item] = node[item]+"</math>"

        mser = re.search(r'(<math.*</math>)', node[item])
        mathData= mser.group(1)

        ind_beg=0
        ind_end=0

        while ind_beg >= 0:
            ind_end = mathData.find("</math>",ind_beg)+7

            mathml = mathData[ind_beg:ind_end]
            math_content_value = re.sub('\s+', ' ', mathml.encode('utf-8')).strip()
            m = md5.new()
            m.update(math_content_value)
            md5_id = m.hexdigest()

            output= StringIO()
            if math2svg(getMathHandler(output), math_content_value, md5_id,'',womiId):
                mathElement = "<mathElement id=\"%s\">" % md5_id

                svg_output_value = output.getvalue()
                mathElement+=svg_output_value
                mathElement +="</mathElement>"
                global mathmlFoundInEngineExercises
                mathmlFoundInEngineExercises += mathElement

                parsed= etree.XML(svg_output_value)
                node[item] = node[item].replace(mathml, "<img class=\"ex-inline\" src=\"womi/{w_id}/img/{s}.png\" style=\"width: {wid}; height: {hei}\"/>".format(w_id=womiId, s=md5_id,
                                                                                                                                           wid=str(SVG_WIDTH_XPATH(parsed)[0]),
                                                                                                                                           hei=str(SVG_HEIGHT_XPATH(parsed)[0])))
            else:
                node[item] = node[item].replace(mathml, unicode("Wystąpił błąd w przetwarzaniu wzoru.",'utf-8'))
                print "[ERR] Problem with mathml in womiId="+str(womiId)

            ind_beg = mathData.find('<math', ind_end)

        return node
    except Exception as e:
        print "[PY_ERR] error in fun 'process_mathml' in womiId=%s in mathml=%s, with err=%s" % (womiId,str(math_content_value),str(e))
        sys.exit(1)

def browse_json_data(json_obj, womiId):
    try:
        for item in json_obj:
            browse_json_data_nest(json_obj, item, False, womiId)
    except Exception as e:
        print "[PY_ERR] error in fun 'browse_json_data' in womiId=%s with err=%s" % (womiId,str(e))
        sys.exit(1)

def browse_json_data_nest(json_obj, item, isNestedList, womiId):
    try:
        if isNestedList:
            data = json_obj
        else:
            data = json_obj[item]

        if isinstance(data, dict):
            browse_json_data(data, womiId)
        elif isinstance(data, (list, tuple)):
            for nestItem in data:
                browse_json_data_nest(nestItem, item, True, womiId)
        else:
            if isinstance(data, unicode):
                data = data.encode('utf-8')
                if(re.search("<img", str(data)) != None):
                    json_obj = process_exist_imgs(json_obj, item, womiId)
                if(re.search("<math", str(data)) != None):
                    json_obj = process_mathml(json_obj, item, womiId)
    except Exception as e:
        print "[PY_ERR] error in fun 'browse_json_data_nest' in womiId=%s with err=%s" % (womiId,str(e))
        sys.exit(1)


def add_doctype_declaration_if_not_exists(filename,inPath, outPath, womiId):
    filePath = os.path.join(inPath,filename)
    dataFile = ""
    try:
        with open(filePath, "r", encoding='utf-8') as file:
            dataFile = file.read()
    except Exception as error:
        print "[PY_WARR] File %s in womi %s has NOT encoding utf-8 [fun='add_doctype_declaration_if_not_exists']" % (filename,str(womiId))
        if file:
            file.close()
        try:
            with open(filePath, "r", encoding='cp1252', errors='ignore') as file:
                dataFile = file.read()
            print "[PY_OK] File has encoding cp1252."
        except Exception as error:
            print "[PY_ERR] error with encoding cp1252 of file %s in womi %s in fun='add_doctype_declaration_if_not_exists' :%s" % (error,filename,str(womiId))
    finally:
        if file:
            file.close()

    incorrectFile=0
    if re.match('^\s+<!DOCTYPE html',dataFile):
        incorrectFile=1
        dataFile=re.sub(r'^[^<!DOCTYPE]*', '',dataFile)

    if not dataFile.startswith('<!DOCTYPE html'):
        incorrectFile=1
        dataFile ="<!DOCTYPE html>\n"+dataFile

    if incorrectFile==1:
        if not os.path.exists(outPath):
            os.mkdir(outPath)
        with open(os.path.join(outPath,filename), 'w+', encoding='utf-8') as f:
            f.write(dataFile)

def process_womi_engine_exercise(param_path_womi_engine, path_changed_womi_files):
    womiId=""
    try:
        global path_changed_womi_engine_files
        path_changed_womi_engine_files= path_changed_womi_files

        list_change_womi =[]
        isUwrWomi=''

        path_womi_engine=os.path.join(param_path_womi_engine,'mobile-app/womi_engine')

        mainFileName=""
        for dirname, subdirs, files in os.walk(path_womi_engine):
            for filename in files:
                womiId=""
                if 'womi_engine/' in dirname:
                    womiId=str((dirname.split('womi_engine/',1)[1]).split('/',1)[0])
                if '.html' in filename:
                    add_doctype_declaration_if_not_exists(filename,dirname,os.path.join(path_changed_womi_files, womiId), womiId)
                    list_change_womi.append(womiId)

                if 'manifest.json' == filename:
                    isUwrWomi = False
                    with open(os.path.join(dirname, 'manifest.json'), "r", encoding='utf-8') as json_file:
                        json_string = json_file.read()
                        json_file.close()
                        if len(json_string) == 0:
                            print "[PY_ERR] Manifest of WOMI %s is empty" % womiId
                            sys.exit(1)

                        try:
                            json_obj = json.loads(json_string)
                        except ValueError as e:
                            print "[PY_ERR] Error parsing manifest of WOMI %s: %s" % (womiId, str(e))
                            sys.exit(1)

                        engine_type = str((json_obj['engine']).encode('utf-8'))
                        if engine_type in 'processingjs_animation':
                            changeWomiIndexFile_oeiizk(womiId,path_womi_engine,path_changed_womi_files,str((json_obj['mainFile']).encode('utf-8')))
                            list_change_womi.append(womiId)

                        if engine_type != 'womi_exercise_engine' and engine_type != 'custom_logic_exercise_womi':
                            isUwrWomi = True

                        mainFileName = str((json_obj['mainFile']).encode('utf-8'))

                    if not(isUwrWomi) and os.path.exists(os.path.join(dirname, mainFileName)):
                        with open(os.path.join(dirname, mainFileName), "r", encoding='utf-8') as json_file:
                            json_string = json_file.read()
                            json_file.close()

                            if "<math" in json_string or "<img" in json_string:
                                womiId= os.path.split(dirname)[1]
                                if not os.path.exists(os.path.join(path_changed_womi_files, womiId)):
                                    os.mkdir(os.path.join(path_changed_womi_files, womiId))

                                global mathmlFoundInEngineExercises
                                mathmlFoundInEngineExercises = ""
                                json_obj = json.loads(json_string)
                                browse_json_data(json_obj, womiId)
                                list_change_womi.append(womiId)

                                with open(os.path.join(path_changed_womi_files, womiId, mainFileName), 'w+', encoding='utf-8') as f:
                                    f.write(json.dumps(json_obj, ensure_ascii=False, indent=1))

                                if mathmlFoundInEngineExercises != "":
                                    mathSvg = "<svgs>"
                                    mathSvg += mathmlFoundInEngineExercises
                                    mathSvg += "</svgs>"

                                    imgPath =os.path.join(path_changed_womi_files, womiId, 'img')
                                    os.mkdir(imgPath)

                                    parser2 = etree.XMLParser(ns_clean=True, recover=True)
                                    svg_parsed= etree.fromstring(mathSvg, parser2)
                                    svg2png(svg_parsed, png_dir=imgPath)

        return list_change_womi
    except Exception as e:
        print "[PY_ERR] error with womiId="+womiId+" in fun 'process_womi_engine_exercise' - "+str(e)
        sys.exit(1)

def get_all_no_declared_scripts(womiId,path_origin_womi, list_declared_scripts):
    listNoDeclaredScript=[]
    for dirname, subdirs, files in os.walk(os.path.join(path_origin_womi,womiId)):
        for filename in files:
            if filename.endswith('.js') and filename not in list_declared_scripts:
                listNoDeclaredScript.append(filename)

    return listNoDeclaredScript


def changeWomiIndexFile_oeiizk(womiId,path_origin_womi, path_changed_womi, mainFileName):
    filePath = os.path.join(path_origin_womi, womiId,mainFileName)
    fileContent = ""
    try:
        with open(filePath, "r", encoding='utf-8') as file:
            fileContent = file.read()
    except Exception as error:
        print "[PY_WARR] File %s in womi %s has NOT encoding utf-8 [fun='changeWomiIndexFile_oeiizk']" % (mainFileName,str(womiId))
        if file:
            file.close()
        print "[PY_OK] File has encoding cp1252."
        try:
            with open(filePath, "r", encoding='cp1252', errors='ignore') as file:
                fileContent = file.read()
        except Exception as error:
            print "[PY_ERR] error with encoding cp1252 of file %s in womi %s in fun='changeWomiIndexFile_oeiizk' :%s" % (error,mainFileName,str(womiId))
    finally:
        if file:
            file.close()

    try:
        XPATH_HEAD = etree.XPath('/html/head')
        XPATH_HEAD_RM_SCRIPT = etree.XPath("//script[contains(@src,'/global/libraries')]")
        XPATH_HEAD_FIRST_SCRIPT = etree.XPath('./script')
        XPATH_HEAD_SCRIPT_SRC = etree.XPath('./script/@src')

        html = etree.HTML(fileContent)
        xpath_result = XPATH_HEAD(html)[0]

        xpath_rm_script = XPATH_HEAD_RM_SCRIPT(xpath_result)
        if (len(xpath_rm_script)>0):
            for rm_item in xpath_rm_script:
                xpath_result.remove(rm_item)

        newElem = etree.Element('script')
        newElem.attrib['src'] = "./../../js/3rdparty/oeiizk/embed.js"

        xpath_add_script = XPATH_HEAD_FIRST_SCRIPT(xpath_result)
        xpath_add_script[0].addprevious(newElem)

        list_no_declared_script = get_all_no_declared_scripts(womiId,path_origin_womi, str(XPATH_HEAD_SCRIPT_SRC(xpath_result)))
        for script in list_no_declared_script:
            elem = etree.Element('script')
            elem.attrib['src'] = script
            xpath_add_script[0].addprevious(elem)

        if not(os.path.exists(os.path.join(path_changed_womi, womiId))):
            os.mkdir(os.path.join(path_changed_womi, womiId))
        with open(os.path.join(path_changed_womi, womiId,mainFileName), 'w+', encoding='utf-8') as f:
            f.write(etree.tostring(html, pretty_print=True, method="html",doctype="<!DOCTYPE HTML>",encoding="unicode"))

    except Exception as error:
        print "[PY_ERR] error in fun='changeWomiIndexFile_oeiizk' :%s" % (error)
        sys.exit(1)
    finally:
        try:
            if not(f is None):
                f.close()
        except Exception as errorFin:
            print "[PY_ERR] error in finally in fun='changeWomiIndexFile_oeiizk' :%s" % (errorFin)
            sys.exit(1)

def transform_collection(input_dir_with_epxhtml, dirs, print_styles, womi_dir,collWithGeogebraExercises,tmp_mathml_engine_exercises):
    print "[py] start transform_collection"
    input_dir = mkdtemp(suffix='-ep2mobile-app_mathEL')
    generate_mathml_md5_map(os.path.abspath(input_dir_with_epxhtml), input_dir, dirs)

    if(len(os.walk(input_dir).next()[2]) > 0):
        result_dir = os.path.abspath(dirs['content'])
        str_cmd = ['java', '-jar',
                   utils.SAXON_JAR,
                   '-s:' + input_dir + "/collection.xml",
                   '-xsl:' + EPXHTML2MOBILEAPP,
                   'resultDir=' + result_dir.replace('\\', '/'),
                   'epxhtml_path=' + input_dir,
                   'womiLocalPath=' + os.path.abspath(womi_dir),
				   'womiLocalPath_modifyWomi=' +tmp_mathml_engine_exercises,
                   'collWithGeogebraExercises='+str(collWithGeogebraExercises),
                   'files_to_stylesheet=' + print_styles
        ]
        proc = subprocess.Popen(str_cmd)
        proc.communicate()

        if os.path.exists(os.path.join(result_dir,"gallery_womi.xml")):
            copy_thumbnail_womi(os.path.join(result_dir,"gallery_womi.xml"), dirs, womi_dir)

        exit_code = proc.wait()
        if exit_code > 0:
            print "[PY_XSLT_ERR] Error in transformation process [error_code=%s]." % str(exit_code)
            shutil.rmtree(input_dir, ignore_errors=True)
            return -1

        print "[py] end transform_collection"

        print "[py] process toc xml2json to files: toc,pages"
        processTocXmlToJson(result_dir.replace('\\', '/'))

        print "[py] process math elements to png"

        svg_file = os.path.join(result_dir, 'svg.html')
        svg_parsed = etree.parse(svg_file)
        svg2png(svg_parsed, png_dir=dirs['math'], epub_png_subdir=DIR_EQUATIONS_MATH)
        if os.path.isfile(svg_file):
            os.remove(svg_file)

    else:
        print "[PY_ERR] Kolekcja zawiera bledne pliki"
        sys.exit(1)

    shutil.rmtree(input_dir, ignore_errors=True)

def copy_thumbnail_womi(path_gallery_womi, dirs, womi_dir):
    f = open(path_gallery_womi, 'r', encoding='utf-8')
    galleryWomi = etree.HTML(f.read())
    f.close()

    xpath_womiId = etree.XPath('//gallery_womi/womi_id/text()')
    listGalleryWomi = xpath_womiId(galleryWomi)

    dirs['womi_thumbnails'] = os.path.join(dirs['content'], DIR_WOMI_THUMBNAILS)
    os.makedirs(dirs['womi_thumbnails'])

    path_womi_120 = os.path.join(womi_dir, 'mobile-app', '120')
    womi_old_name =""
    for item in listGalleryWomi:
        womi_old_name = item.replace('_thumbnail', '')
        shutil.copy(os.path.join(path_womi_120,womi_old_name), os.path.join(dirs['womi_thumbnails'],item))

def processTocXmlToJson(result_dir):
    try:
        f = open(utils.get_absolute_path(result_dir, 'toc.xml'), 'r', encoding='utf-8')
        tocData = f.read()
        f.close()

        tocData = tocData.replace('<!DOCTYPE HTML>\n', '').replace('&nbsp;', ' ')
        tree = etree.fromstring(tocData)

        f = open(os.path.join(result_dir, 'toc.json'), 'w', encoding='utf-8')
        f.write(unicode(json.dumps(toc_create_main_file(tree)['toc'], indent=4, encoding="utf-8")))
        f.close()

        f = open(os.path.join(result_dir, 'pages.json'), 'w', encoding='utf-8')
        f.write(unicode(json.dumps(toc_create_pages_file(tree)['pages'], indent=4, encoding="utf-8")))
        f.close()

        os.remove(utils.get_absolute_path(result_dir, 'toc.xml'))
    except Exception as e:
        print "[PY_ERR] error in fun 'processTocXmlToJson' - "+str(e)
        sys.exit(1)

def toc_create_main_file(node):
    res = {}
    res[node.tag] = []
    xmlToDict(node, res[node.tag])
    return res

def processModuleNodeToc(node,repnode):
    dict ={}
    tmp = []

    for n in list(node):
        if n.tag == 'contentStatus' and n.text is not None:
            for pos, item in enumerate(str(n.text).split(';')):
                if item != '':
                    tmp.append(item)
            dict[n.tag] = tmp
        elif n.tag == 'children':
            if 'about' not in list(node)[0].text:
                xmlToDict(n, repnode)
                if len(repnode) == 0 or (len(repnode) == 1 and repnode[0] is None):
                    dict[n.tag] = None
                else:
                    dict[n.tag] = repnode
            else:
                dict[n.tag] = None
        elif n.tag == 'path':
            dict['pathRef'] = n.text
        else:
            if n.tag != 'pageId':
                dict[n.tag] = n.text
    return dict

def processModuleNode(node):
    dict ={}
    tmp = []

    lastSectionWithTitleTocId = ''
    XPATH_NODE = etree.XPath('./lastSectionWithTitleTocId')
    res_xpath = XPATH_NODE(node)
    if len(res_xpath) > 0:
        lastSectionWithTitleTocId = res_xpath[0].text

    for n in list(node):
        if n.tag == 'id':
            if lastSectionWithTitleTocId != '':
                dict['idRef'] = lastSectionWithTitleTocId
            else:
                dict['idRef'] = n.text
        elif n.tag != 'title' and n.tag != 'numbering' and n.tag != 'contentStatus' and n.tag != 'children' and n.tag != 'not_in_toc' and n.tag != 'lastSectionWithTitleTocId':
            dict[n.tag] = n.text
    return dict

def xmlToDict(node, res):
    rep = {}
    if len(node):
        for n in list(node):
            rep[node.tag] = []
            if n.tag == 'node':
                if (list(n)[4].tag == 'title' and list(n)[4].text is not None)\
                        and (list(n)[8].tag != 'not_in_toc' and list(n)[8].text != 'yes'):
                    parentNode = processModuleNodeToc(n,rep[node.tag])
                    res.append(parentNode)
            elif n.tag == 'tmp':
                xmlToDict(n, rep[node.tag])
                if len(n):
                    res.append(rep[node.tag])
                else:
                    res.append(rep[node.tag][0])
    else:
        res.append(node.text)
    return

def toc_create_pages_file(xml):
    res = {}
    res['pages'] = []
    listNode = XPATH_NODE(xml)
    lenList = len(listNode)
    for pos,node in enumerate(listNode):
        if pos < lenList-1:
            if list(listNode[pos])[5].text != list(listNode[pos+1])[5].text:
                res['pages'].append(processModuleNode(node))
        else:
            res['pages'].append(processModuleNode(node))
    return res

def create_file_with_zip_info(output_dir, zipname, name, mode):
    zf = zipfile.ZipFile(os.path.join(output_dir, zipname))

    uncompressedSize = 0

    for info in zf.infolist():
        uncompressedSize += info.file_size

    f = open(os.path.join(output_dir, "zip_info.txt"), mode, encoding='utf-8')
    f.write(unicode(name + '\t' + str(uncompressedSize) + '\n'))
    f.close()

def transform_to_mobile_app(args, variant):
    _check_exists_of_output_dir(os.path.join(args.output_dir, variant))

    collWithGeogebraExercises = checkIfCollectionContainsGeogebraTypeExercise()

    dirs = _create_temp_directories()
    input_dir_path = args.input_dir

    print "[py] convert mathml2png from womi exercises"
    tmp_mathml_engine_exercises = mkdtemp(suffix='-ep2mobile-app_mathEngine')
    list_change_womi = process_womi_engine_exercise(args.womi_dir, tmp_mathml_engine_exercises)
	
    temp_dir_after_variants = mkdtemp(suffix='-coll2mobile_app_2')
    if args.mode == 'o':
        status = transform_collection(input_dir_path, dirs, args.print_styles, args.womi_dir,collWithGeogebraExercises,tmp_mathml_engine_exercises)
    elif args.mode == 'x':
        collection2epxhtml.transform_to_epxhtml(input_dir_path, args.temp_dir)
        status = transform_collection(args.temp_dir, dirs, args.print_styles, args.womi_dir,collWithGeogebraExercises,tmp_mathml_engine_exercises)
    else:
        collection2epcollxml.transform_collxml_to_epcollxml(input_dir_path, temp_dir_after_variants, args.womi_dir)
        collection2epxhtml.transform_to_epxhtml(temp_dir_after_variants, args.temp_dir)
        status = transform_collection(args.temp_dir, dirs, args.print_styles, args.womi_dir,collWithGeogebraExercises,tmp_mathml_engine_exercises)

    shutil.rmtree(temp_dir_after_variants, ignore_errors=True)
    shutil.rmtree(args.temp_dir, ignore_errors=True)

    if status == -1:
        shutil.rmtree(dirs['root'], ignore_errors=True)
        return status

    currSubjects =getCurrSubject(input_dir_path)
    args.style_catalog = os.path.join(args.style_catalog, get_dir_stylesheet(currSubjects))

    download_fonts_and_scripts(dirs,currSubjects,collWithGeogebraExercises)

    output_path = os.path.join(args.output_dir, variant)
    output_file = output_path + '/mobile'

    bundle_zip(output_file + "-480.zip", dirs, args.womi_dir, args.print_styles, args.style_catalog, '480', list_change_womi, tmp_mathml_engine_exercises)
    bundle_zip(output_file + "-980.zip", dirs, args.womi_dir, args.print_styles, args.style_catalog, '980', list_change_womi, tmp_mathml_engine_exercises)
    bundle_zip(output_file + "-1440.zip", dirs, args.womi_dir, args.print_styles, args.style_catalog, '1440', list_change_womi, tmp_mathml_engine_exercises)
    bundle_zip(output_file + "-1920.zip", dirs, args.womi_dir, args.print_styles, args.style_catalog, '1920', list_change_womi, tmp_mathml_engine_exercises)

    create_file_with_zip_info(output_path, 'mobile-480.zip', '480', 'w')
    create_file_with_zip_info(output_path, 'mobile-980.zip', '980', 'a')
    create_file_with_zip_info(output_path, 'mobile-1440.zip', '1440', 'a')
    create_file_with_zip_info(output_path, 'mobile-1920.zip', '1920', 'a')

    shutil.rmtree(tmp_mathml_engine_exercises, ignore_errors=True)
    shutil.rmtree(dirs['root'], ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(
        description='PY_MOBILE_APP Transforms collxml collection with epxml modules to MOBILE APP archive',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', dest='input_dir', help='Path to directory with input collxml file', required=True)
    parser.add_argument('-w', dest='womi_dir', help='Path to womi directory', required=True)
    parser.add_argument('-s', dest='print_styles', help='Print styles to use (name of CSS files in css dir)', required=True)
    parser.add_argument('-sc', dest='style_catalog', help='Catalog with all print styles', required=True)

    parser.add_argument('-o', dest='output_dir', help='Path to result directory', default=utils.DEFAULT_RESULT_DIRECTORY)
    parser.add_argument('-t', dest='temp_dir', help='Path to temp directory', default=mkdtemp(suffix='-coll2html'))
    parser.add_argument('-p', dest='preview', help='Makes absolute links to womi , to be used in preview', action='store_true')
    parser.add_argument('-m', dest='mode', help='o - only mobile_app, x - xhtml + mobile_app, c or empty - collxml + epxhtml + mobile_app', default='o')
    parser.add_argument('-r', dest='recipient', help='Recipient of current content of modules (eq. student-canon)', default=utils.DEFAULT_RECIPIENT_CONTENT)

    print "[PY_MOBILE_APP] Transforming collxml2mobile_app"
    args = parser.parse_args()
    if(args.mode == 'a'):
        print >> sys.stderr, "[PY_MOBILE_APP] Bad parameter 'mode' value"
        sys.exit(1)

    args.input_dir = os.path.join(args.input_dir, args.recipient)
    global WOMI_DIR_PATH
    WOMI_DIR_PATH = args.womi_dir

    _check_arguments(args)
    status = transform_to_mobile_app(args, args.recipient)
    shutil.rmtree(args.temp_dir, ignore_errors=True)
    if status == -1:
        shutil.rmtree(args.output_dir, ignore_errors=True)
        print "[PY_ERR][PY_MOBILE_APP] Unsuccessful exit."
        sys.exit(1)
    print "[PY_MOBILE_APP] END transforming collxml2mobile_app"

if __name__ == '__main__':
    sys.exit(main())
