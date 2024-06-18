/**
 * PhpThumbContentImages
 *
 * Convert Images in the content field to phpthumb images and adds more attributes and features
 *
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1.5
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnLoadWebDocument
 * @internal    @installset base
 * @internal    @modx_category Images
 * @internal    @properties  &ImageSizes=Use image sizes from:;menu;imageAttribute,phpthumbParams;phpthumbParams &ImageW=Image width:;string;1200 &ImageH=Image height:;string;400 &ImageQ=Image quality:;string;80 &ImageZC=Image Zoom crop:;string;T &ImageF=Image Format:;string;webp &ImageClass= Image Class:;string;img-fluid &FetchPriority=fetchpriority:;menu;no,auto,low,high;no &Loading=loading:;menu;no,lazy;no &DataSRC=Change src to data-src (for lazyload plugins):;menu;no,yes;no  &exclude_docs=Exclude Documents by id (comma separated);string; &exclude_templates=Exclude Templates by id (comma separated);string;
 */

/*
###PhpThumbContentImages for Evolution CMS###
Written By Nicola Lambathakis: http://www.tattoocms.it
Version 1.5 
*/
$exclude_docs = explode(',',$exclude_docs);
$exclude_templates = explode(',',$exclude_templates);
// exclude by doc id or template id
$doc_id = $modx -> documentObject['id'];
$template_id = $modx -> documentObject['template'];
	if (!in_array($doc_id,$exclude_docs) && !in_array($template_id,$exclude_templates)) {		
$e= & $modx->Event;
switch ($e->name) {
case "OnLoadWebDocument":
	    //check if it is an text/html document
	if ($modx->documentObject['contentType'] != 'text/html') {
			break;
		}
	    //Get the output from the content 
		$o = &$modx->documentObject['content'];
			$dom = new DOMDocument(); 
		    $dom->loadHTML(mb_convert_encoding($o, 'HTML-ENTITIES', 'UTF-8')); 
			
		//Search img tag and src attribute (image url)
			$imgTags = $dom->getElementsByTagName('img');
			foreach ($imgTags as $imgTag) {
			$old_src = $imgTag->getAttribute('src');
		//check wich image sizes use 
		if ($ImageSizes == 'imageAttribute') {
			$ImageW = $imgTag->getAttribute('width');
			$ImageH = $imgTag->getAttribute('height');
		} else {
			$imgTag->setAttribute('width', $ImageW);
			$imgTag->setAttribute('height', $ImageH);
		}
		// Add new or modifies image class 
		if ($ImageClass != '') {
			$imgTag->setAttribute('class', $ImageClass);
		}
		//Run phpthumb	
		$new_src = $modx->runSnippet("phpthumb", array('input'=>''.$old_src.'', 'options'=>'aoe=1,w='.$ImageW.',h='.$ImageH.',q='.$ImageQ.',zc='.$ImageZC.',f='.$ImageF.'', 'adBlockFix'=>'1'));
		//Loading attribute
		if ($Loading != 'no') {
			$imgTag->setAttribute('loading', $Loading);
		}
		//FetchPriority attribute
		if ($FetchPriority != 'no') {
			$imgTag->setAttribute('fetchpriority', $FetchPriority);
		}		
		//Replace img src url with phpthumb 	
			$imgTag->setAttribute('src', $new_src);
	    }
		//Remove doctype, html, body amd saveHTML
		$html = preg_replace('~<(?:!DOCTYPE|/?(?:html|body))[^>]*>s*~i', '', $dom->saveHTML());

		if ($html !== false) {
				$o = html_entity_decode($html);
		}
		//Change src to data-src 
		if ($DataSRC == 'yes') {
	    $modx->documentObject['content'] = str_replace(' src="',' data-src="',$modx->documentObject['content']);
		}
		//fix brackets
		$arrFrom = array("%5B","%5D");
		$arrTo = array("[","]");
		$modx->documentObject['content'] = str_replace($arrFrom, $arrTo,$modx->documentObject['content']);
		break;
	default :
		return; // stop here
		break;
     }
}