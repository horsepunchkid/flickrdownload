/*
  FlickrDownload - Copyright(C) 2011 Brian Masney <masneyb@gmail.com>.
  If you have any questions, comments, or suggestions about this program, please
  feel free to email them to me. You can always find out the latest news about
  FlickrDownload from my website at http://code.google.com/p/flickrdownload/

  FlickrDownload comes with ABSOLUTELY NO WARRANTY; for details, see the COPYING
  file. This is free software, and you are welcome to redistribute it under
  certain conditions; for details, see the COPYING file.
*/

package org.gftp.FlickrDownload;

import java.io.IOException;
import java.util.LinkedHashSet;

import org.apache.log4j.Logger;
import org.jdom.Element;
import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.photos.Photo;
import com.aetrion.flickr.photos.PhotoList;

public class PhotosNotInASet extends AbstractSet {
	private LinkedHashSet<BasePhoto> photoIds = new LinkedHashSet<BasePhoto>();
	private String primaryPhotoId;
	private String primaryPhotoSmallSquareUrl;

	public PhotosNotInASet(Configuration configuration, Flickr flickr) throws IOException, SAXException, FlickrException {
		super(configuration);

		Logger.getLogger(getClass()).info("Downloading list of photos that are not in a set");

		int pageNum = 1;
		while (true) {
			PhotoList photos = flickr.getPhotosInterface().getNotInSet(500, pageNum);
			if (photos.getTotal() == 0)
				break;

			for (int i = 0; i < photos.getTotal(); i++) {
				Photo photo = (Photo) photos.get(i);
				if (this.primaryPhotoId == null) {
					this.primaryPhotoId = photo.getId();
					this.primaryPhotoSmallSquareUrl = photo.getSmallSquareUrl();
				}

				this.photoIds.add(new BasePhoto(photo));
			}
			pageNum++;
		}

		Logger.getLogger(getClass()).info(String.format("There are a total of %s photos that are not in a set", this.photoIds.size()));
	}

	@Override
	protected void download(Flickr flickr, Element setXml) throws IOException, SAXException, FlickrException {
		processPhotoList(this.photoIds, flickr, setXml);			
	}

	@Override
	protected int getMediaCount() {
		return this.photoIds.size();
	}

	@Override
	protected String getPrimaryPhotoId() {
		return this.primaryPhotoId;
	}

	@Override
	protected String getPrimaryPhotoSmallSquareUrl() {
		return this.primaryPhotoSmallSquareUrl;
	}

	@Override
	protected String getSetDescription() {
		return "";
	}

	@Override
	protected String getSetId() {
		return "photos-not-in-a-set";
	}

	@Override
	protected String getSetTitle() {
		return "Photos Not In A Set";
	}

}
