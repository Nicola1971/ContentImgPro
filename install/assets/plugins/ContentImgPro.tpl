/**
 * ContentImgPro
 *
 * Enhance and optimize images directly within content fields, adding responsive attributes, lazy loading, and SEO-friendly tags
 *
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1.7
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnLoadWebDocument
 * @internal    @installset base
 * @internal    @modx_category Images
 * @internal    @properties  &ImageSizes=Use image sizes from:;menu;imageAttribute,phpthumbParams;phpthumbParams &ImageWxl= Image Width:;string;1140 &ImageHxl= Image height (if empty it will be calculated automatically):;string;400 &ImageQ=Image quality:;string;80 &ImageZC=Image Zoom crop:;string;T &ImageF=Image Format:;string;webp &ImageClass= Image Class:;string;img-fluid &FetchPriority=fetchpriority:;menu;no,auto,low,high;no &Loading=loading:;menu;no,lazy;no &SearchSet=Create image responsive srcset:;menu;no,yes;no &ImageWlg=srcset Image width lg (992px):;string;964 &ImageWmd=srcset Image width md (768px):;string;724 &ImageWsm=srcset Image width sm (576px):;string;530 &DataPrefix=Append data- prefix to src and srcset:;menu;no,yes;no &exclude_docs=Exclude Documents by id (comma separated);string; &exclude_templates=Exclude Templates by id (comma separated);string;
 */

/*
###ContentImgPro for Evolution CMS###
Written By Nicola Lambathakis: http://www.tattoocms.it
Version 1.7 
*/
//<?php
if (!defined('MODX_BASE_PATH')) {
    die('What are you doing? Get out of here!');
}

// Verifica se il documento o il template sono esclusi
$exclude_docs = explode(',', $exclude_docs);
$exclude_templates = explode(',', $exclude_templates);
$doc_id = $modx->documentObject['id'];
$template_id = $modx->documentObject['template'];

