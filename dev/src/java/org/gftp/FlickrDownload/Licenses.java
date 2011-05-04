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

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.photos.licenses.License;

public class Licenses {
	private static Map<String,String> licenses;

	private synchronized static Map<String,String> getLicenses(Flickr flickr) throws FlickrException, IOException, SAXException {
		if (licenses == null) {
			licenses = new HashMap<String, String>();
	    	for (Object lic : flickr.getLicensesInterface().getInfo()) {
	    		licenses.put(((License) lic).getId(), ((License) lic).getName());
	    	}			
		}
		return licenses;
	}

	public static String getLicense(Flickr flickr, String id) throws FlickrException, IOException, SAXException {
		return getLicenses(flickr).get(id);
	}
}
