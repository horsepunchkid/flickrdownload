/*
  FlickrDownload - Copyright(C) 2011 Brian Masney <masneyb@onstation.org>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://www.onstation.org/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
*/

package org.gftp.FlickrDownload;

import java.io.IOException;
import java.util.Collection;

import javax.xml.transform.TransformerException;

import org.jdom.Element;

public interface MediaIndexer {
	void addToIndex(String setId, Element mediaElement);

	Collection<String> writeIndex() throws IOException, TransformerException;
}
