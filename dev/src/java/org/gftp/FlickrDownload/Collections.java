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

import org.jdom.Element;
import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.photocollections.PhotoCollection;
import com.aetrion.flickr.photocollections.PhotoCollectionsInterface;
import com.aetrion.flickr.photosets.Photoset;

public class Collections {
	public static String COLLECTIONS_ICON_DIRECTORY = "collections";
	private Configuration configuration;
	private Flickr flickr;

	public Collections(Configuration configuration, Flickr flickr) {
		this.configuration = configuration;
		this.flickr = flickr;
	}
	
	public Element createTopLevelXml() throws FlickrException, SAXException, IOException {
		PhotoCollectionsInterface collectionsInterface = this.flickr.getPhotoCollectionsInterface();

		File iconsDir = new File(this.configuration.photosBaseDirectory, COLLECTIONS_ICON_DIRECTORY);
		iconsDir.mkdir();

		Element allCollections = new Element("collections");
    	for (PhotoCollection collection : collectionsInterface.getTree(this.configuration.photosUser.getId())) {
    		Element setsEle = new Element("sets");
    		for (Photoset set : collection.getSets()) {
    			setsEle.addContent(new Element("set")
    				.setAttribute("id", set.getId())
    				.setAttribute("title", set.getTitle()));
    		}

    		File largeFile = new File(iconsDir, collection.getId() + "-large.jpg");
    		File smallFile = new File(iconsDir, collection.getId() + "-small.jpg");

    		allCollections.addContent(new Element("collection")
    			.addContent(new Element("id").setText(collection.getId()))
    			.addContent(new Element("title").setText(collection.getTitle()))
    			.addContent(new Element("description").setText(collection.getDescription()))
    			.addContent(XmlUtils.downloadMediaAndCreateElement("iconLarge", largeFile, iconsDir.getName() + File.separator + largeFile.getName(), collection.getIconLarge(), this.configuration.downloadCollectionIcons))
    			.addContent(XmlUtils.downloadMediaAndCreateElement("iconSmall", smallFile, iconsDir.getName() + File.separator + smallFile.getName(), collection.getIconSmall(), this.configuration.downloadCollectionIcons))
    			.addContent(setsEle));
    	}

    	return allCollections;
	}
}