if (!in_array($doc_id, $exclude_docs) && !in_array($template_id, $exclude_templates)) {

    $e = &$modx->Event;
    switch ($e->name) {
        case "OnLoadWebDocument":

            // Verifica che il contenuto sia HTML
            if ($modx->documentObject['contentType'] != 'text/html') {
                break;
            }

            // Ottieni il contenuto della pagina
            $o = &$modx->documentObject['content'];
            $dom = new DOMDocument();
            @$dom->loadHTML(mb_convert_encoding($o, 'HTML-ENTITIES', 'UTF-8'));

            // Cerca i tag <img>
            $imgTags = $dom->getElementsByTagName('img');
            foreach ($imgTags as $imgTag) {
                $old_src = $imgTag->getAttribute('src');

                // Mantieni l'impostazione delle dimensioni immagine se configurato
                if ($ImageSizes == 'imageAttribute') {
                    $ImageWxl = $imgTag->getAttribute('width');
                    $ImageHxl = $imgTag->getAttribute('height');
                } else {
                    // Verifica se $ImageHxl è impostato solo per questa immagine
                    $currentImageHxl = $ImageHxl; // Backup del valore globale

                    if (empty($currentImageHxl) && !empty($ImageWxl)) {
                        // Ottieni le dimensioni originali dell'immagine con getimagesize
                        $imagePath = MODX_BASE_PATH . $old_src;
                        if (file_exists($imagePath)) {
                            list($originalWidth, $originalHeight) = getimagesize($imagePath);

                            // Calcola l'altezza proporzionale per questa immagine
                            $currentImageHxl = round(($ImageWxl / $originalWidth) * $originalHeight);
                        } else {
                            $currentImageHxl = 400; // Fallback su un'altezza predefinita
                        }
                    }

                    // Imposta width e height per questa immagine
                    $imgTag->setAttribute('width', $ImageWxl);
                    $imgTag->setAttribute('height', $currentImageHxl);
                }

                // Aggiungi o modifica la classe delle immagini
                if ($ImageClass != '') {
                    $imgTag->setAttribute('class', $ImageClass);
                }

                // Genera il nuovo src con phpthumb nel formato specificato in $ImageF
                $new_src = $modx->runSnippet("phpthumb", array(
                    'input' => $old_src,
                    'options' => 'aoe=1,w=' . $ImageWxl . ',h=' . $ImageHxl . ',q=' . $ImageQ . ',zc=' . $ImageZC . ',f=' . $ImageF,
                    'adBlockFix' => '1'
                ));

                // Imposta l'attributo src o data-src in base a $DataPrefix
                if ($DataPrefix == 'yes') {
                    $imgTag->removeAttribute('src');
                    $imgTag->setAttribute('data-src', $new_src);
                } else {
                    $imgTag->setAttribute('src', $new_src);
                }

                if ($SearchSet == 'yes') {
                    // Genera data-srcset o srcset con le dimensioni 300w, 600w, 900w, tutte nel formato $ImageF
                    $srcset = '';
                    $widths = [$ImageWsm, $ImageWmd, $ImageWlg, $ImageWxl];
                    foreach ($widths as $width) {
                        $height = ($width / $ImageWxl) * $ImageHxl;
                        $srcset .= $modx->runSnippet("phpthumb", array(
                            'input' => $old_src,
                            'options' => 'aoe=1,w=' . $width . ',h=' . round($height) . ',q=' . $ImageQ . ',zc=' . $ImageZC . ',f=' . $ImageF,
                            'adBlockFix' => '1'
                        )) . " {$width}w, ";
                    }

                    // Rimuove l'ultima virgola e imposta l'attributo srcset o data-srcset
                    $srcset = rtrim($srcset, ', ');
                    if ($DataPrefix == 'yes') {
                        $imgTag->setAttribute('data-srcset', $srcset);
                    } else {
                        $imgTag->setAttribute('srcset', $srcset);
                    }

                    // Configura l'attributo sizes o data-sizes in base a $DataPrefix
                    if ($DataPrefix == 'yes') {
                        $imgTag->setAttribute('data-sizes', 'auto');
                    } else {
                        $imgTag->setAttribute('sizes', 
                            '(min-width: 1200px) ' . $ImageWxl . 'px, ' . 
                            '(min-width: 992px) ' . $ImageWlg . 'px, ' . 
                            '(min-width: 768px) ' . $ImageWmd . 'px, ' . 
                            '(min-width: 576px) ' . $ImageWsm . 'px, 100vw');
                    }
                }

                // Imposta l'attributo loading per lazy loading, se configurato
                if ($Loading != 'no') {
                    $imgTag->setAttribute('loading', $Loading);
                }

                // Imposta l'attributo fetchpriority, se configurato
                if ($FetchPriority != 'no') {
                    $imgTag->setAttribute('fetchpriority', $FetchPriority);
                }

                // Estrai il nome del file e prepara il testo per il tag alt e title
                $filename = basename($old_src, '.' . pathinfo($old_src, PATHINFO_EXTENSION));
                $altText = ucwords(trim(str_replace(['-', '_'], ' ', $filename)));

                // Imposta un alt testuale e title se non è già presente
                $imgTag->setAttribute('alt', $altText);
                $imgTag->setAttribute('title', $altText);
            }

            // Rimuove doctype, html, body e salva il nuovo HTML
            $html = preg_replace('~<(?:!DOCTYPE|/?(?:html|body))[^>]*>\s*~i', '', $dom->saveHTML());
            if ($html !== false) {
                $o = html_entity_decode($html);
            }

            // Sostituisci src con data-src se l'opzione DataPrefix è attivata
            if ($DataPrefix == 'yes') {
                $modx->documentObject['content'] = str_replace(' src="', ' data-src="', $modx->documentObject['content']);
            }

            // Correggi parentesi quadre codificate
            $arrFrom = array("%5B","%5D");
            $arrTo = array("[","]");
            $modx->documentObject['content'] = str_replace($arrFrom, $arrTo, $modx->documentObject['content']);

            break;

        default:
            return;
    }
}