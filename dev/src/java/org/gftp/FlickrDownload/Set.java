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
import java.util.HashSet;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.gftp.FlickrDownload.Stats.MediaStats;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.xml.sax.SAXException;

import com.aetrion.flickr.Flickr;
import com.aetrion.flickr.FlickrException;
import com.aetrion.flickr.photos.Exif;
import com.aetrion.flickr.photos.GeoData;
import com.aetrion.flickr.photos.Note;
import com.aetrion.flickr.photos.Photo;
import com.aetrion.flickr.photos.PhotoList;
import com.aetrion.flickr.photos.Size;
import com.aetrion.flickr.photosets.Photoset;
import com.aetrion.flickr.tags.Tag;

public class Set {
	public static String SET_XML_FILENAME = "photos.xml";
	public static String SMALL_SQUARE_PHOTO_DESCRIPTION = "Small Square";
	public static String THUMBNAIL_PHOTO_DESCRIPTION = "Thumbnail";
	public static String SMALL_PHOTO_DESCRIPTION = "Small";
	public static String MEDIUM_PHOTO_DESCRIPTION = "Medium";
	public static String LARGE_PHOTO_DESCRIPTION = "Large";
	public static String ORIGINAL_MEDIA_DESCRIPTION = "Original";

	private Photoset set;
	private Configuration configuration;
	
	public Set (Photoset set, Configuration configuration) throws SAXException, IOException, FlickrException {
		this.set = set;
		this.configuration = configuration;
	}
	
	public int getMediaCount() {
		return this.set.getPhotoCount() + this.set.getVideoCount();
	}

	public File getSetDirectory() {
		return new File(this.configuration.photosBaseDirectory, this.set.getId());
	}

	public File getSetXmlFilename() {
		return new File(getSetDirectory(), SET_XML_FILENAME);
	}

	private Element createStatsXml() throws JDOMException, IOException {
		Map<String, MediaStats> allStats = new HashMap<String, MediaStats>();
		Stats.processXmlFile(getSetXmlFilename(), allStats);
		return Stats.generateStatsXml(allStats);
	}

	public Element createToplevelXml() throws JDOMException, IOException {
		String setThumbnailBaseFilename = String.format("%s_thumb_sq.jpg", this.set.getPrimaryPhoto().getId());
		File setDir = new File(this.configuration.photosBaseDirectory, this.set.getId());
		return new Element("set")
				.addContent(new Element("id").setText(this.set.getId()))
				.addContent(new Element("title").setText(this.set.getTitle()))
				.addContent(new Element("description").setText(this.set.getDescription()))
				.addContent(XmlUtils.downloadMediaAndCreateElement("thumbnailFile", 
						new File(setDir, setThumbnailBaseFilename), 
						this.set.getId() + File.separator + setThumbnailBaseFilename, 
						this.set.getPrimaryPhoto().getSmallSquareUrl(), false))
				.addContent(createStatsXml());
	}

