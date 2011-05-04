/*
  FlickrDownload - Copyright(C) 2010 Brian Masney <masneyb@gmail.com>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://code.google.com/p/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
*/

package org.gftp.FlickrDownload;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.xml.transform.TransformerException;

import org.apache.log4j.Logger;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.xml.sax.SAXException;

import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.photosets.Photoset;

public class Sets {
	public static String SET_THUMBNAIL_FILENAME = "index.html";
	public static String SET_DETAIL_FILENAME = "detail.html";

	private Map<String,Set> sets = null;
	protected Configuration configuration;

	public Sets(Configuration configuration) throws Exception {
		this.configuration = configuration;
		this.sets = getSets();
	}

	public Map<String,Set> getSets() throws FlickrException, IOException, SAXException {
		if (this.sets != null)
			return this.sets;
		this.sets = new HashMap<String, Set>();

		Logger.getLogger(Sets.class).info("Downloading photo set information");

		Map<String,Set> setMap = new LinkedHashMap<String, Set>();
        Iterator<Photoset> fsets = this.configuration.flickr.getPhotosetsInterface().getList(this.configuration.photosUser.getId()).getPhotosets().iterator();
        while (fsets.hasNext()) {
            Photoset fset = fsets.next();
        	Set s = new Set(fset, this.configuration);
        	setMap.put(fset.getId(), s);
        }

        return setMap;
	}
	
	public Element createTopLevelXml() throws JDOMException, IOException {
		Element allSets = new Element("sets");
    	for (String key : this.sets.keySet()) {
    		allSets.addContent(this.sets.get(key).createToplevelXml());
    	}
    	return allSets;
	}
	
	public Collection<String> performXsltTransformation() throws IOException, TransformerException {	
    	for (String key : this.sets.keySet()) {
    		Set set = this.sets.get(key);

    		File setXmlFile = set.getSetXmlFilename();
    		if (!setXmlFile.exists())
    			continue;

    		File setDir = set.getSetDirectory();
    		XmlUtils.performXsltTransformation(this.configuration, "set.xsl",
    				setXmlFile,
    				new File(setDir, SET_THUMBNAIL_FILENAME));

    		XmlUtils.performXsltTransformation(this.configuration, "set_detail.xsl",
    				setXmlFile,
    				new File(setDir, SET_DETAIL_FILENAME));
    	}		
    	return this.sets.keySet();
	}

	public void downloadAllPhotos(Collection<String> limitDownloadsToSets) throws Exception {
		for (final String key : this.sets.keySet()) {
			if (limitDownloadsToSets.size() > 0 && !limitDownloadsToSets.contains(key))
				continue;

			final Set set = this.sets.get(key);

			File setDir = new File(Sets.this.configuration.photosBaseDirectory, key);
			setDir.mkdir();

			File setXmlFilename = set.getSetXmlFilename();
			if (Sets.this.configuration.partialDownloads && setXmlFilename.exists() && Stats.getMediaCount(setXmlFilename) == set.getMediaCount()) {
				Logger.getLogger(getClass()).info("Skipping the download of set " + key);
				continue;
			}

			XmlUtils.outputXmlFile(setXmlFilename, set.createSetlevelXml(Sets.this.configuration.flickr, setDir));
		}
	}
}