	public Element createSetlevelXml(Flickr flickr, File setDir) throws IOException, SAXException, FlickrException {
		Collection<String> expectedFiles = new HashSet<String>();
		expectedFiles.add(SET_XML_FILENAME);
		expectedFiles.add(Sets.SET_THUMBNAIL_FILENAME);
		expectedFiles.add(Sets.SET_DETAIL_FILENAME);

		Logger.getLogger(getClass()).info(String.format("Downloading information for set %s - %s",
				this.set.getId(), this.set.getTitle()));

		Element setXml = new Element("set")
				.addContent(XmlUtils.createApplicationXml())
				.addContent(XmlUtils.createUserXml(this.configuration))
				.addContent(new Element("id").setText(this.set.getId()))
				.addContent(new Element("title").setText(this.set.getTitle()))
				.addContent(new Element("description").setText(this.set.getDescription()));

		String primaryPhotoId = this.set.getPrimaryPhoto().getId();

		int pageNum = 1;
		int retrievedPhotos = 0;
		do {
			PhotoList photos = flickr.getPhotosetsInterface().getPhotos(this.set.getId(), 500, pageNum);
			retrievedPhotos += photos.getTotal();
            for (int i = 0; i < photos.getTotal(); i++) {
            	Photo basePhoto = (Photo) photos.get(i);
                Photo photo = flickr.getPhotosInterface().getPhoto(basePhoto.getId(), basePhoto.getSecret());

                Element tagEle = new Element("tags");
                for (Object tagObj : photo.getTags()) {
                	Tag tag = (Tag) tagObj;
                	tagEle.addContent(new Element("tag")
                		.setAttribute("author", tag.getAuthor())
                		.setAttribute("value", tag.getValue()));
                }

                Element notesEle = new Element("notes");
                for (Note note : (Collection<Note>) photo.getNotes()) {
                	notesEle.addContent(new Element("note")
                		.setAttribute("id", note.getId())
                		.setAttribute("author", note.getAuthor())
                		.setAttribute("text", note.getText())
                		.setAttribute("x", String.valueOf(note.getBounds().getX()))
                		.setAttribute("y", String.valueOf(note.getBounds().getY()))
                		.setAttribute("width", String.valueOf(note.getBounds().getWidth()))
                		.setAttribute("height", String.valueOf(note.getBounds().getHeight())));
                }

                Element exifTagsEle = new Element("exif");
                for (Exif exif : (Collection<Exif>) flickr.getPhotosInterface().getExif(photo.getId(), photo.getSecret())) {
                	exifTagsEle.addContent(new Element("exif")
                		.setAttribute("clean", StringUtils.defaultString(exif.getClean()))
                		.setAttribute("label", StringUtils.defaultString(exif.getLabel()))
                		.setAttribute("raw", StringUtils.defaultString(exif.getRaw()))
                		.setAttribute("tag", StringUtils.defaultString(exif.getTag()))
                		.setAttribute("tagspace", StringUtils.defaultString(exif.getTagspace()))
                		.setAttribute("tagspaceId", StringUtils.defaultString(exif.getTagspaceId())));
                }

                String originalUrl = null;
                String originalBaseFilename;
                if (photo.getMedia().equals("video")) {
                	originalUrl = getOriginalVideoUrl(flickr, photo.getId());
                	originalBaseFilename = String.format("%s_orig.%s", 
                			photo.getId(),
                			IOUtils.getExtension(IOUtils.getRemoteFilename(originalUrl)));
                }
                else {
                	try {
                		originalUrl = photo.getOriginalUrl();
                	}
                	catch (FlickrException e) {
                		// NOOP - original URL not available
                	}
            		originalBaseFilename = String.format("%s_orig.%s", 
            				photo.getId(), 
            				photo.getOriginalFormat());
                }

                String smallSquareBaseFilename = String.format("%s_thumb_sq.jpg", photo.getId());
                String mediumBaseFilename = String.format("%s_med.jpg", photo.getId());

        		expectedFiles.add(String.format("%s.html", photo.getId()));
                expectedFiles.add(smallSquareBaseFilename);
                expectedFiles.add(mediumBaseFilename);
                expectedFiles.add(originalBaseFilename);

                GeoData geoData = photo.getGeoData();
                setXml.addContent(new Element("media")
                	.setAttribute("type", photo.getMedia())
                	.addContent(new Element("id").setText(photo.getId()))
                	.addContent(new Element("title").setText(photo.getTitle()))
                	.addContent(new Element("description").setText(photo.getDescription()))
        			.addContent(new Element("publicUrl").setText(photo.getUrl()))
        			.addContent(XmlUtils.createMediaElement("image", null, null, photo.getThumbnailUrl())
        					.setAttribute("type", THUMBNAIL_PHOTO_DESCRIPTION))
        			.addContent(XmlUtils.createMediaElement("image", null, null, photo.getSmallUrl())
        					.setAttribute("type", SMALL_PHOTO_DESCRIPTION))
                	.addContent(XmlUtils.downloadMediaAndCreateElement("image",
                			new File(setDir, smallSquareBaseFilename), 
                			smallSquareBaseFilename,
                			photo.getSmallSquareUrl(),
                			false)
                				.setAttribute("type", SMALL_SQUARE_PHOTO_DESCRIPTION))
                	.addContent(XmlUtils.downloadMediaAndCreateElement("image",
                			new File(setDir, mediumBaseFilename), 
                			mediumBaseFilename,
                			photo.getMediumUrl(),
                			false)
                				.setAttribute("type", MEDIUM_PHOTO_DESCRIPTION))
        			.addContent(XmlUtils.createMediaElement("image", null, null, photo.getLargeUrl())
        					.setAttribute("type", LARGE_PHOTO_DESCRIPTION))
                	.addContent(XmlUtils.downloadMediaAndCreateElement("image",
                			new File(setDir, originalBaseFilename), 
                			originalBaseFilename,
                			originalUrl,
                			false)
                				.setAttribute("type", ORIGINAL_MEDIA_DESCRIPTION)
                				.setAttribute("format", photo.getOriginalFormat()))
               		.addContent(new Element("dates")               		
               			.addContent(XmlUtils.createDateElement("taken", photo.getDateTaken())
               				.setAttribute("granularity", photo.getTakenGranularity()))
               			.addContent(XmlUtils.createDateElement("uploaded", photo.getDatePosted()))
               			.addContent(XmlUtils.createDateElement("lastUpdate", photo.getLastUpdate())))
                	.addContent(new Element("license").setText(Licenses.getLicense(flickr, photo.getLicense())))
                	.addContent(new Element("primary").setText(photo.getId().equals(primaryPhotoId) ? "1" : "0"))
                	.addContent(new Element("privacy")
                		.setAttribute("family", (photo.isFamilyFlag() ? "1" : "0"))
                		.setAttribute("friends", (photo.isFriendFlag() ? "1" : "0"))
                		.setAttribute("public", (photo.isPublicFlag() ? "1" : "0")))
                	.addContent(new Element("rotation").setText(String.valueOf(photo.getRotation())))
                	.addContent(new Element("geodata")
                		.setAttribute("placeId", photo.getPlaceId())
                		.setAttribute("acuracy", geoData == null ? "" : String.valueOf(geoData.getAccuracy()))
                		.setAttribute("latitude", geoData == null ? "" : String.valueOf(geoData.getLatitude()))
                		.setAttribute("longitude", geoData == null ? "" : String.valueOf(geoData.getLongitude())))
                  	.addContent(tagEle)
                   	.addContent(notesEle)
                   	.addContent(exifTagsEle)
                );
            }
		} while (retrievedPhotos < this.set.getPhotoCount());

		IOUtils.findFilesThatDoNotBelong(setDir, expectedFiles, this.configuration.addExtensionToUnknownFiles);
		return setXml;
	}

	// FIXME - move this into the flickrj library
	private String getOriginalVideoUrl(Flickr flickr, String photoId) throws IOException, FlickrException, SAXException {
		for (Size size : (Collection<Size>) flickr.getPhotosInterface().getSizes(photoId, true)) {
			if (size.getSource().contains("/play/orig"))
				return size.getSource();
		}
		return null;
	}
}
